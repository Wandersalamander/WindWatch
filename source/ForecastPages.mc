import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

//! The forecast pages, in the order DOWN and swiping up go through
enum ForecastPage {
    NEXT_HOURS_PAGE,
    TODAY_PAGE,
    NEXT_DAYS_PAGE,
    PAGE_COUNT,
}

//! The pages in the watch's own page loop, which also shows where you are
//! and slides between them
class ForecastPageFactory extends WatchUi.ViewLoopFactory {
    function initialize() {
        ViewLoopFactory.initialize();
    }

    function getSize() as Number {
        return PAGE_COUNT;
    }

    function getView(
        page as Number
    ) as [ViewLoopFactory.Views] or
        [ViewLoopFactory.Views, ViewLoopFactory.Delegates] {
        var view = new LakeWindView(page as ForecastPage);
        return [view, new MyBehaviorDelegate(view)];
    }
}

//! Of the [hourly, quarter hourly] forecasts: the next 3 hours in quarter
//! hours, the rest of today or the next 3 days in hours
function pageForecast(
    page as Number,
    forecasts as [Forecast, Forecast]
) as Forecast {
    switch (page) {
        case NEXT_HOURS_PAGE:
            return forecasts[1];
        case TODAY_PAGE:
            return forecastUntilEndOfDay(forecasts[0]);
    }
    return forecasts[0];
}

function pageTitle(page as Number) as String {
    switch (page) {
        case NEXT_HOURS_PAGE:
            return WatchUi.loadResource(Rez.Strings.NextHours) as String;
        case TODAY_PAGE:
            return WatchUi.loadResource(Rez.Strings.Today) as String;
    }
    return WatchUi.loadResource(Rez.Strings.NextDays) as String;
}

//! The samples of the forecast on the local day of its first sample
function forecastUntilEndOfDay(forecast as Forecast) as Forecast {
    var times = forecast[FORECAST_TIMES];
    var firstDay = localDay(times[0]);
    var count = 1;
    while (count < times.size() && localDay(times[count]) == firstDay) {
        count++;
    }
    return [
        times.slice(0, count),
        forecast[FORECAST_SPEEDS].slice(0, count),
        forecast[FORECAST_GUSTS].slice(0, count),
        forecast[FORECAST_DIRECTIONS].slice(0, count),
    ];
}

function localDay(time as Number) as Number {
    return Gregorian.info(new Time.Moment(time), Time.FORMAT_SHORT).day;
}
