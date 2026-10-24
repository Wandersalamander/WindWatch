import Toybox.Graphics;
import Toybox.Lang;

// Lower limits of the wind speed bands in km/h, following the Beaufort scale:
// 0-1 calm, 2 light, 3 gentle, 4 moderate, 5 fresh and 6+ strong breeze.
// The open top band is closed at Beaufort 7, so each band maps onto one
// equally wide color bar segment.
(:glance)
const COLOR_BAND_LIMITS as Array<Float> = [
    0.0, 6.0, 12.0, 20.0, 29.0, 39.0, 50.0,
];

// Green marks good sailing wind, red the wind that Swiss lake storm warnings flash for
(:glance,:colorDisplay)
const BAND_COLORS as Array<Lang.Number or Graphics.ColorValue> = [
    Graphics.COLOR_DK_BLUE,
    Graphics.COLOR_BLUE,
    0x00ffff,
    Graphics.COLOR_GREEN,
    Graphics.COLOR_YELLOW,
    Graphics.COLOR_RED,
];

(:glance,:colorDisplay)
function getColor(speed as Float?) as Lang.Number or Graphics.ColorValue {
    if (speed == null) {
        return Graphics.COLOR_DK_GRAY;
    }
    return BAND_COLORS[bandOf(speed)];
}

// Monochrome displays draw the nearest of black and white, which turns half
// the wind colors black and so invisible on the black background
(:glance,:monochromeDisplay)
function getColor(speed as Float?) as Lang.Number or Graphics.ColorValue {
    return Graphics.COLOR_WHITE;
}

//! Index of the band of the speed, the outer bands also take speeds beyond them
(:glance)
function bandOf(speed as Float) as Number {
    var band = 0;
    while (band + 1 < bandCount() && speed >= COLOR_BAND_LIMITS[band + 1]) {
        band++;
    }
    return band;
}

(:glance)
function bandCount() as Number {
    return COLOR_BAND_LIMITS.size() - 1;
}

//! Position 0..1 of the speed on the color bar drawn by getColorByIdx
(:glance)
function getColorPos(speed as Float?) as Float {
    if (speed == null) {
        return 0.0;
    }
    var band = bandOf(speed);
    var lower = COLOR_BAND_LIMITS[band];
    var upper = COLOR_BAND_LIMITS[band + 1];
    var positionInBand = (speed - lower) / (upper - lower);
    if (positionInBand < 0.0) {
        positionInBand = 0.0;
    }
    if (positionInBand > 1.0) {
        positionInBand = 1.0;
    }
    return (band + positionInBand) / bandCount();
}

(:glance)
function getColorByIdx(idx as Number) as Lang.Number or Graphics.ColorValue {
    return getColor(COLOR_BAND_LIMITS[idx]);
}
