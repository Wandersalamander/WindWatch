import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.WatchUi;

// Fonts available on every device; the FONT_AUX* fonts need API 4.2.2
const LARGE_TEXT_FONT = Graphics.FONT_MEDIUM;
const SMALL_TEXT_FONT = Graphics.FONT_XTINY;
// Cut of the top corners of semi-octagon displays (Instinct), as a fraction
// of the width, measured from the simulator's display outline. The bottom
// corners are only slightly rounded.
const OCTAGON_CORNER_RATIO = 0.18;
// Keeps text clear of the ring drawn around a subscreen
const SUBSCREEN_MARGIN = 4;
// Fraction of the line height taken by a direction arrow in front of the text
(:glance)
const ARROW_SIZE_RATIO = 0.7;
// Largest first, for text that should be as large as its area allows
const FONTS_BY_SIZE as Array<FontType> = [
    Graphics.FONT_MEDIUM,
    Graphics.FONT_SMALL,
    Graphics.FONT_XTINY,
];

//! Draws the wind range with its direction arrow in front, centered in the
//! visible part of its row. Without the unit, which the forecast chart shows,
//! as the top row of round screens is narrow.
function drawWindLine(
    dc as Dc,
    top as Numeric,
    font as FontType,
    wind as Wind
) as Void {
    var width = arrowLineTextWidth(dc, top, font);
    var text = fitText(dc, formatWindRange(wind, speedUnit()), font, width);
    drawArrowLine(dc, top, font, text, wind[WIND_DIRECTION]);
}

function drawArrowLine(
    dc as Dc,
    top as Numeric,
    font as FontType,
    text as String,
    fromDirection as Float
) as Void {
    var height = dc.getFontHeight(font);
    var span = visibleSpan(dc, top, top + height);
    var lineWidth = height + dc.getTextWidthInPixels(text, font);
    var left = (span[0] + span[1] - lineWidth) / 2.0;
    drawWindArrow(
        dc,
        left + height / 2.0,
        top + height / 2.0,
        ARROW_SIZE_RATIO * height,
        fromDirection
    );
    dc.drawText(left + height, top, font, text, Graphics.TEXT_JUSTIFY_LEFT);
}

// The arrow takes a square of the line height in front of the text
function arrowLineTextWidth(
    dc as Dc,
    top as Numeric,
    font as FontType
) as Float {
    var height = dc.getFontHeight(font);
    var span = visibleSpan(dc, top, top + height);
    return span[1] - span[0] - height;
}

//! Draws the text centered in the round subscreen, in the largest font it fits
function drawInSubscreen(
    dc as Dc,
    subscreen as BoundingBox,
    text as String
) as Void {
    var radius = (subscreen.width as Number) / 2.0 - SUBSCREEN_MARGIN;
    var font = FONTS_BY_SIZE[FONTS_BY_SIZE.size() - 1];
    for (var i = FONTS_BY_SIZE.size() - 1; i >= 0; i--) {
        var textWidth = dc.getTextWidthInPixels(text, FONTS_BY_SIZE[i]);
        if (textWidth <= subscreenTextWidth(dc, radius, FONTS_BY_SIZE[i])) {
            font = FONTS_BY_SIZE[i];
        }
    }
    dc.drawText(
        (subscreen.x as Number) + (subscreen.width as Number) / 2.0,
        (subscreen.y as Number) + (subscreen.height as Number) / 2.0,
        font,
        text,
        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
    );
}

// Width of a text line through the center of the round subscreen
function subscreenTextWidth(
    dc as Dc,
    radius as Float,
    font as FontType
) as Float {
    return chordLength(radius, dc.getFontHeight(font) / 2.0);
}

//! Length of a circle's chord at the given distance from its center
function chordLength(radius as Float, distanceFromCenter as Float) as Float {
    if (distanceFromCenter >= radius) {
        return 0.0;
    }
    return (
        2 *
        Math.sqrt(
            radius * radius - distanceFromCenter * distanceFromCenter
        ).toFloat()
    );
}

//! Horizontal extent [left, right] that is visible over the whole height
//! of the row from top to bottom, excluding round display edges and subscreens.
//! Symmetric around the middle of the screen, so content in it looks centered
//! even when a subscreen cuts one side.
function visibleSpan(
    dc as Dc,
    top as Numeric,
    bottom as Numeric
) as [Float, Float] {
    var span = displaySpan(dc, top, bottom);
    var subscreen = subscreenArea();
    if (subscreen != null) {
        var subscreenLeft = subscreen.x as Number;
        var subscreenBottom =
            (subscreen.y as Number) + (subscreen.height as Number);
        var rightOfSpan = subscreenLeft - SUBSCREEN_MARGIN;
        if (top < subscreenBottom && rightOfSpan < span[1]) {
            span[1] = rightOfSpan.toFloat();
        }
    }
    var middle = dc.getWidth() / 2.0;
    var halfWidth = middle - span[0];
    if (span[1] - middle < halfWidth) {
        halfWidth = span[1] - middle;
    }
    return [middle - halfWidth, middle + halfWidth];
}

function displaySpan(
    dc as Dc,
    top as Numeric,
    bottom as Numeric
) as [Float, Float] {
    var shape = System.getDeviceSettings().screenShape;
    if (shape == System.SCREEN_SHAPE_RECTANGLE) {
        return [0.0, dc.getWidth().toFloat()];
    }
    if (shape == System.SCREEN_SHAPE_SEMI_OCTAGON) {
        return octagonSpan(dc, top);
    }
    return circleSpan(dc, top, bottom);
}

function octagonSpan(dc as Dc, top as Numeric) as [Float, Float] {
    var width = dc.getWidth().toFloat();
    var cornerCut = OCTAGON_CORNER_RATIO * width;
    var inset = (cornerCut - top).toFloat();
    if (inset < 0) {
        inset = 0.0;
    }
    return [inset, width - inset];
}

function circleSpan(
    dc as Dc,
    top as Numeric,
    bottom as Numeric
) as [Float, Float] {
    var radius = dc.getWidth() / 2.0;
    var centerY = dc.getHeight() / 2.0;
    var distanceFromCenter = (top - centerY).abs();
    if ((bottom - centerY).abs() > distanceFromCenter) {
        distanceFromCenter = (bottom - centerY).abs();
    }
    var halfChord = chordLength(radius, distanceFromCenter.toFloat()) / 2.0;
    return [radius - halfChord, radius + halfChord];
}

function subscreenArea() as BoundingBox? {
    if (WatchUi has :getSubscreen) {
        return WatchUi.getSubscreen();
    }
    return null;
}

(:glance)
const ELLIPSIS = "...";

//! The text, shortened character by character with an ellipsis to fit the width.
//! Graphics.fitTextToArea drops whole words, which loses most of short names.
(:glance)
function fitText(
    dc as Dc,
    text as String,
    font as FontType,
    width as Numeric
) as String {
    if (dc.getTextWidthInPixels(text, font) <= width) {
        return text;
    }
    var shortened = text;
    while (
        shortened.length() > 0 &&
        dc.getTextWidthInPixels(shortened + ELLIPSIS, font) > width
    ) {
        shortened = shortened.substring(0, shortened.length() - 1) as String;
    }
    return shortened + ELLIPSIS;
}
