import Toybox.Graphics;
import Toybox.WatchUi;
using Toybox.Graphics as Gfx;
import Toybox.Lang;
import Toybox.Communications;
using Toybox.System;
using Toybox.Time;
import Toybox.Position;

// Fractions of the screen height kept clear at the top and bottom edge. Round
// screens narrow quickly towards the bottom, where the text lines are long.
const EDGE_MARGIN_RATIO = 0.05;
const ROUND_BOTTOM_MARGIN_RATIO = 0.1;
// Fraction of the screen height between the text and the chart
const CHART_GAP_RATIO = 0.02;

class LakeWindView extends WatchUi.View {
    function initialize() {
        System.println("LakeWindView.initialize");
        View.initialize();
        tryUpdateCurrentPosition();
        makeRequest(true, true);
    }

    function tryUpdateCurrentPosition() as Void {
        System.println("LakeWindView.tryUpdateCurrentPosition");
        var newPos = getPosition();
        var newLake = closestLake(newPos);
        if (newPos != null and newLake != null) {
            setCurrentPosition(newPos);
            setCurrentDistance(newLake[1]);
            var isSameLake = newLake[0].equals(getCurrentLake());
            if (isSameLake) {
                return;
            }
            setCurrentLake(newLake[0]);
            // The previous lake's wind must not show under the new name
            clearCurrentWind();
            makeRequestProx(true);
        }
    }

    function notifyFullUpdate() as Void {
        tryUpdateCurrentPosition();
        System.println("LakeWindView.notifyFavUpdate");
        makeRequest(true, true);
    }

    function onLayout(dc as Dc) as Void {
        System.println("LakeWindView.onLayout");
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        tryUpdateCurrentPosition();
        System.println("LakeWindView.onUpdate");
        View.onUpdate(dc);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);

        var topMargin = EDGE_MARGIN_RATIO * dc.getHeight();
        var bottomMarginRatio = isRoundScreen()
            ? ROUND_BOTTOM_MARGIN_RATIO
            : EDGE_MARGIN_RATIO;
        var bottomMargin = bottomMarginRatio * dc.getHeight();
        var chartGap = CHART_GAP_RATIO * dc.getHeight();
        var chartTop =
            topMargin + 2 * dc.getFontHeight(LARGE_TEXT_FONT) + chartGap;
        var closestLakeTop =
            dc.getHeight() -
            bottomMargin -
            2 * dc.getFontHeight(SMALL_TEXT_FONT);

