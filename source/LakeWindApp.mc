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

    // Return the initial view of your application here
    (:typecheck(disableGlanceCheck))
    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new LakeWindView();
        var delegate = new MyBehaviorDelegate(view);
        return [view, delegate];
    }
}

function getApp() as LakeWindApp {
    return Application.getApp() as LakeWindApp;
}
