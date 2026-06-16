import Toybox.System;
import Toybox.Lang;
import Toybox.WatchUi;

class PeakLineInputDelegate extends WatchUi.BehaviorDelegate {
    var _view;

    function initialize(view) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    function onNextPage() as Boolean {
        _view.increaseRange();
        return true;
    }

    function onPreviousPage() as Boolean {
        _view.decreaseRange();
        return true;
    }

    function onSelect() as Boolean {
        _view.toggleHeadingLock();
        return true;
    }

    function onBack() as Boolean {
        System.exit();
        return true;
    }

    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();
        if (key == WatchUi.KEY_UP) {
            _view.nudgeHeading(-5);
            return true;
        } else if (key == WatchUi.KEY_DOWN) {
            _view.nudgeHeading(5);
            return true;
        } else if (key == WatchUi.KEY_ENTER) {
            _view.toggleHeadingLock();
            return true;
        } else if (key == WatchUi.KEY_ESC) {
            System.exit();
            return true;
        }
        return false;
    }
}
