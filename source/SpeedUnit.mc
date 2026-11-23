import Toybox.Lang;

// Values of the SpeedUnit setting, see resources/settings
(:glance)
enum SpeedUnit {
    SPEED_UNIT_KNOTS = 0,
    SPEED_UNIT_KMH = 1,
    SPEED_UNIT_MS = 2,
    SPEED_UNIT_MPH = 3,
    SPEED_UNIT_BEAUFORT = 4,
}

// Indexed by SpeedUnit
(:glance)
const UNIT_LABELS as Array<String> = ["kn", "km/h", "m/s", "mph", "Bft"];
// Indexed by SpeedUnit, for the units a factor converts to, not Beaufort
(:glance)
const KMH_PER_UNIT as Array<Float> = [1.852, 1.0, 3.6, 1.609344];

// Lowest speed of each Beaufort number from 1 to 12, in km/h, from the WMO
// limits in m/s
(:glance)
const BEAUFORT_LIMITS_KMH as Array<Float> = [
    0.5 * 3.6,
    1.6 * 3.6,
    3.4 * 3.6,
    5.5 * 3.6,
    8.0 * 3.6,
    10.8 * 3.6,
    13.9 * 3.6,
    17.2 * 3.6,
    20.8 * 3.6,
    24.5 * 3.6,
    28.5 * 3.6,
    32.7 * 3.6,
];

//! The unit chosen in the app settings, knots as sailors on the lakes use them.
//! Speeds stay in km/h internally, so changing the unit needs no new request.
(:glance)
function speedUnit() as SpeedUnit {
    return listSetting("SpeedUnit", UNIT_LABELS.size()) as SpeedUnit;
}

(:glance)
function speedIn(kmh as Float, unit as SpeedUnit) as Float {
    if (unit == SPEED_UNIT_BEAUFORT) {
        return beaufortOf(kmh).toFloat();
    }
    return kmh / KMH_PER_UNIT[unit];
}

//! The Beaufort number of the speed, from 0 for calm to 12 for hurricane
(:glance)
function beaufortOf(kmh as Float) as Number {
    var beaufort = 0;
    while (
        beaufort < BEAUFORT_LIMITS_KMH.size() &&
        kmh >= BEAUFORT_LIMITS_KMH[beaufort]
    ) {
        beaufort++;
    }
    return beaufort;
}

(:glance)
function speedUnitLabel(unit as SpeedUnit) as String {
    return UNIT_LABELS[unit];
}
