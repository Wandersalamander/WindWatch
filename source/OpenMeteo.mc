import Toybox.Lang;
import Toybox.Time;

//! [sample times in seconds since 1970, mean speeds, gust speeds,
//! directions], see Wind for the units
typedef Forecast as [Array<Number>, Array<Float>, Array<Float>, Array<Float>];

const FORECAST_TIMES = 0;
const FORECAST_SPEEDS = 1;
const FORECAST_GUSTS = 2;
const FORECAST_DIRECTIONS = 3;

// Both forecasts start at the current hour or quarter hour
const FORECAST_HOURS = 72;
const FORECAST_QUARTER_HOURS = 12;

const HOURLY_KEY = "hourly";
const QUARTER_HOURLY_KEY = "minutely_15";

// Open-Meteo updates the current wind every 15 minutes, so asking more often
// only loads its free servers
(:glance)
const REQUEST_INTERVAL = 15 * 60;

// Data that missed a refresh, as the watch was offline or the request
// failed, no longer passes for the current wind
(:glance)
const OUTDATED_AFTER = 2 * REQUEST_INTERVAL;

//! Whether data requested at lastUpdate is old enough to request it again
(:glance)
function isDue(lastUpdate as Time.Moment?) as Boolean {
    return isOlderThan(lastUpdate, REQUEST_INTERVAL);
}

//! Whether data requested at lastUpdate missed its refresh
(:glance)
function isOutdated(lastUpdate as Time.Moment?) as Boolean {
    return isOlderThan(lastUpdate, OUTDATED_AFTER);
}

(:glance)
function isOlderThan(lastUpdate as Time.Moment?, seconds as Number) as Boolean {
    if (lastUpdate == null) {
        return true;
    }
    var age = new Time.Duration(seconds);
    return Time.now().greaterThan(lastUpdate.add(age));
}

(:glance)
const OPEN_METEO_URL = "https://api.open-meteo.com/v1/forecast";
(:glance)
const SPEED_KEY = "wind_speed_10m";
(:glance)
const GUST_KEY = "wind_gusts_10m";
(:glance)
const DIRECTION_KEY = "wind_direction_10m";

//! Request of the current wind at the position, for the glance.
//! Unix times are smaller to parse and store than ISO times.
(:glance)
function currentWindUrl(position as [Double, Double]) as String {
    return Lang.format("$1$?$2$&current=$3$,$4$,$5$&timeformat=unixtime", [
        OPEN_METEO_URL,
        positionKey(position),
        SPEED_KEY,
        GUST_KEY,
        DIRECTION_KEY,
    ]);
}

//! Request of the current wind and the hourly and quarter hourly forecasts
//! at the position
function forecastUrl(position as [Double, Double]) as String {
    var variables = Lang.format("$1$,$2$,$3$", [
        SPEED_KEY,
        GUST_KEY,
        DIRECTION_KEY,
    ]);
    return Lang.format(
        "$1$&$2$=$3$&forecast_hours=$4$&$5$=$3$&forecast_minutely_15=$6$",
        [
            currentWindUrl(position),
            HOURLY_KEY,
            variables,
            FORECAST_HOURS,
            QUARTER_HOURLY_KEY,
            FORECAST_QUARTER_HOURS,
        ]
    );
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

function hourlyForecast(data as Dictionary) as Forecast? {
    return forecastOf(data[HOURLY_KEY] as Object?);
}

function quarterHourlyForecast(data as Dictionary) as Forecast? {
    return forecastOf(data[QUARTER_HOURLY_KEY] as Object?);
}

//! Forecast of one series of a response, or null when the response lacks it
function forecastOf(series as Object?) as Forecast? {
    if (series instanceof Lang.Dictionary) {
        var times = series["time"];
        if (times instanceof Lang.Array && times.size() > 0) {
            var count = times.size();
            var speeds = floatsOf(series[SPEED_KEY] as Object?, count);
            var gusts = floatsOf(series[GUST_KEY] as Object?, count);
            var directions = floatsOf(series[DIRECTION_KEY] as Object?, count);
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
