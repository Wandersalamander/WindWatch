import Toybox.Application;
import Toybox.Lang;
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

    //! The watch's own page loop needs Connect IQ 3.4, older watches like
    //! the fr745 switch the pages in one view
    (:typecheck(disableGlanceCheck))
    function getInitialView() as [Views] or [Views, InputDelegates] {
        if (WatchUi has :ViewLoop) {
            var pages = new WatchUi.ViewLoop(new ForecastPageFactory(), {
                :wrap => true,
            });
            return [pages, new WatchUi.ViewLoopDelegate(pages)];
        }
        var view = new WindWatchView(NEXT_HOURS_PAGE);
        return [view, new PagingDelegate(view)];
    }
}

function getApp() as WindWatchApp {
    return Application.getApp() as WindWatchApp;
}
