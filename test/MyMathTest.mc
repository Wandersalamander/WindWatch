import Toybox.Lang;
import Toybox.Test;

(:test)
function maximumFindsLargest(logger as Logger) as Boolean {
    return maximum([3, 9, 1]) == 9;
}

(:test)
function minimumFindsSmallest(logger as Logger) as Boolean {
    return minimum([3, 9, 1]) == 1;
}

(:test)
function meanAveragesValues(logger as Logger) as Boolean {
    return mean([1, 2, 3, 6]) == 3.0;
}

(:test)
function spanIsMaxMinusMin(logger as Logger) as Boolean {
    return span([3, 9, 1]) == 8;
}
