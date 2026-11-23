import Toybox.Application;
import Toybox.Lang;

//! The entry chosen in a list setting, or the first one when the stored
//! value is not one of the entries
(:glance)
function listSetting(id as String, entryCount as Number) as Number {
    var entry = Application.Properties.getValue(id);
    if (entry instanceof Number && entry >= 0 && entry < entryCount) {
        return entry;
    }
    return 0;
}

//! A list setting of the app settings, which the watch menu also steps through
class ListSetting {
    private var _id as String;
    // Indexed by the values of the setting, as in resources/settings
    private var _entryNames as Array<ResourceId>;

    function initialize(id as String, entryNames as Array<ResourceId>) {
        _id = id;
        _entryNames = entryNames;
    }

    function chosenName() as ResourceId {
        return _entryNames[chosenEntry()];
    }

    //! Chooses the next entry, and the first after the last
    function chooseNext() as Void {
        var next = (chosenEntry() + 1) % _entryNames.size();
        Application.Properties.setValue(_id, next);
    }

    private function chosenEntry() as Number {
        return listSetting(_id, _entryNames.size());
    }
}
