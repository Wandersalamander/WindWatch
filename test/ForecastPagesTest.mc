import Toybox.Lang;
import Toybox.Test;

(:test)
function pageAfterLastIsFirst(logger as Logger) as Boolean {
    return pageAfter(NEXT_DAYS_PAGE, 1) == NEXT_HOURS_PAGE;
}

(:test)
function pageBeforeFirstIsLast(logger as Logger) as Boolean {
    return pageAfter(NEXT_HOURS_PAGE, -1) == NEXT_DAYS_PAGE;
}

const TEST_HOUR = 60 * 60;

// Samples at 0 h, 1 h, 2 h and 3 h
function fourHours() as Forecast {
    return [
        [0, TEST_HOUR, 2 * TEST_HOUR, 3 * TEST_HOUR],
        [1.0, 2.0, 3.0, 4.0],
        [5.0, 6.0, 7.0, 8.0],
        [90.0, 90.0, 90.0, 90.0],
    ];
}

(:test)
function upcomingSamplesStartAtTheCurrentSample(logger as Logger) as Boolean {
    var upcoming = upcomingSamples(fourHours(), TEST_HOUR + 1, 4) as Forecast;
    return upcoming[FORECAST_TIMES][0] == TEST_HOUR;
}

(:test)
function upcomingSamplesKeepTheGusts(logger as Logger) as Boolean {
    var upcoming = upcomingSamples(fourHours(), TEST_HOUR + 1, 4) as Forecast;
    return upcoming[FORECAST_GUSTS][0] == 6.0;
}

(:test)
function upcomingSamplesStopAtTheCount(logger as Logger) as Boolean {
    var upcoming = upcomingSamples(fourHours(), 0, 2) as Forecast;
    return upcoming[FORECAST_TIMES].size() == 2;
}

(:test)
function upcomingSamplesStopAtTheEnd(logger as Logger) as Boolean {
    var upcoming = upcomingSamples(fourHours(), TEST_HOUR + 1, 9) as Forecast;
    return upcoming[FORECAST_TIMES].size() == 3;
}

(:test)
function upcomingSamplesOfAPastForecastAreNull(logger as Logger) as Boolean {
    return upcomingSamples(fourHours(), 3 * TEST_HOUR, 4) == null;
}

(:test)
function nextHoursPageShowsQuarterHours(logger as Logger) as Boolean {
    var quarterHourly = [
        [0, 900],
        [9.0, 9.0],
        [9.0, 9.0],
        [0.0, 0.0],
    ];
    var forecasts = [fourHours(), quarterHourly as Forecast];
    var shown = pageForecast(NEXT_HOURS_PAGE, forecasts, 0) as Forecast;
    return shown[FORECAST_SPEEDS][0] == 9.0;
}

(:test)
function nextDaysPageShowsAllHours(logger as Logger) as Boolean {
    var forecasts = [fourHours(), fourHours()];
    var shown = pageForecast(NEXT_DAYS_PAGE, forecasts, 0) as Forecast;
    return shown[FORECAST_TIMES].size() == 4;
}
