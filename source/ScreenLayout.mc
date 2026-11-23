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
// Keeps content clear of the slightly rounded side and bottom edges of
// semi-octagon displays, where the bezel of the Instinct 2S also overlaps
// the screen in the simulator
const OCTAGON_EDGE_MARGIN = 6;
// Fraction of the line height taken by a direction arrow in front of the text
(:glance)
const ARROW_SIZE_RATIO = 0.7;
// Largest first, for text that should be as large as its area allows
const FONTS_BY_SIZE as Array<FontType> = [
    Graphics.FONT_MEDIUM,
    Graphics.FONT_SMALL,
    Graphics.FONT_XTINY,
];

//! Draws the mean and gust speed with the direction arrow in front and the mark
//! behind, centered in the visible part of its row. Without the unit, which
//! the forecast chart shows, as the top row of round screens is narrow.
function drawWindLine(
    dc as Dc,
    top as Numeric,
    font as FontType,
    wind as Wind,
    mark as DataMark?
) as Void {
    var height = dc.getFontHeight(font);
    var span = visibleSpan(dc, top, top + height);
    var markSpace = markWidth(mark, height);
    var text = fitText(
        dc,
        formatSpeedAndGust(wind, speedUnit(), windFormat()),
        font,
        span[1] - span[0] - height - markSpace
    );
    var textWidth = dc.getTextWidthInPixels(text, font);
    var left = (span[0] + span[1] - height - textWidth - markSpace) / 2.0;
    var centerY = top + height / 2.0;
    var symbolSize = ARROW_SIZE_RATIO * height;
    drawWindArrow(
        dc,
        left + height / 2.0,
        centerY,
        symbolSize,
        wind[WIND_DIRECTION]
    );
    dc.drawText(left + height, top, font, text, Graphics.TEXT_JUSTIFY_LEFT);
    if (mark != null) {
        var textRight = left + height + textWidth;
        mark.draw(dc, textRight + height / 2.0, centerY, symbolSize);
    }
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
//! Beside a subscreen it ends at the subscreen, so content centered in it
//! uses the free space on its left, as the Instinct's own screens do.
function visibleSpan(
    dc as Dc,
    top as Numeric,
    bottom as Numeric
) as [Float, Float] {
    var span = displaySpan(dc, top, bottom);
    var subscreen = subscreenArea();
    if (subscreen != null && top < subscreenBottom(subscreen)) {
        var rightOfSpan = (subscreen.x as Number) - SUBSCREEN_MARGIN;
        if (rightOfSpan < span[1]) {
            span[1] = rightOfSpan.toFloat();
        }
    }
    return span;
}

//! Round screens narrow toward the bottom as toward the top, so content ends
//! as far above the bottom as it starts below the top. The flat bottom of
//! semi-octagon displays (Instinct) is used up to its edge.
function contentBottom(dc as Dc, contentTop as Float) as Float {
    var height = dc.getHeight();
    var shape = System.getDeviceSettings().screenShape;
    if (shape == System.SCREEN_SHAPE_SEMI_OCTAGON) {
        return (height - OCTAGON_EDGE_MARGIN).toFloat();
    }
    return height - contentTop;
}

//! The top, moved below the subscreen if there is one, for content that
//! needs the full width of the screen
function belowSubscreen(top as Float) as Float {
    var subscreen = subscreenArea();
    if (subscreen == null) {
        return top;
    }
    var freeTop = (subscreenBottom(subscreen) + SUBSCREEN_MARGIN).toFloat();
    return top > freeTop ? top : freeTop;
}

function subscreenBottom(subscreen as BoundingBox) as Number {
    return (subscreen.y as Number) + (subscreen.height as Number);
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
    if (inset < OCTAGON_EDGE_MARGIN) {
        inset = OCTAGON_EDGE_MARGIN.toFloat();
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
