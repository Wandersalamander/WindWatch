import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Test;

(:test,:colorDisplay)
function colorWithoutSpeedIsGray(logger as Logger) as Boolean {
    return getColor(null) == Graphics.COLOR_DK_GRAY;
}

(:test,:colorDisplay)
function colorOfCalmIsDarkBlue(logger as Logger) as Boolean {
    return getColor(5.9) == Graphics.COLOR_DK_BLUE;
}

(:test,:colorDisplay)
function colorOfModerateBreezeIsGreen(logger as Logger) as Boolean {
    return getColor(20.0) == Graphics.COLOR_GREEN;
}

(:test,:colorDisplay)
function colorOfStormIsRed(logger as Logger) as Boolean {
    return getColor(90.0) == Graphics.COLOR_RED;
}

(:test,:monochromeDisplay)
function colorOnMonochromeDisplayIsWhite(logger as Logger) as Boolean {
    return getColor(5.9) == Graphics.COLOR_WHITE;
}

(:test)
function bandOfNegativeSpeedIsFirst(logger as Logger) as Boolean {
    return bandOf(-1.0) == 0;
}

(:test)
function bandOfStormIsLast(logger as Logger) as Boolean {
    return bandOf(90.0) == bandCount() - 1;
}

(:test)
function colorPosIsClampedBelow(logger as Logger) as Boolean {
    return getColorPos(-5.0) == 0.0;
}

(:test)
function colorPosIsClampedAbove(logger as Logger) as Boolean {
    return getColorPos(90.0) == 1.0;
}

(:test)
function colorPosIsCenteredAtStartOfGreenBand(logger as Logger) as Boolean {
    return getColorPos(20.0) == 0.5;
}

(:test)
function colorPosStaysInBlueSegmentBelowTwelve(logger as Logger) as Boolean {
    return getColorPos(11.9) < 2.0 / 6.0;
}

(:test)
function colorByIdxMatchesSpeedBand(logger as Logger) as Boolean {
    return getColorByIdx(3) == getColor(20.0);
}
