import Toybox.Lang;
import Toybox.Test;

(:test)
function chartTopIsStrongestGust(logger as Logger) as Boolean {
    return chartTopSpeed([10.0, 31.5, 20.0]) == 31.5;
}

(:test)
function chartTopIsRaisedForLightWind(logger as Logger) as Boolean {
    return chartTopSpeed([4.0, 7.0]) == MIN_CHART_TOP_SPEED;
}
