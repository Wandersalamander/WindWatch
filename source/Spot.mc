import Toybox.Lang;
import Toybox.Position;

//! The position the wind is shown for: in GPS mode the last GPS fix, else the
//! favourite. GPS mode shows the favourite until the first fix.
(:glance)
function shownPosition() as [Double, Double] {
    var gpsPosition = getGpsPosition();
    if (getShowsGps() && gpsPosition != null) {
        return gpsPosition;
    }
    return getFavouritePosition();
}

//! Query of the position, rounded to about 1 km, which is finer than the
//! weather models. It also keys the stored data, so GPS jitter within a
//! model cell asks for nothing new.
(:glance)
function positionKey(position as [Double, Double]) as String {
    return Lang.format("latitude=$1$&longitude=$2$", [
        position[0].format("%.2f"),
        position[1].format("%.2f"),
    ]);
}

//! The current or last known GPS position, or null without any fix
function getPosition() as [Double, Double]? {
    var info = Position.getInfo();
    var position = info.position;
    if (info.accuracy >= Position.QUALITY_LAST_KNOWN && position != null) {
        return position.toDegrees();
    }
    return null;
}
