import Toybox.Lang;
import Toybox.Time;
import Toybox.Application.Storage;
import Toybox.Application;
(:glance)
function setFavouritePosition(position_lat_long as [Double, Double]) as Void {
    Storage.setValue("favouritePosition", position_lat_long);
}

function setFavouriteLake(newFavouriteLake as String) as Void {
    Storage.setValue("favouriteLake", newFavouriteLake);
}
(:glance)
function setFavouriteWind(wind as Wind) as Void {
    Storage.setValue("favouriteWind", wind);
}
function setFavouriteForecast(forecast as Forecast) as Void {
    Storage.setValue("favouriteForecast", forecast as Array<Storage.ValueType>);
}

(:glance)
function setGlanceLastUpdate() as Void {
    Storage.setValue("glanceLastUpdate", Time.now().value() as Number);
}
function setLastUpdateProx() as Void {
    Storage.setValue("lastUpdateProx", Time.now().value() as Number);
}
function setLastUpdateFav() as Void {
    Storage.setValue("lastUpdateFav", Time.now().value() as Number);
}

function setCurrentWind(wind as Wind) as Void {
    Storage.setValue("currentWind", wind);
}
function setCurrentDistance(currentDistance as Float) as Void {
    Storage.setValue("currentDistance", currentDistance);
}
function clearCurrentWind() as Void {
    Storage.deleteValue("currentWind");
}

// Getters
(:glance)
function getFavouritePosition() as [Double, Double] {
    var myDefault = [(46.287075).toDouble(), (6.16961).toDouble()];
    var ret = Storage.getValue("favouritePosition") as [Double, Double]?;
    if (ret == null) {
        return myDefault;
    } else {
        return ret;
    }
}

(:glance)
function getFavouriteLake() as String {
    var myDefault = "geneva";
    var ret = Storage.getValue("favouriteLake");
    if (ret == null) {
        return myDefault;
    }
    return ret as String;
}

(:glance)
function getFavouriteWind() as Wind? {
    return Storage.getValue("favouriteWind") as Wind?;
}
function getFavouriteForecast() as Forecast? {
    return Storage.getValue("favouriteForecast") as Forecast?;
}

(:glance)
function _getLastUpdate(name as String) as Time.Moment? {
    if (Storage.getValue(name) != null) {
        return new Time.Moment(Storage.getValue(name) as Number);
    } else {
        return null;
    }
}
(:glance)
function getGlanceLastUpdate() as Time.Moment? {
    return _getLastUpdate("glanceLastUpdate");
}
function getLastUpdateProx() as Time.Moment? {
    return _getLastUpdate("lastUpdateProx");
}
(:glance)
function getLastUpdateFav() as Time.Moment? {
    return _getLastUpdate("lastUpdateFav");
}

function getCurrentWind() as Wind? {
    return Storage.getValue("currentWind") as Wind?;
}
function getCurrentDistance() as Float? {
    return Storage.getValue("currentDistance") as Float?;
}

function getCurrentLake() as String? {
    return Storage.getValue("currentLake") as String?;
}
function getCurrentPosition() as [Double, Double]? {
    return Storage.getValue("currentPosition") as [Double, Double]?;
}

function setCurrentLake(lake as String) as Void {
    Storage.setValue("currentLake", lake);
}
function setCurrentPosition(position as [Double, Double]) as Void {
    Storage.setValue("currentPosition", position);
}
