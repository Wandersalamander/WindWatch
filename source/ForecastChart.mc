import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Lighter wind is not stretched up to the full height, so calm days look calm.
// Chart speeds are in km/h, only the labels are in the unit of speedUnit().
const MIN_CHART_TOP_SPEED = 20.0;
// Pixels between the bars and their labels or the screen edge
const CHART_PADDING = 4;
// The bottom label shows the unit instead of 0, the bars obviously start at 0
const WIDEST_RANGE_LABEL = "km/h";
// Keeps the calmest bars visible above the axis instead of looking like missing data
const MIN_BAR_HEIGHT = 3;
const GUST_MARK_HEIGHT = 2;
// One direction arrow per that many hours, drawn above the middle hour
const HOURS_PER_ARROW = 6;
// Fraction of the arrow row taken by an arrow
const CHART_ARROW_SIZE_RATIO = 0.8;
// Day labels sit below the local noon of their day
const NOON_HOUR = 12;

// Axis lines and labels stay quieter than the bars and the lake text
const CHART_GRID_COLOR = Graphics.COLOR_DK_GRAY;
const CHART_LABEL_COLOR = Graphics.COLOR_LT_GRAY;

//! Bar chart of the forecast wind speeds with marks at the gust speeds,
//! a row of direction arrows above the bars, the day labels below them and
//! range labels on their right side, fitted into the visible screen between
//! top and bottom.
class ForecastChart {
    private var _left as Float;
    private var _arrowsTop as Numeric;
    private var _top as Numeric;
    private var _width as Float;
    private var _barsHeight as Numeric;

    function initialize(dc as Dc, top as Numeric, bottom as Numeric) {
        var span = visibleSpan(dc, top, bottom);
        var labelWidth = dc.getTextWidthInPixels(
            WIDEST_RANGE_LABEL,
            SMALL_TEXT_FONT
        );
        var arrowRowHeight = dc.getFontHeight(SMALL_TEXT_FONT);
        _left = span[0] + CHART_PADDING;
        _arrowsTop = top;
        _top = top + arrowRowHeight;
        _width = span[1] - _left - labelWidth - 2 * CHART_PADDING;
        _barsHeight =
            bottom - _top - CHART_PADDING - dc.getFontHeight(SMALL_TEXT_FONT);
    }

    function draw(dc as Dc, forecast as Forecast) as Void {
        var topSpeed = chartTopSpeed(forecast[FORECAST_GUSTS]);
        drawBars(dc, forecast[FORECAST_SPEEDS], topSpeed);
        drawGustMarks(dc, forecast[FORECAST_GUSTS], topSpeed);
        drawAxis(dc);
        drawArrows(dc, forecast[FORECAST_DIRECTIONS]);
        drawDayMarks(dc, forecast[FORECAST_TIMES]);
        drawRangeLabels(dc, topSpeed);
    }

