using Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Position;

enum {
    SET_FAVOURITE,
    TOGGLE_SHOWN_POSITION,
    RELOAD,
    CREDITS,
}

//! The view's onShow takes over GPS again when the menu closes
class MyMenuDelegate extends WatchUi.Menu2InputDelegate {
    var view as WindWatchView;

    function initialize(view as WindWatchView) {
        Menu2InputDelegate.initialize();
        // Warms up GPS, so "Set favourite here" gets a good fix
        Position.enableLocationEvents(
            Position.LOCATION_CONTINUOUS,
            method(:onPosition)
        );
        self.view = view;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var itemId = item.getId();
        if (itemId instanceof ListSetting) {
            // Steps in place, the menu stays open
            itemId.chooseNext();
            item.setSubLabel(itemId.chosenName());
            return;
        }
        var id = itemId as Number;
        if (id == TOGGLE_SHOWN_POSITION) {
            // Switches in place, the menu stays open
            setShowsGps((item as WatchUi.ToggleMenuItem).isEnabled());
            return;
        }
        // Closed first, so the toasts show on top of the view
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        switch (id) {
            case SET_FAVOURITE:
                setFavouriteHere();
                break;
            case RELOAD:
                view.reload();
                break;
            case CREDITS:
                WatchUi.showToast(Rez.Strings.ThanksOpenMeteo, null);
                break;
        }
    }

    private function setFavouriteHere() as Void {
        var position = getPosition();
        if (position == null) {
            WatchUi.showToast(Rez.Strings.GpsTooInaccurate, null);
            return;
        }
        setFavouritePosition(position);
        WatchUi.showToast(Rez.Strings.FavouriteSaved, null);
    }

    public function onPosition(info as Position.Info) as Void {
        System.println("MyMenuDelegate.onPosition " + info.accuracy);
    }
}

class MyBehaviorDelegate extends WatchUi.BehaviorDelegate {
    var view as WindWatchView;

    function initialize(view as WindWatchView) {
        BehaviorDelegate.initialize();
        self.view = view;
    }

    function onSelect() as Boolean {
        showMenu(view);
        return true;
    }
}

//! Switches the forecast pages on watches without the page loop
class PagingDelegate extends MyBehaviorDelegate {
    function initialize(view as WindWatchView) {
        MyBehaviorDelegate.initialize(view);
    }

    // DOWN or swiping up
    function onNextPage() as Boolean {
        view.showPage(1);
        return true;
    }

    // UP or swiping down
    function onPreviousPage() as Boolean {
        view.showPage(-1);
        return true;
    }
}

//! The menu behind START, which also opens by itself on the first start
function showMenu(view as WindWatchView) as Void {
    // A full screen menu, the ActionMenu cuts its labels to a few characters
    var menu = new WatchUi.Menu2({});
    menu.addItem(
        new WatchUi.MenuItem(
            Rez.Strings.SetFavourite,
            Rez.Strings.SetFavouriteHint,
            SET_FAVOURITE,
            {}
        )
    );
    menu.addItem(
        new WatchUi.ToggleMenuItem(
            Rez.Strings.Show,
            {
                :enabled => Rez.Strings.GpsPosition,
                :disabled => Rez.Strings.Favourite,
            },
            TOGGLE_SHOWN_POSITION,
            getShowsGps(),
            {}
        )
    );
    addListSettingItem(menu, Rez.Strings.SpeedUnitMenu, speedUnitSetting());
    addListSettingItem(menu, Rez.Strings.WindFormatMenu, windFormatSetting());
    menu.addItem(new WatchUi.MenuItem(Rez.Strings.Reload, null, RELOAD, {}));
    menu.addItem(new WatchUi.MenuItem(Rez.Strings.Credits, null, CREDITS, {}));
    WatchUi.pushView(menu, new MyMenuDelegate(view), WatchUi.SLIDE_LEFT);
}

//! An item with the chosen entry below its label, see MyMenuDelegate.onSelect
function addListSettingItem(
    menu as WatchUi.Menu2,
    label as ResourceId,
    setting as ListSetting
) as Void {
    menu.addItem(
        new WatchUi.MenuItem(label, setting.chosenName(), setting, {})
    );
}

//! In the order of SpeedUnit
function speedUnitSetting() as ListSetting {
    return new ListSetting("SpeedUnit", [
        Rez.Strings.Knots,
        Rez.Strings.KilometersPerHour,
        Rez.Strings.MetersPerSecond,
        Rez.Strings.MilesPerHour,
        Rez.Strings.Beaufort,
    ]);
}

//! In the order of WindFormat
function windFormatSetting() as ListSetting {
    return new ListSetting("WindFormat", [
        Rez.Strings.WindFormatGust,
        Rez.Strings.WindFormatBrackets,
        Rez.Strings.WindFormatDash,
    ]);
}
