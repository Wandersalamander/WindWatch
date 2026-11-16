import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;

// 22h, 23h, then 0h and 1h of tomorrow, in local time
function forecastAroundMidnight() as Forecast {
    var midnight = Time.today().value();
    var hour = 60 * 60;
    return [
        [
            midnight + 22 * hour,
            midnight + 23 * hour,
            midnight + 24 * hour,
            midnight + 25 * hour,
        ],
        [1.0, 2.0, 3.0, 4.0],
        [5.0, 6.0, 7.0, 8.0],
        [90.0, 90.0, 90.0, 90.0],
    ];
}

(:test)
function forecastUntilEndOfDayStopsAtMidnight(logger as Logger) as Boolean {
    var today = forecastUntilEndOfDay(forecastAroundMidnight()) as Forecast;
    return today[FORECAST_TIMES].size() == 2;
}

(:test)
function forecastUntilEndOfDayKeepsTheGusts(logger as Logger) as Boolean {
    var today = forecastUntilEndOfDay(forecastAroundMidnight()) as Forecast;
    return today[FORECAST_GUSTS][1] == 6.0;
}

(:test)
function nextHoursPageShowsQuarterHours(logger as Logger) as Boolean {
    var hourly = forecastAroundMidnight();
    var quarterHourly = [[0], [9.0], [9.0], [0.0]] as Forecast;
    var shown = pageForecast(NEXT_HOURS_PAGE, [hourly, quarterHourly]);
    return shown[FORECAST_SPEEDS][0] == 9.0;
}

(:test)
function nextDaysPageShowsAllHours(logger as Logger) as Boolean {
    var hourly = forecastAroundMidnight();
    var shown = pageForecast(NEXT_DAYS_PAGE, [hourly, hourly]);
    return shown[FORECAST_TIMES].size() == 4;
}
