import Toybox.Lang;
import Toybox.Test;

(:test)
function windIsFormattedWithTheGustNotation(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    var text = formatWind(wind, SPEED_UNIT_KMH, WIND_FORMAT_GUST);
    return text.equals("14 G32 km/h");
}

(:test)
function windIsFormattedWithTheGustInBrackets(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    var text = formatWind(wind, SPEED_UNIT_KMH, WIND_FORMAT_BRACKETS);
    return text.equals("14 (32) km/h");
}

(:test)
function windIsFormattedAsSpeedToGust(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    var text = formatWind(wind, SPEED_UNIT_KMH, WIND_FORMAT_DASH);
    return text.equals("14-32 km/h");
}

(:test)
function windInKnotsIsConverted(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    var text = formatWind(wind, SPEED_UNIT_KNOTS, WIND_FORMAT_DASH);
    return text.equals("7-17 kn");
}

(:test)
function windInMetersPerSecondIsConverted(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    var text = formatWind(wind, SPEED_UNIT_MS, WIND_FORMAT_DASH);
    return text.equals("4-9 m/s");
}

(:test)
function windInMilesPerHourIsConverted(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    var text = formatWind(wind, SPEED_UNIT_MPH, WIND_FORMAT_DASH);
    return text.equals("9-20 mph");
}

(:test)
function windInBeaufortIsConverted(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    var text = formatWind(wind, SPEED_UNIT_BEAUFORT, WIND_FORMAT_GUST);
    return text.equals("3 G5 Bft");
}

(:test)
function calmIsBeaufortZero(logger as Logger) as Boolean {
    return beaufortOf(0.0) == 0;
}

// 3.4 m/s, where Beaufort 3 starts
(:test)
function beaufortStartsAtItsLowerLimit(logger as Logger) as Boolean {
    return beaufortOf(3.4 * 3.6) == 3;
}

// 32.7 m/s and above
(:test)
function hurricaneIsBeaufortTwelve(logger as Logger) as Boolean {
    return beaufortOf(200.0) == 12;
}

(:test)
function speedUnitIsKnotsByDefault(logger as Logger) as Boolean {
    return speedUnit() == SPEED_UNIT_KNOTS;
}

(:test)
function windFormatIsTheGustNotationByDefault(logger as Logger) as Boolean {
    return windFormat() == WIND_FORMAT_GUST;
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
function speedAndGustLeaveOutTheUnit(logger as Logger) as Boolean {
    var wind = [13.7, 31.7, 215.0] as Wind;
    var text = formatSpeedAndGust(wind, SPEED_UNIT_KMH, WIND_FORMAT_GUST);
    return text.equals("14 G32");
}