        drawFavouriteLake(dc, topMargin);
        drawForecast(dc, chartTop, closestLakeTop - chartGap);
        drawClosestLake(dc, closestLakeTop);
    }

    private function drawFavouriteLake(dc as Dc, top as Float) as Void {
        var subscreen = subscreenArea();
        if (subscreen != null) {
            drawFavouriteLakeBesideSubscreen(dc, top, subscreen);
            return;
        }
        var favouriteWind = getFavouriteWind();
        if (favouriteWind != null) {
            drawWindLine(dc, top, LARGE_TEXT_FONT, favouriteWind);
        }
        drawFittedLine(
            dc,
            top + dc.getFontHeight(LARGE_TEXT_FONT),
            LARGE_TEXT_FONT,
            readableLakeName(getFavouriteLake())
        );
    }

    // The subscreen highlights the speed, the name wraps left of it
    private function drawFavouriteLakeBesideSubscreen(
        dc as Dc,
        top as Float,
        subscreen as BoundingBox
    ) as Void {
        var favouriteWind = getFavouriteWind();
        if (favouriteWind != null) {
            // Only the mean speed, gusts and unit do not fit the subscreen
            drawInSubscreen(
                dc,
                subscreen,
                favouriteWind[WIND_SPEED].format("%.0f")
            );
        }
        var nameHeight = 2 * dc.getFontHeight(LARGE_TEXT_FONT);
        var span = visibleSpan(dc, top, top + nameHeight);
        // fitTextToArea needs some slack to allow the second line
        var name = Graphics.fitTextToArea(
            readableLakeName(getFavouriteLake()),
            LARGE_TEXT_FONT,
            span[1] - span[0],
            nameHeight + dc.getFontHeight(LARGE_TEXT_FONT) / 2,
            true
        );
        if (name != null) {
            dc.drawText(
                (span[0] + span[1]) / 2.0,
                top,
                LARGE_TEXT_FONT,
                name,
                Graphics.TEXT_JUSTIFY_CENTER
            );
        }
    }

    private function drawForecast(
        dc as Dc,
        top as Float,
        bottom as Float
    ) as Void {
        var forecast = getFavouriteForecast();
        if (forecast != null) {
            (new ForecastChart(dc, top, bottom)).draw(dc, forecast);
        }
    }

    private function drawClosestLake(dc as Dc, top as Float) as Void {
        var lineHeight = dc.getFontHeight(SMALL_TEXT_FONT);
        drawFittedLine(dc, top, SMALL_TEXT_FONT, closestLakeLabel());
        var currentLake = getCurrentLake();
        if (currentLake == null) {
            return;
        }
        var currentWind = getCurrentWind();
        var lakeName = readableLakeName(currentLake);
        if (currentWind == null) {
            drawFittedLine(dc, top + lineHeight, SMALL_TEXT_FONT, lakeName);
        } else {
            drawLakeWindLine(
                dc,
                top + lineHeight,
                SMALL_TEXT_FONT,
                lakeName,
                currentWind
            );
        }
    }

    private function closestLakeLabel() as String {
        var closestLake =
            WatchUi.loadResource(Rez.Strings.ClosestLake) as String;
        var currentDistance = getCurrentDistance();
        if (currentDistance == null) {
            return closestLake;
        }
        if (currentDistance >= 1000) {
            return Lang.format("$1$ ($2$km)", [
                closestLake,
                (currentDistance / 1000.0).format("%d"),
            ]);
        }
        return Lang.format("$1$ ($2$m)", [
            closestLake,
            currentDistance.format("%d"),
        ]);
    }

    public function makeRequest(
        forceFav as Boolean,
        forceProx as Boolean
    ) as Void {
        System.println("LakeWindView.makeRequest");
        makeRequestFav(forceFav);
        makeRequestProx(forceProx);
    }

    public function makeRequestFav(forceFav as Boolean) as Void {
        System.println("LakeWindView.makeRequestFav");
        var skipUpdateBelowSeconds = new Time.Duration(60 * 60); // 60 min
        var readyForUpdateFav = true;
        var lastUpdateFav = getLastUpdateFav();
        if (lastUpdateFav != null) {
            readyForUpdateFav = Time.now().greaterThan(
                lastUpdateFav.add(skipUpdateBelowSeconds)
            );
        }
        if (forceFav) {
            readyForUpdateFav = true;
        }

        if (readyForUpdateFav) {
            var myRequestFav = forecastUrl(getFavouritePosition());
            System.println(myRequestFav);
            Communications.makeWebRequest(
                myRequestFav,
                null,
                {
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
                    // Drops answers for a lake that is no longer shown
                    :context => getFavouriteLake(),
                },
                method(:onReceiveFav)
            );
        }
    }

    public function makeRequestProx(forceProx as Boolean) as Void {
        System.println("LakeWindView.makeRequestProx");
        var skipUpdateBelowSeconds2 = new Time.Duration(15 * 60); // 15 min
        var readyForUpdateProx = true;
        var lastUpdateProx = getLastUpdateProx();
        if (lastUpdateProx != null) {
            readyForUpdateProx = Time.now().greaterThan(
                lastUpdateProx.add(skipUpdateBelowSeconds2)
            );
        }
        if (getCurrentWind() == null) {
            readyForUpdateProx = true;
        }
        if (forceProx) {
            readyForUpdateProx = true;
        }

        var currentLake = getCurrentLake();
        var currentPosition = getCurrentPosition();
        if (
            currentLake != null &&
            currentPosition != null &&
            readyForUpdateProx
        ) {
            var myRequestProx = currentWindUrl(currentPosition);
            System.println(myRequestProx);
            Communications.makeWebRequest(
                myRequestProx,
                null,
                {
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
                    // Drops answers for a lake that is no longer shown
                    :context => currentLake,
                },
                method(:onReceiveProx)
            );
        }
    }

    //! Receive the data from the web request
    //! @param responseCode The server response code
    //! @param data Content from a successful request
    //! @param requestedLake The lake the request was made for
    public function onReceiveFav(
        responseCode as Number,
        data as Dictionary or String or Null,
        requestedLake as Object
    ) as Void {
        System.println("LakeWindView.onReceiveFav");
        System.println(responseCode);
        // The favourite may have changed while the request was in flight
        if (requestedLake.equals(getFavouriteLake()) == false) {
            return;
        }
        if (responseCode == 200 && data instanceof Dictionary) {
            var wind = currentWind(data);
            var forecast = hourlyForecast(data);
            if (wind != null && forecast != null) {
                // The glance shows the same current wind
                setFavouriteWind(wind);
                setFavouriteForecast(forecast);
                setLastUpdateFav();
                requestUpdate();
            }
        } else {
            System.println("Failed to load, error " + responseCode.toString());
        }
    }

    public function onReceiveProx(
        responseCode as Number,
        data as Dictionary or String or Null,
        requestedLake as Object
    ) as Void {
        System.println("LakeWindView.onReceiveProx");
        System.println(responseCode);
        // The closest lake may have changed while the request was in flight
        if (requestedLake.equals(getCurrentLake()) == false) {
            return;
        }
        if (responseCode == 200 && data instanceof Dictionary) {
            var wind = currentWind(data);
            if (wind != null) {
                setCurrentWind(wind);
                setLastUpdateProx();
                requestUpdate();
            }
        } else {
            System.println("Failed to load, error " + responseCode.toString());
        }
    }
}
