using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
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
    // Read only when they may change, as the glance list redraws every
    // glance on each frame while it scrolls, and the storage is slow
    private var _wind as Wind? = null;
    private var _windText as String = "";
    private var _mark as DataMark? = null;

    function initialize() {
        GlanceView.initialize();
        makeRequest();
    }

    function onShow() as Void {
        readShownWind();
    }

    //! The last known wind shows offline too, marked when it is not the
    //! current one at the shown position
    private function readShownWind() as Void {
        var wind = getLastWind();
        _wind = wind;
        if (wind != null) {
            _windText = formatWind(wind, speedUnit(), windFormat());
        }
        _mark = dataMarkFor(WIND, positionKey(shownPosition()));
    }

    function onUpdate(dc as Gfx.Dc) as Void {
        var wind = _wind;
        drawColorBar(dc, wind);
        if (wind == null) {
            return;
        }
        drawWind(dc, wind);
    }

    // The arrow takes a square of the font height in front of the text, and
    // the mark one behind it
    private function drawWind(dc as Gfx.Dc, wind as Wind) as Void {
        var mark = _mark;
        var center = GLANCE_WIND_ROW * dc.getHeight();
        var symbolSpace = dc.getFontHeight(Graphics.FONT_GLANCE);
        var symbolSize = ARROW_SIZE_RATIO * symbolSpace;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        drawWindArrow(
            dc,
            symbolSpace / 2.0,
            center,
            symbolSize,
            wind[WIND_DIRECTION]
        );
        var text = fitText(
            dc,
            _windText,
            Graphics.FONT_GLANCE,
            dc.getWidth() - symbolSpace - markWidth(mark, symbolSpace)
        );
        dc.drawText(
            symbolSpace,
            center,
            Graphics.FONT_GLANCE,
            text,
            Graphics.TEXT_JUSTIFY_VCENTER | Graphics.TEXT_JUSTIFY_LEFT
        );
        if (mark != null) {
            var textWidth = dc.getTextWidthInPixels(text, Graphics.FONT_GLANCE);
            var textRight = symbolSpace + textWidth;
            mark.draw(dc, textRight + symbolSpace / 2.0, center, symbolSize);
        }
    }

    //! Requests the current wind unless it is stored and recent
    public function makeRequest() as Void {
        var position = shownPosition();
        var key = positionKey(position);
        if (needsRequest(WIND, key)) {
            System.println(currentWindUrl(position));
            (new PositionRequest(key, method(:onReceive))).start(
                currentWindUrl(position)
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
    //! @param key The position key the request was made for
    public function onReceive(
        responseCode as Number,
        data as Dictionary or String or Null,
        key as String
    ) as Void {
        System.println(responseCode);
        if (responseCode == 200 && data instanceof Dictionary) {
            var wind = currentWind(data);
            if (wind != null) {
                storeFor(WIND, wind, key);
            }
        }
        readShownWind();
        requestUpdate();
    }
}