    private function drawBars(
        dc as Dc,
        speeds as Array<Float>,
        topSpeed as Float
    ) as Void {
        var barWidth = _width / speeds.size();
        var bottom = barsBottom();
        for (var i = 0; i < speeds.size(); i++) {
            var barLeft = (_left + i * barWidth).toNumber();
            var barRight = (_left + (i + 1) * barWidth).toNumber();
            var barHeight = heightOf(speeds[i], topSpeed);
            if (barHeight < MIN_BAR_HEIGHT) {
                barHeight = MIN_BAR_HEIGHT;
            }
            dc.setColor(getColor(speeds[i]), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(
                barLeft,
                bottom - barHeight,
                barRight - barLeft,
                barHeight
            );
        }
    }

    private function drawGustMarks(
        dc as Dc,
        gusts as Array<Float>,
        topSpeed as Float
    ) as Void {
        var barWidth = _width / gusts.size();
        dc.setColor(CHART_LABEL_COLOR, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < gusts.size(); i++) {
            var barLeft = (_left + i * barWidth).toNumber();
            var barRight = (_left + (i + 1) * barWidth).toNumber();
            dc.fillRectangle(
                barLeft,
                barsBottom() - heightOf(gusts[i], topSpeed),
                barRight - barLeft,
                GUST_MARK_HEIGHT
            );
        }
    }

    private function heightOf(speed as Float, topSpeed as Float) as Float {
        return ((speed / topSpeed) * _barsHeight).toFloat();
    }

    private function drawAxis(dc as Dc) as Void {
        dc.setColor(CHART_GRID_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(_left, barsBottom(), _left + _width, barsBottom());
    }

    private function drawArrows(dc as Dc, directions as Array<Float>) as Void {
        var slotWidth = _width / directions.size();
        var rowHeight = _top - _arrowsTop;
        var arrowLength = CHART_ARROW_SIZE_RATIO * rowHeight;
        dc.setColor(CHART_LABEL_COLOR, Graphics.COLOR_TRANSPARENT);
        for (
            var i = HOURS_PER_ARROW / 2;
            i < directions.size();
            i += HOURS_PER_ARROW
        ) {
            drawWindArrow(
                dc,
                _left + (i + 0.5) * slotWidth,
                _arrowsTop + rowHeight / 2.0,
                arrowLength,
                directions[i]
            );
        }
    }

    // Marks are placed where local midnight or noon falls between two samples,
    // so they also work for non-whole-hour time zones
    private function drawDayMarks(dc as Dc, times as Array<Number>) as Void {
        var slotWidth = _width / times.size();
        var todayDay = Gregorian.info(Time.now(), Time.FORMAT_SHORT).day;
        var lastIndex = times.size() - 1;
        var previous = localInfo(times[0]);
        for (var i = 1; i < times.size(); i++) {
            var x = _left + i * slotWidth;
            var current = localInfo(times[i]);
            var isNewDay = current.day != previous.day;
            var isPastNoon =
                previous.hour < NOON_HOUR && current.hour >= NOON_HOUR;
            if (isNewDay) {
                drawDaySeparator(dc, x);
            } else if (isPastNoon && i < lastIndex) {
                drawDayLabel(dc, x, dayLabel(current.day, todayDay));
            }
            previous = current;
        }
    }

    private function localInfo(time as Number) as Gregorian.Info {
        return Gregorian.info(new Time.Moment(time), Time.FORMAT_SHORT);
    }

    // A black gap splits the bars into days, a tick continues it below the axis
    private function drawDaySeparator(dc as Dc, x as Float) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, _top, x, barsBottom());
        dc.setColor(CHART_GRID_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x, barsBottom(), x, barsBottom() + CHART_PADDING);
    }

    private function dayLabel(day as Number, todayDay as Number) as String {
        if (day == todayDay) {
            return WatchUi.loadResource(Rez.Strings.Today) as String;
        }
        return day.format("%02d") + ".";
    }

    // Labels of days that start close to the left end would be cut
    private function drawDayLabel(
        dc as Dc,
        x as Float,
        label as String
    ) as Void {
        var labelLeft = x - dc.getTextWidthInPixels(label, SMALL_TEXT_FONT) / 2;
        if (labelLeft < _left) {
            return;
        }
        dc.setColor(CHART_LABEL_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            x,
            barsBottom() + CHART_PADDING,
            SMALL_TEXT_FONT,
            label,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    private function drawRangeLabels(dc as Dc, topSpeed as Float) as Void {
        var labelX = _left + _width + CHART_PADDING;
        var labelHeight = dc.getFontHeight(SMALL_TEXT_FONT);
        var bottomLabelTop = barsBottom() - labelHeight;
        dc.setColor(CHART_LABEL_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            labelX,
            _top,
            SMALL_TEXT_FONT,
            speedIn(topSpeed, speedUnit()).format("%.0f"),
            Graphics.TEXT_JUSTIFY_LEFT
        );
        // Small screens leave the bars too low for two labels
        var labelsOverlap = bottomLabelTop < _top + labelHeight;
        if (labelsOverlap) {
            return;
        }
        dc.drawText(
            labelX,
            bottomLabelTop,
            SMALL_TEXT_FONT,
            speedUnitLabel(speedUnit()),
            Graphics.TEXT_JUSTIFY_LEFT
        );
    }

    private function barsBottom() as Numeric {
        return _top + _barsHeight;
    }
}

//! Speed at the top of the chart, whose bars start at 0: the strongest gust,
//! raised to at least MIN_CHART_TOP_SPEED
function chartTopSpeed(gusts as Array<Float>) as Float {
    var strongestGust = maximum(gusts).toFloat();
    if (strongestGust < MIN_CHART_TOP_SPEED) {
        return MIN_CHART_TOP_SPEED;
    }
    return strongestGust;
}
