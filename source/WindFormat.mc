import Toybox.Lang;

// Values of the WindFormat setting, see resources/settings
(:glance)
enum WindFormat {
    // The gust notation of sailing and aviation weather reports, which no
    // one takes for a range of speeds
    WIND_FORMAT_GUST = 0,
    WIND_FORMAT_BRACKETS = 1,
    WIND_FORMAT_DASH = 2,
}

// Patterns of the mean speed $1$ and the gust speed $2$, indexed by WindFormat
(:glance)
const WIND_FORMAT_PATTERNS as Array<String> = [
    "$1$ G$2$",
    "$1$ ($2$)",
    "$1$-$2$",
];

//! The format chosen in the app settings
(:glance)
function windFormat() as WindFormat {
    return listSetting("WindFormat", WIND_FORMAT_PATTERNS.size()) as WindFormat;
}
