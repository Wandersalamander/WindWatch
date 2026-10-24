using Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.Application.Storage;
import Toybox.Position;

enum {
    GPS,
    CHOOSE_LAKE,
    UPDATE_ALL,
    CREDITS,
}

class MyMenuDelegate extends WatchUi.Menu2InputDelegate {
    var view as LakeWindView;

    function initialize(view as LakeWindView) {
        System.println("MyMenuDelegate.initialize");
        Menu2InputDelegate.initialize();
        // Start aquiring GPS position, so that on button press the GPS-quality might be okay alread
        Position.enableLocationEvents(
            Position.LOCATION_CONTINUOUS,
            method(:onPosition)
        );
        self.view = view;
    }
    function onBack() as Void {
        System.println("MyMenuDelegate.onBack");
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        // disable GPS
        Position.enableLocationEvents(
            Position.LOCATION_DISABLE,
            method(:onPosition)
        );
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        System.println("MyMenuDelegate.onSelect");
        // Closed first, so the toasts show on top of the lake view
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        if (item has :getId) {
            var Id = item.getId();
            if (Id != null) {
                var position_lat_long = getPosition();
                switch (Id) {
                    case GPS:
                        var newFavouriteLake = getClosesLake(position_lat_long);
                        if (
                            position_lat_long != null and
                            newFavouriteLake != null
                        ) {
                            setFavouritePosition(position_lat_long);
                            setFavouriteLake(newFavouriteLake);
                            WatchUi.showToast(
                                readableLakeName(newFavouriteLake),
                                null
                            );
                            self.view.notifyFullUpdate();
                        } else {
                            WatchUi.showToast(
                                Rez.Strings.GpsTooInaccurate,
                                null
                            );
                        }
                        break; // mandatory, otherwise next case also executed
                    case CHOOSE_LAKE:
                        showLakeList(self.view);
                        break; // mandatory, otherwise next case also executed
                    case CREDITS:
                        WatchUi.showToast(Rez.Strings.ThanksOpenMeteo, null);
                        break; // mandatory, otherwise next case also executed
                    case UPDATE_ALL:
                        self.view.notifyFullUpdate();
                        break; // mandatory, otherwise next case also executed
                }
            }
            // disable GPS
        }
        Position.enableLocationEvents(
            Position.LOCATION_DISABLE,
            method(:onPosition)
        );
    }
    public function onPosition(info as Info) as Void {
        System.println("MyMenuDelegate.onPosition");
        System.println("info.accuracy");
        System.println(info.accuracy);
    }
}

class MyBehaviorDelegate extends WatchUi.BehaviorDelegate {
    var view as LakeWindView;
    function initialize(view as LakeWindView) {
        System.println("MyBehaviorDelegate.initialize");
        BehaviorDelegate.initialize();
        self.view = view;
    }

    function onSelect() {
        System.println("MyBehaviorDelegate.onSelect");
        // A full screen menu, the ActionMenu cuts its labels to a few characters
        var menu = new WatchUi.Menu2({});
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.SetFavourite,
                Rez.Strings.SetFavouriteHint,
                GPS,
                {}
            )
        );
        menu.addItem(
            new WatchUi.MenuItem(
                Rez.Strings.ChooseFavourite,
                Rez.Strings.ChooseFavouriteHint,
                CHOOSE_LAKE,
                {}
            )
        );
        menu.addItem(
            new WatchUi.MenuItem(Rez.Strings.Reload, null, UPDATE_ALL, {})
        );
        menu.addItem(
            new WatchUi.MenuItem(Rez.Strings.Credits, null, CREDITS, {})
        );
        WatchUi.pushView(
            menu,
            new MyMenuDelegate(self.view),
            WatchUi.SLIDE_LEFT
        );
        return true;
    }
}
