import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;

//! [mean speed in km/h, gust speed in km/h, direction in degrees it comes from],
//! shown in the unit of speedUnit()
typedef Wind as [Float, Float, Float];

(:glance)
const WIND_SPEED = 0;
(:glance)
const WIND_GUST = 1;
(:glance)
const WIND_DIRECTION = 2;

// Arrow pointing north, around its center, in units of half its length
(:glance)
const ARROW_SHAPE as Array<[Float, Float]> = [
    [0.0, -1.0],
    [0.7, 0.8],
    [0.0, 0.35],
    [-0.7, 0.8],
];

//! "<speed>-<gust> <unit>", the range the wind blows in
(:glance)
function formatWind(wind as Wind, unit as SpeedUnit) as String {
    return formatWindRange(wind, unit) + " " + speedUnitLabel(unit);
}

//! "<speed>-<gust>", for where the unit is shown elsewhere
(:glance)
function formatWindRange(wind as Wind, unit as SpeedUnit) as String {
    return Lang.format("$1$-$2$", [
        speedIn(wind[WIND_SPEED], unit).format("%.0f"),
        speedIn(wind[WIND_GUST], unit).format("%.0f"),
    ]);
}

(:glance)
function drawWindArrow(
    dc as Dc,
    centerX as Numeric,
    centerY as Numeric,
    length as Numeric,
    fromDirection as Float
) as Void {
    dc.fillPolygon(windArrowPoints(centerX, centerY, length, fromDirection));
}

//! Corners of an arrow pointing where the wind blows to, as wind maps draw
//! it, while the API gives the direction the wind comes from. North is up.
(:glance)
function windArrowPoints(
    centerX as Numeric,
    centerY as Numeric,
    length as Numeric,
    fromDirection as Float
) as Array<[Numeric, Numeric]> {
    var bearing = Math.toRadians(fromDirection + 180.0);
    var cos = Math.cos(bearing).toFloat();
    var sin = Math.sin(bearing).toFloat();
    var halfLength = length / 2.0;
    var points = new Array<[Numeric, Numeric]>[ARROW_SHAPE.size()];
    for (var i = 0; i < ARROW_SHAPE.size(); i++) {
        var x = ARROW_SHAPE[i][0];
        var y = ARROW_SHAPE[i][1];
        points[i] = [
            centerX + halfLength * (x * cos - y * sin),
            centerY + halfLength * (x * sin + y * cos),
        ];
    }
    return points;
}
