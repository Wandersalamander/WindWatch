"""Takes the README screenshots Glance.png, View.png, ViewToday.png,
ViewDays.png and Menu.png in the simulator.

Runs inside the Connect IQ Docker image (see scripts/screenshots.sh), which
has the simulator, Xvfb and python3, but no screenshot tool. So the screen is
read from the framebuffer file Xvfb writes. The simulator starts the app in
its glance or its full view depending on a setting in simulator.ini.

The device files are changed in place, which is safe in the throwaway container.

Usage: python3 scripts/simulator_screenshots.py <device> <output directory>
"""

import ctypes
import json
import os
import resource
import struct
import subprocess
import sys
import time
import zlib

CONNECTIQ_DEVICES = "/root/.Garmin/ConnectIQ/Devices"
SIMULATOR_SETTINGS = "/root/.Garmin/ConnectIQ/simulator.ini"
DISPLAY = ":1"
FRAMEBUFFER_DIR = "/tmp/framebuffer"
SCREEN_SIZE = "1280x1024x24"
# Top left corner of the device image in the simulator window, below its menu bar
DEVICE_IMAGE_OFFSET = (1, 26)
SIMULATOR_START_SECONDS = 5
# ponytail: fixed wait for the Open-Meteo requests, poll the screen if it gets flaky
APP_LOAD_SECONDS = 25
# The menu slides in or out
MENU_OPEN_SECONDS = 3
# The page loop shows where you are for a moment after the menu closes
PAGE_INDICATOR_SECONDS = 5
# The view redraws the next forecast page
PAGE_SWITCH_SECONDS = 2
# The simulator ignores a press and release without a pause between them
KEY_HOLD_SECONDS = 0.15


def main(device, output_dir):
    # The simulator can crash on shutdown, and its core dump would be copied
    # back into the repository
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    program = build(device)
    simulator_config = load_simulator_config(device)
    center_glance(device, simulator_config)
    os.environ["DISPLAY"] = DISPLAY
    os.makedirs(FRAMEBUFFER_DIR, exist_ok=True)
    start(["Xvfb", DISPLAY, "-screen", "0", SCREEN_SIZE, "-fbdir", FRAMEBUFFER_DIR])
    def save(file_name):
        save_device_image(
            device, simulator_config, os.path.join(output_dir, file_name))

    simulator = start_app(program, device, glance_setting="1")
    save("Glance.png")
    simulator.kill()
    simulator.wait()

    # The menu opens by itself on the first start, as no favourite is stored
    start_app(program, device, glance_setting="0")
    save("Menu.png")
    press_key(simulator_config, "esc")
    time.sleep(MENU_OPEN_SECONDS + PAGE_INDICATOR_SECONDS)
    save("View.png")
    for page in ("ViewToday.png", "ViewDays.png"):
        press_key(simulator_config, "down")
        time.sleep(PAGE_SWITCH_SECONDS)
        save(page)


def start_app(program, device, glance_setting):
    with open(SIMULATOR_SETTINGS, "w") as settings:
        settings.write(f"Glance={glance_setting}\n")
    simulator = start(["simulator"])
    time.sleep(SIMULATOR_START_SECONDS)
    start(["monkeydo", program, device])
    time.sleep(APP_LOAD_SECONDS)
    return simulator


def build(device):
    key_pem, key_der, program = "/tmp/key.pem", "/tmp/key.der", "/tmp/app.prg"
    run(["openssl", "genrsa", "-out", key_pem, "4096"])
    run(["openssl", "pkcs8", "-topk8", "-inform", "PEM", "-outform", "DER",
         "-in", key_pem, "-out", key_der, "-nocrypt"])
    run(["monkeyc", "-f", "monkey.jungle", "-d", device, "-o", program,
         "-y", key_der, "-l", "3"])
    return program


def run(command):
    subprocess.run(command, check=True, stdout=subprocess.DEVNULL)


