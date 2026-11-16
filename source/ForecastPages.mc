import Toybox.Lang;
import Toybox.WatchUi;

// Length of the middle page, which unlike the rest of today still shows
// the wind of tomorrow morning late in the evening
const HOURS_PER_DAY = 24;

//! The forecast pages, in the order DOWN and swiping up go through
enum ForecastPage {
    NEXT_HOURS_PAGE,
    NEXT_DAY_PAGE,
    NEXT_DAYS_PAGE,
    PAGE_COUNT,
}

//! The page that many steps after the page, wrapping around at both ends
function pageAfter(page as ForecastPage, steps as Number) as ForecastPage {
    return ((page + steps + PAGE_COUNT) % PAGE_COUNT) as ForecastPage;
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
        var view = new WindWatchView(page as ForecastPage);
        return [view, new MyBehaviorDelegate(view)];
    }
}

//! Of the [hourly, quarter hourly] forecasts: the next 3 hours in quarter
//! hours, the next 24 or 72 hours in hours. Each page starts at the sample
//! now falls in, as the stored forecasts start at the time of their request.
function pageForecast(
    page as Number,
    forecasts as [Forecast, Forecast],
    now as Number
) as Forecast? {
    switch (page) {
        case NEXT_HOURS_PAGE:
            return upcomingSamples(forecasts[1], now, FORECAST_QUARTER_HOURS);
        case NEXT_DAY_PAGE:
            return upcomingSamples(forecasts[0], now, HOURS_PER_DAY);
    }
    return upcomingSamples(forecasts[0], now, FORECAST_HOURS);
}

function pageTitle(page as Number) as String {
    switch (page) {
        case NEXT_HOURS_PAGE:
            return WatchUi.loadResource(Rez.Strings.NextHours) as String;
        case NEXT_DAY_PAGE:
            return WatchUi.loadResource(Rez.Strings.NextDay) as String;
    }
    return WatchUi.loadResource(Rez.Strings.NextDays) as String;
}

//! Up to count samples of the forecast, from the one now falls in. Null when
//! no sample is after now, as the forecast then lies in the past.
function upcomingSamples(
    forecast as Forecast,
    now as Number,
    count as Number
) as Forecast? {
    var times = forecast[FORECAST_TIMES];
    var size = times.size();
    if (times[size - 1] <= now) {
        return null;
    }
    var first = 0;
    while (times[first + 1] <= now) {
        first++;
    }
    var end = first + count;
    if (end > size) {
        end = size;
    }
    return [
        times.slice(first, end),
        forecast[FORECAST_SPEEDS].slice(first, end),
        forecast[FORECAST_GUSTS].slice(first, end),
        forecast[FORECAST_DIRECTIONS].slice(first, end),
    ];
}
