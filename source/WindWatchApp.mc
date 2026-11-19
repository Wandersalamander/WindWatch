import Toybox.Application;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;
using Toybox.Application.Storage;

(:glance)
class WindWatchApp extends Application.AppBase {
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

    //! Watches on Connect IQ 3, like the fenix 6 and fr745, switch the
    //! pages in one view, see hasPageLoop
    (:typecheck(disableGlanceCheck))
    function getInitialView() as [Views] or [Views, InputDelegates] {
        if (hasPageLoop()) {
            var pages = new WatchUi.ViewLoop(new ForecastPageFactory(), {
                :wrap => true,
            });
            return [pages, new WatchUi.ViewLoopDelegate(pages)];
        }
        var view = new WindWatchView(NEXT_HOURS_PAGE);
        return [view, new PagingDelegate(view)];
    }
}

// From this Connect IQ version on, watches run widgets as apps
const APP_WIDGETS_MAJOR_VERSION = 4;

//! Whether the app can show its pages in the watch's own page loop. Connect
//! IQ 3.4 has the ViewLoop, but runs the app as a widget, which then fails to
//! start with a type error on the fenix 6 and fr55, or stays blank on the
//! Instinct 2.
function hasPageLoop() as Boolean {
    var version = System.getDeviceSettings().monkeyVersion;
    return version[0] >= APP_WIDGETS_MAJOR_VERSION;
}

function getApp() as WindWatchApp {
    return Application.getApp() as WindWatchApp;
}
