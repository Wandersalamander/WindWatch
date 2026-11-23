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

//! Whether the stored value was requested for the position key
(:glance)
function isStoredFor(name as String, key as String) as Boolean {
    return (
        Storage.getValue(name) != null &&
        key.equals(Storage.getValue(name + "Key"))
    );
}

(:glance)
function requestTime(name as String) as Time.Moment? {
    var time = Storage.getValue(name + "Time") as Number?;
    if (time == null) {
        return null;
    }
    return new Time.Moment(time);
}

//! Whether the value for the position key is missing or due for a new request
(:glance)
function needsRequest(name as String, key as String) as Boolean {
    if (isStoredFor(name, key)) {
        return isDue(requestTime(name));
    }
    return true;
}

//! The last wind stored, for whichever position, see dataMarkFor
(:glance)
function getLastWind() as Wind? {
    return Storage.getValue(WIND) as Wind?;
}

//! The last [hourly, quarter hourly] forecasts stored, see dataMarkFor
function getLastForecasts() as [Forecast, Forecast]? {
    return Storage.getValue(FORECASTS) as [Forecast, Forecast]?;
}
