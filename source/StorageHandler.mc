import Toybox.Lang;
import Toybox.Time;
import Toybox.Application.Storage;

// Club Nautique de Versoix on Lake Geneva
(:glance)
const DEFAULT_FAVOURITE as [Double, Double] = [46.288474d, 6.174525d];

// Names of the data stored per position, see storeFor
(:glance)
const WIND = "wind";
const FORECASTS = "forecasts";

(:glance)
function getFavouritePosition() as [Double, Double] {
    var position = Storage.getValue("favouritePosition") as [Double, Double]?;
    if (position == null) {
        return DEFAULT_FAVOURITE;
    }
    return position;
}
function setFavouritePosition(position as [Double, Double]) as Void {
    Storage.setValue("favouritePosition", position);
}

function hasFavourite() as Boolean {
    return Storage.getValue("favouritePosition") != null;
}

//! Kept apart from the favourite, so backing out of the prompt does not
//! bring it back on every launch
function hasShownFavouritePrompt() as Boolean {
    return Storage.getValue("favouritePromptShown") != null;
}
function setFavouritePromptShown() as Void {
    Storage.setValue("favouritePromptShown", true);
}

(:glance)
function getShowsGps() as Boolean {
    return true.equals(Storage.getValue("showsGps"));
}
function setShowsGps(showsGps as Boolean) as Void {
    Storage.setValue("showsGps", showsGps);
}

(:glance)
function getGpsPosition() as [Double, Double]? {
    return Storage.getValue("gpsPosition") as [Double, Double]?;
}
function setGpsPosition(position as [Double, Double]) as Void {
    Storage.setValue("gpsPosition", position);
}

//! Stores the value requested for the position key, with the request time
(:glance)
function storeFor(
    name as String,
    value as Storage.ValueType,
    key as String
) as Void {
    Storage.setValue(name, value);
    Storage.setValue(name + "Key", key);
    Storage.setValue(name + "Time", Time.now().value());
}

//! The value stored for the position key, or null when it is for another one
(:glance)
function storedFor(name as String, key as String) as Storage.ValueType? {
    if (key.equals(Storage.getValue(name + "Key"))) {
        return Storage.getValue(name);
    }
    return null;
}

//! Whether the value for the position key is missing or due for a new request
(:glance)
function needsRequest(name as String, key as String) as Boolean {
    var time = Storage.getValue(name + "Time") as Number?;
    if (storedFor(name, key) == null || time == null) {
        return true;
    }
    return isDue(new Time.Moment(time));
}

(:glance)
function getWindFor(key as String) as Wind? {
    return storedFor(WIND, key) as Wind?;
}

//! [hourly, quarter hourly] forecast for the position key
function getForecastsFor(key as String) as [Forecast, Forecast]? {
    return storedFor(FORECASTS, key) as [Forecast, Forecast]?;
}
