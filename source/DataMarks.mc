import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Application.Storage;

// Pen width of a mark, as a fraction of its size
(:glance)
const MARK_PEN_RATIO = 0.12;

//! Drawn behind the wind when the shown data is the last known, not the
//! current one at the shown position. Drawn, as the fonts have no such
//! symbols, and in the text color, so they show on black and white displays.
(:glance)
class DataMark {
    function initialize() {}

    //! Draws the mark in a square of the size around the center
    function draw(
        dc as Dc,
        centerX as Numeric,
        centerY as Numeric,
        size as Numeric
    ) as Void {
        // At least one pixel on the smallest fonts
        dc.setPenWidth(1 + (MARK_PEN_RATIO * size).toNumber());
        drawShape(dc, centerX, centerY, size / 2.0);
        dc.setPenWidth(1);
    }

    function drawShape(
        dc as Dc,
        centerX as Numeric,
        centerY as Numeric,
        radius as Numeric
    ) as Void {}
}

//! A clock: the data missed its refresh, as the watch was offline or the
//! request failed
(:glance)
class OutdatedMark extends DataMark {
    function initialize() {
        DataMark.initialize();
    }

    function drawShape(
        dc as Dc,
        centerX as Numeric,
        centerY as Numeric,
        radius as Numeric
    ) as Void {
        dc.drawCircle(centerX, centerY, radius);
        // Hands at three o'clock
        dc.drawLine(centerX, centerY, centerX, centerY - 0.6 * radius);
        dc.drawLine(centerX, centerY, centerX + 0.5 * radius, centerY);
    }
}

//! A map pin: the data is for another position, like before GPS moved on
(:glance)
class OtherPositionMark extends DataMark {
    function initialize() {
        DataMark.initialize();
    }

    //! A ring above a point at the bottom of the square
    function drawShape(
        dc as Dc,
        centerX as Numeric,
        centerY as Numeric,
        radius as Numeric
    ) as Void {
        var ringRadius = 0.55 * radius;
        var ringY = centerY - 0.4 * radius;
        var tipY = centerY + radius;
        dc.drawCircle(centerX, ringY, ringRadius);
        dc.drawLine(centerX - ringRadius, ringY, centerX, tipY);
        dc.drawLine(centerX + ringRadius, ringY, centerX, tipY);
    }
}

//! The mark for the stored value, or null when it is the current one at the
//! position key or nothing is stored yet. Another position outweighs the
//! age of the data.
(:glance)
function dataMarkFor(name as String, key as String) as DataMark? {
    if (Storage.getValue(name) == null) {
        return null;
    }
    if (!isStoredFor(name, key)) {
        return new OtherPositionMark();
    }
    if (isOutdated(requestTime(name))) {
        return new OutdatedMark();
    }
    return null;
}

//! Width a mark takes behind text of the height, none without a mark
(:glance)
function markWidth(mark as DataMark?, height as Numeric) as Numeric {
    if (mark == null) {
        return 0;
    }
    return height;
}
