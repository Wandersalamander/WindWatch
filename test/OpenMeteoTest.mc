import Toybox.Lang;
import Toybox.Test;

// Trimmed real response from api.open-meteo.com (2026-10-24)
function sampleResponse() as Dictionary {
    return {
        "current" => {
            "time" => 1792836900,
            "interval" => 900,
            "wind_speed_10m" => 13.7,
            "wind_gusts_10m" => 31.7,
            "wind_direction_10m" => 215,
        },
        "hourly" => {
            "time" => [1792836000, 1792839600],
            "wind_speed_10m" => [14.2, 12],
            "wind_gusts_10m" => [30.2, 31.7],
            "wind_direction_10m" => [214, 220],
        },
    };
}

(:test)
function currentWindUrlAsksForWindInUnixTime(logger as Logger) as Boolean {
    return currentWindUrl([46.5d, 6.25d]).equals(
        "https://api.open-meteo.com/v1/forecast?latitude=46.50000&longitude=6.25000&current=wind_speed_10m,wind_gusts_10m,wind_direction_10m&timeformat=unixtime"
    );
}

(:test)
function forecastUrlAsksForHourlyWind(logger as Logger) as Boolean {
    var url = forecastUrl([46.287075d, 6.16961d]);
    return url.find(
        "&hourly=wind_speed_10m,wind_gusts_10m,wind_direction_10m&forecast_hours=48"
    ) != null;
}

(:test)
function currentWindReadsDirectionAsFloat(logger as Logger) as Boolean {
    return (currentWind(sampleResponse()) as Wind)[WIND_DIRECTION] == 215.0;
}

(:test)
function currentWindReadsGust(logger as Logger) as Boolean {
    return (currentWind(sampleResponse()) as Wind)[WIND_GUST] == 31.7f;
}

(:test)
function currentWindWithoutCurrentIsNull(logger as Logger) as Boolean {
    return currentWind({ "hourly" => {} }) == null;
}

(:test)
function forecastReadsWholeSpeedAsFloat(logger as Logger) as Boolean {
    var forecast = hourlyForecast(sampleResponse()) as Forecast;
    return forecast[FORECAST_SPEEDS][1] == 12.0;
}

(:test)
function forecastKeepsUnixTimes(logger as Logger) as Boolean {
    var forecast = hourlyForecast(sampleResponse()) as Forecast;
    return forecast[FORECAST_TIMES][0] == 1792836000;
}

(:test)
function forecastWithMissingValueIsNull(logger as Logger) as Boolean {
    var response = sampleResponse();
    var hourly = response["hourly"] as Dictionary;
    hourly["wind_gusts_10m"] = [30.2, null];
    return hourlyForecast(response) == null;
}

(:test)
function forecastWithShorterSeriesIsNull(logger as Logger) as Boolean {
    var response = sampleResponse();
    var hourly = response["hourly"] as Dictionary;
    hourly["wind_direction_10m"] = [214];
    return hourlyForecast(response) == null;
}

(:test)
function forecastWithoutHourlyIsNull(logger as Logger) as Boolean {
    return hourlyForecast({ "current" => {} }) == null;
}
