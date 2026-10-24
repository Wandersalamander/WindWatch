# Runs the pinned Connect IQ image (scripts/toolchain.env), sourced by the scripts
# that need it. On Windows without Docker, the Docker inside the default WSL
# distribution runs it, so Linux, macOS and Windows use the same container.

docker_available() {
  command -v docker >/dev/null || wsl_docker_available
}

wsl_docker_available() {
  command -v wsl.exe >/dev/null && wsl.exe docker version >/dev/null 2>&1
}

# The host directory as the Docker daemon sees it, for volume mounts
docker_path() {
  if command -v docker >/dev/null; then
    echo "$1"
  else
    wsl.exe wslpath -a "$(cygpath -m "$1")" | tr -d '\r'
  fi
}

# docker run with the repository mounted at /app; the arguments go to docker run.
# MSYS_NO_PATHCONV keeps Git Bash on Windows from rewriting the container paths.
run_image() {
  if command -v docker >/dev/null; then
    MSYS_NO_PATHCONV=1 docker run --rm -v "$PWD:/app" -w /app "$@"
  else
    MSYS_NO_PATHCONV=1 wsl.exe bash scripts/wsl_docker_run.sh "$@"
  fi
}
