using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;
using Toybox.Time;
using Toybox.Application.Storage;

// Vertical centers of the lake name, the color bar and the wind, as fractions
// of the glance height
(:glance)
const GLANCE_NAME_ROW = 0.2;
(:glance)
const GLANCE_WIND_ROW = 0.8;

// The lake name takes the top row instead of a fixed title, as narrow glances
// would otherwise cut it to a few letters
(:glance)
class WidgetGlanceView extends Ui.GlanceView {
    function initialize() {
        GlanceView.initialize();
        makeRequest(false);
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
            0,
            GLANCE_NAME_ROW * dc.getHeight(),
            Graphics.FONT_GLANCE,
            fitText(
                dc,
                readableLakeName(getFavouriteLake()),
                Graphics.FONT_GLANCE,
                dc.getWidth()
            ),
            Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_LEFT
        );
        drawColorBar(dc);
        var wind = getFavouriteWind();
        if (wind != null) {
            drawWind(dc, wind);
        }
    }

    // The arrow takes a square of the font height in front of the text
    private function drawWind(dc as Gfx.Dc, wind as Wind) as Void {
        var center = GLANCE_WIND_ROW * dc.getHeight();
        var arrowSpace = dc.getFontHeight(Graphics.FONT_GLANCE);
        drawWindArrow(
            dc,
            arrowSpace / 2.0,
            center,
            ARROW_SIZE_RATIO * arrowSpace,
            wind[WIND_DIRECTION]
        );
        dc.drawText(
            arrowSpace,
            center,
            Graphics.FONT_GLANCE,
            fitText(
                dc,
                formatWind(wind, speedUnit()),
                Graphics.FONT_GLANCE,
                dc.getWidth() - arrowSpace
            ),
            Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    //! Make the web request
    public function makeRequest(forceUpdate as Boolean) as Void {
        System.println("Executing\nRequest");
        var lastUpdate = getGlanceLastUpdate();
        var readyForUpdate = true;
        if (lastUpdate != null) {
            // Open-Meteo updates the current wind every 15 minutes
            var skipUpdateBelowSeconds = new Time.Duration(15 * 60);
            readyForUpdate = Time.now().greaterThan(
                lastUpdate.add(skipUpdateBelowSeconds)
            );
        }
        if (forceUpdate) {
            readyForUpdate = true;
        }
        if (readyForUpdate == false) {
            return;
        }
        var options = {
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
            :context => getFavouriteLake(),
        };
        var myRequest = currentWindUrl(getFavouritePosition());
        System.println(myRequest);
        Communications.makeWebRequest(
            myRequest,
            null,
            options,
            method(:onReceive)
        );
    }

    function drawColorBar(dc as Gfx.Dc) as Void {
        var bands = bandCount();
        var totalWidth = dc.getWidth();
        var barWidth = totalWidth / bands.toFloat();
        var delta = 1.0;
        var height = dc.getHeight() * 0.1;
        var heightHighlight = dc.getHeight() * 0.15;
        var heightMarker = dc.getHeight() * 0.25;
        var widthMarker = barWidth / 8.0;
        var center = dc.getHeight() / 2.0;

        // draw in background
        for (var i = 0; i < bands; i++) {
            dc.setColor(getColorByIdx(i), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(
                i * barWidth + delta,
                center - height / 2.0,
                barWidth - 2 * delta,
                height
            );
        }
        var wind = getFavouriteWind();
        if (wind != null) {
            var speed = wind[WIND_SPEED];
            // keeps the marker on screen at the right end of the bar
            var markerX = getColorPos(speed) * (totalWidth - widthMarker);
            var band = bandOf(speed);
            // draw in foreground
            dc.setColor(getColorByIdx(band), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(
                band * barWidth + delta,
                center - heightHighlight / 2.0,
                barWidth - 2 * delta,
                heightHighlight
            );
            // draw wind speed marker
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(
                markerX - delta,
                center - heightMarker / 2.0,
                widthMarker + 2 * delta,
                heightMarker
            );
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(
                markerX,
                center - heightMarker / 2,
                widthMarker,
                heightMarker
            );
        }
    }

    //! Receive the data from the web request
    //! @param responseCode The server response code
    //! @param data Content from a successful request
    //! @param requestedLake The lake the request was made for
    public function onReceive(
        responseCode as Number,
        data as Dictionary or String or Null,
        requestedLake as Object
    ) as Void {
        System.println(responseCode);
        // The favourite may have changed while the request was in flight
        if (requestedLake.equals(getFavouriteLake()) == false) {
            return;
        }
        if (responseCode == 200 && data instanceof Dictionary) {
            var wind = currentWind(data);
            if (wind != null) {
                setFavouriteWind(wind);
                setGlanceLastUpdate();
            }
        }
        requestUpdate();
    }
}
