import Toybox.Lang;

//! [hour times in seconds since 1970, mean speeds, gust speeds, directions],
//! see Wind for the units
typedef Forecast as [Array<Number>, Array<Float>, Array<Float>, Array<Float>];

const FORECAST_TIMES = 0;
const FORECAST_SPEEDS = 1;
const FORECAST_GUSTS = 2;
const FORECAST_DIRECTIONS = 3;

// The chart starts at the current hour
const FORECAST_HOURS = 48;

(:glance)
const OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast";
(:glance)
const SPEED_KEY = "wind_speed_10m";
(:glance)
const GUST_KEY = "wind_gusts_10m";
(:glance)
const DIRECTION_KEY = "wind_direction_10m";

//! Request of the current wind at the position, for the glance and the
//! closest lake. Unix times are smaller to parse and store than ISO times.
(:glance)
function currentWindUrl(position as [Double, Double]) as String {
    return Lang.format(
        "$1$?latitude=$2$&longitude=$3$&current=$4$,$5$,$6$&timeformat=unixtime",
        [
            OPEN_METEO_URL,
            position[0].format("%.5f"),
            position[1].format("%.5f"),
            SPEED_KEY,
            GUST_KEY,
            DIRECTION_KEY,
        ]
    );
}

//! Request of the current wind and the hourly forecast at the position
function forecastUrl(position as [Double, Double]) as String {
    return Lang.format("$1$&hourly=$2$,$3$,$4$&forecast_hours=$5$", [
        currentWindUrl(position),
        SPEED_KEY,
        GUST_KEY,
        DIRECTION_KEY,
        FORECAST_HOURS,
    ]);
}

//! Current wind of a response, or null when the response lacks it
(:glance)
function currentWind(data as Dictionary) as Wind? {
    var current = data["current"];
    if (current instanceof Lang.Dictionary) {
        var speed = floatOf(current[SPEED_KEY] as Object?);
        var gust = floatOf(current[GUST_KEY] as Object?);
        var direction = floatOf(current[DIRECTION_KEY] as Object?);
        if (speed != null && gust != null && direction != null) {
            return [speed, gust, direction];
        }
    }
    return null;
}

//! Hourly forecast of a response, or null when the response lacks it
function hourlyForecast(data as Dictionary) as Forecast? {
    var hourly = data["hourly"];
    if (hourly instanceof Lang.Dictionary) {
        var times = hourly["time"];
        if (times instanceof Lang.Array && times.size() > 0) {
            var count = times.size();
            var speeds = floatsOf(hourly[SPEED_KEY] as Object?, count);
            var gusts = floatsOf(hourly[GUST_KEY] as Object?, count);
            var directions = floatsOf(hourly[DIRECTION_KEY] as Object?, count);
            if (speeds != null && gusts != null && directions != null) {
                return [times as Array<Number>, speeds, gusts, directions];
            }
        }
    }
    return null;
}

//! The values as Floats, or null when one is missing, as Open-Meteo returns
//! null beyond the end of a weather model
function floatsOf(values as Object?, count as Number) as Array<Float>? {
    if (values instanceof Lang.Array && values.size() == count) {
        var floats = new Array<Float>[count];
        for (var i = 0; i < count; i++) {
            var value = floatOf(values[i] as Object?);
            if (value == null) {
                return null;
            }
            floats[i] = value;
        }
        return floats;
    }
    return null;
}

// Open-Meteo writes whole numbers without decimals, which parse as Number
(:glance)
function floatOf(value as Object?) as Float? {
    if (
        value instanceof Lang.Number ||
        value instanceof Lang.Float ||
        value instanceof Lang.Double
    ) {
        return value.toFloat();
    }
    return null;
}
