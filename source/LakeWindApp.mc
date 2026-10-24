import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Activity;
using Toybox.Application.Storage;

(:glance)
class LakeWindApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function getGlanceView() {
        return [new WidgetGlanceView()];
    }

    // Shows a changed speed unit right away
    function onSettingsChanged() as Void {
        WatchUi.requestUpdate();
    }

    (:typecheck(disableGlanceCheck))
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var pages = new WatchUi.ViewLoop(new ForecastPageFactory(), {
            :wrap => true,
        });
        return [pages, new WatchUi.ViewLoopDelegate(pages)];
    }
}

function getApp() as LakeWindApp {
    return Application.getApp() as LakeWindApp;
}
