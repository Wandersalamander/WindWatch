using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
import Toybox.Communications;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System;

// Vertical centers of the wind and the color bar, as fractions of the
// glance height
(:glance)
const GLANCE_WIND_ROW = 0.3;
(:glance)
const GLANCE_BAR_ROW = 0.72;

//! The current wind and its place on the color bar, for the shown position.
//! In GPS mode that is the last fix the view got, as glances get no GPS.
(:glance)
class WidgetGlanceView extends Ui.GlanceView {
    function initialize() {
        GlanceView.initialize();
        makeRequest();
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        var wind = getWindFor(positionKey(shownPosition()));
        drawColorBar(dc, wind);
        if (wind != null) {
            drawWind(dc, wind);
        }
    }

    // The arrow takes a square of the font height in front of the text
    private function drawWind(dc as Gfx.Dc, wind as Wind) as Void {
        var center = GLANCE_WIND_ROW * dc.getHeight();
        var arrowSpace = dc.getFontHeight(Graphics.FONT_GLANCE);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
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

    //! Requests the current wind unless it is stored and recent
    public function makeRequest() as Void {
        var position = shownPosition();
        var key = positionKey(position);
        if (needsRequest(WIND, key)) {
            System.println(currentWindUrl(position));
            Communications.makeWebRequest(
                currentWindUrl(position),
                null,
                {
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON,
                    :context => key,
                },
                method(:onReceive)
            );
        }
    }

    function drawColorBar(dc as Gfx.Dc, wind as Wind?) as Void {
        var bands = bandCount();
        var totalWidth = dc.getWidth();
        var barWidth = totalWidth / bands.toFloat();
        var delta = 1.0;
        var height = dc.getHeight() * 0.1;
        var heightHighlight = dc.getHeight() * 0.15;
        var heightMarker = dc.getHeight() * 0.25;
        var widthMarker = barWidth / 8.0;
        var center = GLANCE_BAR_ROW * dc.getHeight();

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
    //! @param requestedKey The position key the request was made for
    public function onReceive(
        responseCode as Number,
        data as Dictionary or String or Null,
        requestedKey as Object
    ) as Void {
        System.println(responseCode);
        if (responseCode == 200 && data instanceof Dictionary) {
            var wind = currentWind(data);
            if (wind != null) {
                storeFor(WIND, wind, requestedKey as String);
            }
        }
        requestUpdate();
    }
}
