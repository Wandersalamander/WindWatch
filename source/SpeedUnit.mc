import Toybox.Application;
import Toybox.Lang;

// Values of the SpeedUnit setting, see resources/settings
(:glance)
enum SpeedUnit {
    SPEED_UNIT_KNOTS = 0,
    SPEED_UNIT_KMH = 1,
}

(:glance)
const KMH_PER_KNOT = 1.852;

//! The unit chosen in the app settings, knots as sailors on the lakes use them.
//! Speeds stay in km/h internally, so changing the unit needs no new request.
(:glance)
function speedUnit() as SpeedUnit {
    var unit = Application.Properties.getValue("SpeedUnit");
    if (SPEED_UNIT_KMH.equals(unit)) {
        return SPEED_UNIT_KMH;
    }
    return SPEED_UNIT_KNOTS;
}

(:glance)
function speedIn(kmh as Float, unit as SpeedUnit) as Float {
    if (unit == SPEED_UNIT_KMH) {
        return kmh;
    }
    return kmh / KMH_PER_KNOT;
}

(:glance)
function speedUnitLabel(unit as SpeedUnit) as String {
    if (unit == SPEED_UNIT_KMH) {
        return "km/h";
    }
    return "kn";
}
