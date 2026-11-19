import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Graphics as Gfx;
import Toybox.Lang;
using Toybox.System;
import Toybox.Position;
import Toybox.Time;

// Fraction of the screen height taken by the wind and the chart below it,
// centered, where round screens are widest
const CONTENT_HEIGHT_RATIO = 0.7;
// Fraction of the screen height between the wind and the chart
const CHART_GAP_RATIO = 0.02;

//! The current wind and one forecast page, for the favourite or, in GPS
//! mode, for where the watch is
class WindWatchView extends WatchUi.View {
    private var _page as ForecastPage;
    // Position key of the last request, answered or not
    private var _requestedKey as String?;

    function initialize(page as ForecastPage) {
        View.initialize();
        _page = page;
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    //! Also called when the menu closes, which may have changed the position
    function onShow() as Void {
        followGps();
        requestIfOutdated();
        WatchUi.requestUpdate();
        promptForFavourite();
    }

    //! Opens the menu once, as new users miss it behind START and would
    //! only see the wind at the default favourite
    private function promptForFavourite() as Void {
        if (hasFavourite() || hasShownFavouritePrompt()) {
            return;
        }
        setFavouritePromptShown();
        showMenu(self);
    }

    //! Moves that many forecast pages on, wrapping around at both ends
    function showPage(steps as Number) as Void {
        _page = pageAfter(_page, steps);
        WatchUi.requestUpdate();
    }

    //! Asks for new data now, as Reload in the menu does
    function reload() as Void {
        request();
    }

    // GPS only runs in GPS mode. Starting from the last known position shows
    // nearby wind before the first fix of this session.
    private function followGps() as Void {
        if (getShowsGps()) {
            var lastKnown = getPosition();
            if (lastKnown != null) {
                setGpsPosition(lastKnown);
            }
            Position.enableLocationEvents(
                Position.LOCATION_CONTINUOUS,
                method(:onPosition)
            );
        } else {
            Position.enableLocationEvents(
                Position.LOCATION_DISABLE,
                method(:onPosition)
            );
        }
    }

    function onPosition(info as Position.Info) as Void {
        var position = info.position;
        if (position != null) {
            setGpsPosition(position.toDegrees());
            // GPS fixes come every second, faster than an answer or a retry
            // makes sense, so only a new rounded position asks again
            var key = positionKey(shownPosition());
            if (key.equals(_requestedKey)) {
                return;
            }
            requestIfOutdated();
            WatchUi.requestUpdate();
        }
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
        var key = positionKey(shownPosition());
        var height = dc.getHeight();
        var windTop = (height * (1 - CONTENT_HEIGHT_RATIO)) / 2;
        var chartTop = belowSubscreen(
            windTop +
                dc.getFontHeight(LARGE_TEXT_FONT) +
                CHART_GAP_RATIO * height
        );
        var chartBottom = contentBottom(dc, windTop);

        drawWind(dc, windTop, getWindFor(key));
        drawForecast(dc, chartTop, chartBottom, getForecastsFor(key));
    }

    private function drawWind(dc as Dc, top as Float, wind as Wind?) as Void {
        if (wind == null) {
            return;
        }
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        drawWindLine(dc, top, LARGE_TEXT_FONT, wind);
        var subscreen = subscreenArea();
        if (subscreen != null) {
            // Only the mean speed, gusts and unit do not fit the subscreen
            drawInSubscreen(
                dc,
                subscreen,
                speedIn(wind[WIND_SPEED], speedUnit()).format("%.0f")
            );
        }
    }

    private function drawForecast(
        dc as Dc,
        top as Float,
        bottom as Float,
        forecasts as [Forecast, Forecast]?
    ) as Void {
        if (forecasts == null) {
            return;
        }
        var forecast = pageForecast(_page, forecasts, Time.now().value());
        if (forecast == null) {
            return;
        }
        var chart = new ForecastChart(dc, top, bottom, pageTitle(_page));
        chart.draw(dc, forecast);
    }

    //! Requests the current wind and the forecasts of the shown position,
    //! unless they are stored and recent
    private function requestIfOutdated() as Void {
        if (needsRequest(FORECASTS, positionKey(shownPosition()))) {
            request();
        }
    }

    private function request() as Void {
        var position = shownPosition();
        var key = positionKey(position);
        _requestedKey = key;
        System.println(forecastUrl(position));
        (new PositionRequest(key, method(:onReceive))).start(
            forecastUrl(position)
        );
    }

    //! Receive the data from the web request
    //! @param responseCode The server response code
    //! @param data Content from a successful request
    //! @param key The position key the request was made for
    public function onReceive(
        responseCode as Number,
        data as Dictionary or String or Null,
        key as String
    ) as Void {
        System.println("WindWatchView.onReceive " + responseCode.toString());
        if (responseCode == 200 && data instanceof Dictionary) {
            var wind = currentWind(data);
            var forecast = hourlyForecast(data);
            var quarterHourForecast = quarterHourlyForecast(data);
            if (
                wind != null &&
                forecast != null &&
                quarterHourForecast != null
            ) {
                // Also spares the glance its own request
                storeFor(WIND, wind, key);
                storeFor(FORECASTS, [forecast, quarterHourForecast], key);
                WatchUi.requestUpdate();
            }
        }
    }
}
