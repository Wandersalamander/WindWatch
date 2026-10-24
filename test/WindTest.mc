import Toybox.Lang;
import Toybox.Test;

(:test)
function windIsFormattedAsSpeedToGust(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    return formatWind(wind, SPEED_UNIT_KMH).equals("14-32 km/h");
}

(:test)
function windInKnotsIsConverted(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    return formatWind(wind, SPEED_UNIT_KNOTS).equals("7-17 kn");
}

(:test)
function speedUnitIsKnotsByDefault(logger as Logger) as Boolean {
    return speedUnit() == SPEED_UNIT_KNOTS;
}

// Wind from the south blows north, so the tip is above the center
(:test)
function arrowOfSouthWindPointsUp(logger as Logger) as Boolean {
    var tip = windArrowPoints(50, 50, 20, 180.0)[0];
    return (tip[0] - 50).abs() < 0.01 && (tip[1] - 40).abs() < 0.01;
}

// Wind from the west blows east, so the tip is right of the center
(:test)
function arrowOfWestWindPointsRight(logger as Logger) as Boolean {
    var tip = windArrowPoints(50, 50, 20, 270.0)[0];
    return (tip[0] - 60).abs() < 0.01 && (tip[1] - 50).abs() < 0.01;
}

(:test)
function windRangeLeavesOutTheUnit(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    return formatWindRange(wind, SPEED_UNIT_KMH).equals("14-32");
}