def start(command):
    return subprocess.Popen(
        command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def simulator_config_path(device):
    return os.path.join(CONNECTIQ_DEVICES, device, "simulator.json")


def load_simulator_config(device):
    with open(simulator_config_path(device)) as file:
        return json.load(file)


# The simulator draws the glance in the top slot of the glance list, while the
# watch shows the selected glance in the middle
def center_glance(device, config):
    glance = config["glance"]
    content = glance["contentArea"]
    display_height = config["display"]["location"]["height"]
    shift = (display_height - content["height"]) // 2 - content["y"]
    content["y"] += shift
    # Some devices, like the Instinct 2, show glances without an icon
    if "iconArea" in glance:
        glance["iconArea"]["y"] += shift
    with open(simulator_config_path(device), "w") as file:
        json.dump(config, file)


# Clicks the key's button on the device image, through the XTest library of the
# image, as the image has no input tool like xdotool
def press_key(config, key_id):
    location = next(key["location"] for key in config["keys"] if key["id"] == key_id)
    x = DEVICE_IMAGE_OFFSET[0] + location["x"] + location["width"] // 2
    y = DEVICE_IMAGE_OFFSET[1] + location["y"] + location["height"] // 2
    x11 = ctypes.cdll.LoadLibrary("libX11.so.6")
    xtest = ctypes.cdll.LoadLibrary("libXtst.so.6")
    x11.XOpenDisplay.restype = ctypes.c_void_p
    display = ctypes.c_void_p(x11.XOpenDisplay(DISPLAY.encode()))
    left_button, no_delay, current_screen = 1, 0, -1
    xtest.XTestFakeMotionEvent(display, current_screen, x, y, no_delay)
    xtest.XTestFakeButtonEvent(display, left_button, True, no_delay)
    x11.XFlush(display)
    time.sleep(KEY_HOLD_SECONDS)
    xtest.XTestFakeButtonEvent(display, left_button, False, no_delay)
    x11.XFlush(display)


def save_device_image(device, config, path):
    device_image = os.path.join(CONNECTIQ_DEVICES, device, config["image"])
    width, height = png_size(device_image)
    left, top = DEVICE_IMAGE_OFFSET
    rows = read_framebuffer_rows(left, top, width, height)
    write_png(path, width, height, rows)


def png_size(path):
    with open(path, "rb") as file:
        header = file.read(24)
    return struct.unpack(">II", header[16:24])


# Xvfb writes the screen in XWD format: a header of 25 big-endian numbers,
# the window name, the color map and then 32 bit BGRX pixels
def read_framebuffer_rows(left, top, width, height):
    with open(os.path.join(FRAMEBUFFER_DIR, "Xvfb_screen0"), "rb") as file:
        data = file.read()
    header = struct.unpack(">25I", data[:100])
    header_size, bits_per_pixel, bytes_per_line, color_count = (
        header[0], header[11], header[12], header[19])
    assert bits_per_pixel == 32, f"unexpected {bits_per_pixel} bits per pixel"
    pixels = data[header_size + 12 * color_count:]
    rows = []
    for y in range(top, top + height):
        start = y * bytes_per_line + 4 * left
        bgrx = pixels[start:start + 4 * width]
        rgb = bytearray(3 * width)
        rgb[0::3], rgb[1::3], rgb[2::3] = bgrx[2::4], bgrx[1::4], bgrx[0::4]
        rows.append(bytes(rgb))
    return rows


def write_png(path, width, height, rows):
    def chunk(kind, body):
        crc = zlib.crc32(kind + body)
        return struct.pack(">I", len(body)) + kind + body + struct.pack(">I", crc)

    bit_depth, rgb_color_type = 8, 2
    header = struct.pack(">IIBBBBB", width, height, bit_depth, rgb_color_type, 0, 0, 0)
    no_filter = b"\0"
    image = zlib.compress(b"".join(no_filter + row for row in rows), 9)
    with open(path, "wb") as file:
        file.write(b"\x89PNG\r\n\x1a\n")
        file.write(chunk(b"IHDR", header) + chunk(b"IDAT", image) + chunk(b"IEND", b""))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
