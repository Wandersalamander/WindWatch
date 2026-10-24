import Toybox.Lang;
import Toybox.Test;

const GENEVA_POSITION as [Double, Double] = [46.287075d, 6.16961d];

(:test)
function closestLakeToGenevaShoreIsGeneva(logger as Logger) as Boolean {
    return "geneva".equals(getClosesLake(GENEVA_POSITION));
}

// The mean of Lake Geneva is far from its east end, behind those of smaller lakes
(:test)
function closestLakeAtEastEndOfGenevaIsGeneva(logger as Logger) as Boolean {
    return "geneva".equals(getClosesLake([46.36d, 6.84d]));
}

// Comparing unscaled degrees picks Lake Neuchatel, 24 km away instead of 21 km
(:test)
function closestLakeScalesLongitudeByLatitude(logger as Logger) as Boolean {
    return "biel".equals(getClosesLake([47.21d, 6.95d]));
}

(:test)
function closestLakeWithoutPositionIsNull(logger as Logger) as Boolean {
    return getClosesLake(null) == null;
}

// 1313 m to the closest border point in scripts/lake_borders.json
(:test)
function closestLakeDistanceIsInMeters(logger as Logger) as Boolean {
    var distance = (closestLake(GENEVA_POSITION) as [String, Float])[1];
    return (distance - 1313).abs() < 5;
}
