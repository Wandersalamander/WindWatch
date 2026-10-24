#!/usr/bin/env bash
# Verifies the live Open-Meteo API still returns what currentWind() and
# hourlyForecast() in source/OpenMeteo.mc expect, at the center of every lake
# of the lake list. New lakes are covered automatically.
set -uo pipefail

LAKE_CHOICES="$(dirname "$0")/../resources/jsonData/lakeChoices.json"
OPEN_METEO="$(dirname "$0")/../source/OpenMeteo.mc"
API="https://api.open-meteo.com/v1/forecast"
VARIABLES="wind_speed_10m,wind_gusts_10m,wind_direction_10m"
FORECAST_HOURS=$(grep -o 'const FORECAST_HOURS = [0-9]*' "$OPEN_METEO" | grep -o '[0-9]*$')
# Plausible wind speeds in km/h, the strongest gust measured in Switzerland is 268 km/h
MAX_WIND_SPEED=300

lake_positions=$(jq -r '.[] | "\(.[0]) \(.[1]) \(.[2])"' "$LAKE_CHOICES" | tr -d '\r')
if [[ -z $lake_positions ]]; then
  echo "FAIL: no lakes found in $LAKE_CHOICES"
  exit 1
fi

# Same request as forecastUrl(), which contains the one of currentWindUrl()
check() {
  local lake=$1 lat=$2 lng=$3
  local url="$API?latitude=$lat&longitude=$lng&current=$VARIABLES&timeformat=unixtime&hourly=$VARIABLES&forecast_hours=$FORECAST_HOURS"
  local body
  if ! body=$(curl -sf --retry 2 -m 60 "$url"); then
    echo "FAIL $lake: HTTP error for $url"
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
  " >/dev/null <<<"$body"; then
    echo "FAIL $lake: unexpected response shape from $url"
    echo "$body" | head -c 500
    echo
    return 1
  fi
  echo "ok   $lake"
}

failures=0
while read -r lake lat lng; do
  check "$lake" "$lat" "$lng" || failures=$((failures + 1))
done <<<"$lake_positions"

echo "$failures lake(s) failed"
exit $((failures > 0))
