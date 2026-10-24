#!/usr/bin/env bash
# Verifies the live Open-Meteo API still returns what currentWind(),
# hourlyForecast() and quarterHourlyForecast() in source/OpenMeteo.mc expect,
# at spots spread over the world, as the app works anywhere.
set -uo pipefail

OPEN_METEO="$(dirname "$0")/../source/OpenMeteo.mc"
# name latitude longitude, rounded like positionKey() in source/Spot.mc
SPOTS="versoix 46.29 6.17
tarifa 36.01 -5.60
hood_river 45.71 -121.51
cape_town -33.92 18.42
sydney -33.86 151.21
lake_titicaca -15.80 -69.45"
API="https://api.open-meteo.com/v1/forecast"
VARIABLES="wind_speed_10m,wind_gusts_10m,wind_direction_10m"
FORECAST_HOURS=$(grep -o 'const FORECAST_HOURS = [0-9]*' "$OPEN_METEO" | grep -o '[0-9]*$')
FORECAST_QUARTER_HOURS=$(grep -o 'const FORECAST_QUARTER_HOURS = [0-9]*' "$OPEN_METEO" | grep -o '[0-9]*$')
# Plausible wind speeds in km/h, above the strongest gusts ever measured
MAX_WIND_SPEED=420

# Same request as forecastUrl(), which contains the one of currentWindUrl()
check() {
  local spot=$1 lat=$2 lng=$3
  local url="$API?latitude=$lat&longitude=$lng&current=$VARIABLES&timeformat=unixtime&hourly=$VARIABLES&forecast_hours=$FORECAST_HOURS&minutely_15=$VARIABLES&forecast_minutely_15=$FORECAST_QUARTER_HOURS"
  local body
  if ! body=$(curl -sf --retry 2 -m 60 "$url"); then
    echo "FAIL $spot: HTTP error for $url"
    return 1
  fi
  if ! jq -e "
    def speed: type == \"number\" and . >= 0 and . <= $MAX_WIND_SPEED;
    def direction: type == \"number\" and . >= 0 and . <= 360;
    (.current.wind_speed_10m | speed)
    and (.current.wind_gusts_10m | speed)
    and (.current.wind_direction_10m | direction)
    and (.hourly.time | length == $FORECAST_HOURS)
    and (.hourly.time | all(type == \"number\"))
    and (.hourly.time == (.hourly.time | sort))
    and (.hourly.wind_speed_10m | length == $FORECAST_HOURS and all(speed))
    and (.hourly.wind_gusts_10m | length == $FORECAST_HOURS and all(speed))
    and (.hourly.wind_direction_10m | length == $FORECAST_HOURS and all(direction))
    and (.minutely_15.time | length == $FORECAST_QUARTER_HOURS and all(type == \"number\"))
    and (.minutely_15.wind_speed_10m | length == $FORECAST_QUARTER_HOURS and all(speed))
    and (.minutely_15.wind_gusts_10m | length == $FORECAST_QUARTER_HOURS and all(speed))
    and (.minutely_15.wind_direction_10m | length == $FORECAST_QUARTER_HOURS and all(direction))
  " >/dev/null <<<"$body"; then
    echo "FAIL $spot: unexpected response shape from $url"
    echo "$body" | head -c 500
    echo
    return 1
  fi
  echo "ok   $spot"
}

failures=0
while read -r spot lat lng; do
  check "$spot" "$lat" "$lng" || failures=$((failures + 1))
done <<<"$SPOTS"

echo "$failures spot(s) failed"
exit $((failures > 0))
