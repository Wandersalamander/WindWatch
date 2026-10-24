import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

// Lakes that Alplakes splits into basins, which would otherwise show the same name
const BASIN_NAMES as Dictionary<String, String> = {
    "upperconstance" => "Obersee",
    "lowerconstance" => "Untersee",
    "lucernekreuztrichterandvitznauerbecken" => "Kreuztrichter & Vitznau",
    "lucerneurnersee" => "Urnersee",
    "lucernegersauerandtreibbecken" => "Gersau & Treib",
};
const NEIGHBOUR_COLOR = Graphics.COLOR_LT_GRAY;

//! Shows all lakes, starting at the favourite, to choose a new favourite from.
//! A view of its own: a menu with an item per lake runs out of memory on 64kB
//! widgets, and the system picker is white on some watches.
function showLakeList(view as LakeWindView) as Void {
    var list = new LakeListView();
    WatchUi.pushView(
        list,
        new LakeListDelegate(list, view),
        WatchUi.SLIDE_LEFT
    );
}

class LakeListView extends WatchUi.View {
    // [name, latitude, longitude] per lake, see scripts/generate_lake_resources.py
    private var _lakes as Array<[String, Float, Float]>;
    private var _selected as Number;

    function initialize() {
        View.initialize();
        _lakes =
            WatchUi.loadResource(Rez.JsonData.LakeChoices) as
            Array<[String, Float, Float]>;
        _selected = indexOf(getFavouriteLake());
    }

    function selectedLake() as [String, Float, Float] {
        return _lakes[_selected];
    }

    //! Moves the selection by the steps, wrapping around at both ends
    function move(steps as Number) as Void {
        _selected = (_selected + steps + _lakes.size()) % _lakes.size();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        var lineHeight = dc.getFontHeight(LARGE_TEXT_FONT);
        var centerTop = (dc.getHeight() - lineHeight) / 2;
        // Close above the lakes, where round screens are wide enough for it
        var titleTop =
            centerTop - lineHeight - 1.5 * dc.getFontHeight(SMALL_TEXT_FONT);
        drawFittedLine(
            dc,
            titleTop,
            SMALL_TEXT_FONT,
            WatchUi.loadResource(Rez.Strings.ChooseFavourite) as String
        );
        drawFittedLine(dc, centerTop, LARGE_TEXT_FONT, lakeLabel(0));
        var basin = BASIN_NAMES[selectedLake()[0]];
        if (basin != null) {
            drawFittedLine(dc, centerTop + lineHeight, SMALL_TEXT_FONT, basin);
        }
        dc.setColor(NEIGHBOUR_COLOR, Graphics.COLOR_TRANSPARENT);
        drawFittedLine(
            dc,
            centerTop - lineHeight,
            SMALL_TEXT_FONT,
            lakeLabel(-1)
        );
        drawFittedLine(
            dc,
            centerTop + 2 * lineHeight,
            SMALL_TEXT_FONT,
            lakeLabel(1)
        );
    }

    private function lakeLabel(offset as Number) as String {
        var index = (_selected + offset + _lakes.size()) % _lakes.size();
        return readableLakeName(_lakes[index][0]);
    }

    private function indexOf(lake as String) as Number {
        for (var i = 0; i < _lakes.size(); i++) {
            if (_lakes[i][0].equals(lake)) {
                return i;
            }
        }
        return 0;
    }
}

class LakeListDelegate extends WatchUi.BehaviorDelegate {
    private var _list as LakeListView;
    private var _view as LakeWindView;

    function initialize(list as LakeListView, view as LakeWindView) {
        BehaviorDelegate.initialize();
        _list = list;
        _view = view;
    }

    function onNextPage() as Boolean {
        _list.move(1);
        return true;
    }

    function onPreviousPage() as Boolean {
        _list.move(-1);
        return true;
    }

    //! The lake's center becomes the favourite position, so the wind is
    //! taken in the middle of the lake
    function onSelect() as Boolean {
        var lake = _list.selectedLake();
        setFavouriteLake(lake[0]);
        setFavouritePosition([lake[1].toDouble(), lake[2].toDouble()]);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.showToast(readableLakeName(lake[0]), null);
        _view.notifyFullUpdate();
        return true;
    }
}
