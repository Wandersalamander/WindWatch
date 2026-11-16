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
        var id = item.getId() as Number;
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
        menu.addItem(
            new WatchUi.MenuItem(Rez.Strings.Reload, null, RELOAD, {})
        );
        menu.addItem(
            new WatchUi.MenuItem(Rez.Strings.Credits, null, CREDITS, {})
        );
        WatchUi.pushView(menu, new MyMenuDelegate(view), WatchUi.SLIDE_LEFT);
        return true;
    }
}
