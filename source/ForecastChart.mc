import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Lighter wind is not stretched up to the full height, so calm days look calm.
// Chart speeds are in km/h, only the labels are in the unit of speedUnit().
const MIN_CHART_TOP_SPEED = 20.0;
// Pixels between the bars and their labels or the screen edge
const CHART_PADDING = 4;
// Keeps the calmest bars visible above the axis instead of looking like missing data
const MIN_BAR_HEIGHT = 3;
const GUST_MARK_HEIGHT = 2;
// Distance between the direction arrows, in arrow row heights
const ARROW_SPACING_RATIO = 1.5;
// Fraction of the arrow row taken by an arrow
const CHART_ARROW_SIZE_RATIO = 0.8;
// Day labels sit below the local noon of their day
const NOON_HOUR = 12;
// Forecasts spanning at least a day get day labels, shorter ones hour labels
const SECONDS_PER_DAY = 24 * 60 * 60;

// Axis lines and labels stay quieter than the bars and the wind text
const CHART_GRID_COLOR = Graphics.COLOR_DK_GRAY;
const CHART_LABEL_COLOR = Graphics.COLOR_LT_GRAY;

//! Bar chart of the forecast wind speeds with marks at the gust speeds,
//! a row of direction arrows above the bars ending in the speed at the top of
//! the scale, day or hour labels below the bars and the title below them,
//! fitted into the visible screen between top and bottom.
class ForecastChart {
    private var _left as Float;
    private var _arrowsTop as Numeric;
    // Whole pixels, so all bars end on the same pixel row
    private var _top as Number;
    private var _width as Float;
    private var _barsHeight as Number;

    private var _title as String;

    function initialize(
        dc as Dc,
        top as Numeric,
        bottom as Numeric,
        title as String
    ) {
        var rowHeight = dc.getFontHeight(SMALL_TEXT_FONT);
        var titleTop = bottom - rowHeight;
        // The short centered title does not narrow the chart
        var span = visibleSpan(dc, top, titleTop);
        _title = title;
        _left = span[0] + CHART_PADDING;
        _arrowsTop = top;
        _top = (top + rowHeight).toNumber();
        _width = span[1] - span[0] - 2 * CHART_PADDING;
        _barsHeight = (titleTop - _top - CHART_PADDING - rowHeight).toNumber();
    }

    function draw(dc as Dc, forecast as Forecast) as Void {
        var topSpeed = chartTopSpeed(forecast[FORECAST_GUSTS]);
        var scaleLabel = scaleLabelOf(topSpeed);
        var scaleLabelLeft =
            _left +
            _width -
            dc.getTextWidthInPixels(scaleLabel, SMALL_TEXT_FONT);
        drawBars(dc, forecast[FORECAST_SPEEDS], topSpeed);
        drawGustMarks(dc, forecast[FORECAST_GUSTS], topSpeed);
        drawAxis(dc);
        drawArrows(
            dc,
            forecast[FORECAST_DIRECTIONS],
            scaleLabelLeft - CHART_PADDING
        );
        drawTimeMarks(dc, forecast[FORECAST_TIMES]);
        drawTitle(dc);
        drawScaleLabel(dc, scaleLabel);
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
            // fillRectangle truncates top and height on their own, which
            // would leave the bottom of some bars a pixel short
            var barTop = Math.round(bottom - barHeight).toNumber();
            dc.setColor(getColor(speeds[i]), Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(
                barLeft,
                barTop,
                barRight - barLeft,
                bottom - barTop
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

    //! Arrows up to the right end, where the scale label starts
    private function drawArrows(
        dc as Dc,
        directions as Array<Float>,
        right as Float
    ) as Void {
        var slotWidth = _width / directions.size();
        var rowHeight = _top - _arrowsTop;
        var arrowLength = CHART_ARROW_SIZE_RATIO * rowHeight;
        var samplesPerArrow = Math.ceil(
            (ARROW_SPACING_RATIO * rowHeight) / slotWidth
        ).toNumber();
        dc.setColor(CHART_LABEL_COLOR, Graphics.COLOR_TRANSPARENT);
        for (
            var i = samplesPerArrow / 2;
            i < directions.size();
            i += samplesPerArrow
        ) {
            var x = _left + (i + 0.5) * slotWidth;
            if (x + arrowLength / 2 > right) {
                break;
            }
            drawWindArrow(
                dc,
                x,
                _arrowsTop + rowHeight / 2.0,
                arrowLength,
                directions[i]
            );
        }
    }

    private function drawTimeMarks(dc as Dc, times as Array<Number>) as Void {
        var spansDays = times[times.size() - 1] - times[0] >= SECONDS_PER_DAY;
        if (spansDays) {
            drawDayMarks(dc, times);
        } else {
            drawHourMarks(dc, times);
        }
    }

    // Labels every whole hour that has room after the previous label
    private function drawHourMarks(dc as Dc, times as Array<Number>) as Void {
        var slotWidth = _width / times.size();
        var freeFromX = _left;
        dc.setColor(CHART_LABEL_COLOR, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < times.size(); i++) {
            var info = localInfo(times[i]);
            var x = _left + i * slotWidth;
            var label = info.hour.format("%d") + "h";
            var halfWidth = dc.getTextWidthInPixels(label, SMALL_TEXT_FONT) / 2;
            var fits = x - halfWidth >= freeFromX;
            if (info.min == 0 && fits) {
                dc.drawLine(x, barsBottom(), x, barsBottom() + CHART_PADDING);
                dc.drawText(
                    x,
                    barsBottom() + CHART_PADDING,
                    SMALL_TEXT_FONT,
                    label,
                    Graphics.TEXT_JUSTIFY_CENTER
                );
                freeFromX = x + halfWidth + CHART_PADDING;
            }
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
        var labelWidth = dc.getTextWidthInPixels(label, SMALL_TEXT_FONT);
        if (x - labelWidth / 2 < _left) {
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

    // Centered below the time labels, where round screens are still wide
    // enough for one word
    private function drawTitle(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _left + _width / 2,
            barsBottom() + CHART_PADDING + dc.getFontHeight(SMALL_TEXT_FONT),
            SMALL_TEXT_FONT,
            _title,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    // At the right end of the arrow row, right above the top of the bars it
    // stands for
    private function drawScaleLabel(dc as Dc, label as String) as Void {
        dc.setColor(CHART_LABEL_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            _left + _width,
            _arrowsTop,
            SMALL_TEXT_FONT,
            label,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    private function scaleLabelOf(topSpeed as Float) as String {
        var unit = speedUnit();
        return (
            speedIn(topSpeed, unit).format("%.0f") + " " + speedUnitLabel(unit)
        );
    }

    private function barsBottom() as Number {
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
