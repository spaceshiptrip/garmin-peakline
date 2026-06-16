import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;

class PeakLineView extends WatchUi.View {
    const BG_COLOR = 0x0B1018;
    const LINE_COLOR = 0xD8DDE6;
    const MUTED_COLOR = 0x8A93A3;
    const PEAK_COLOR = 0xFFFFFF;
    const ACCENT_COLOR = 0x1EA7FF;
    const WINDOW_DEG = 90.0;
    const MAX_LABELS = 10;
    const METERS_PER_MILE = 1609.344;

    var _heading = 52.0;
    var _rangeIndex = 2;
    var _headingLocked = false;
    var _ranges = [5, 15, 30, 60, 100];

    function initialize() {
        View.initialize();
    }

    function onLayout(dc as Graphics.Dc) as Void {
    }

    function onShow() as Void {
    }

    function onHide() as Void {
    }

    function increaseRange() as Void {
        if (_rangeIndex < _ranges.size() - 1) {
            _rangeIndex++;
        }
        WatchUi.requestUpdate();
    }

    function decreaseRange() as Void {
        if (_rangeIndex > 0) {
            _rangeIndex--;
        }
        WatchUi.requestUpdate();
    }

    function nudgeHeading(delta) as Void {
        _heading = PeakMath.normalize360(_heading + delta);
        WatchUi.requestUpdate();
    }

    function toggleHeadingLock() as Void {
        _headingLocked = !_headingLocked;
        WatchUi.requestUpdate();
    }

    function headingLabel(deg) {
        var dirs = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
        var index = ((PeakMath.normalize360(deg) + 22.5) / 45.0).toNumber() % 8;
        return dirs[index];
    }

    function absFloat(value) {
        return value < 0.0 ? -value : value;
    }

    function drawCentered(dc, x, y, font, text, color) as Void {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function drawStatus(dc, w, h) as Void {
        var rangeMi = _ranges[_rangeIndex];
        drawCentered(dc, w / 2, 16, Graphics.FONT_MEDIUM, "PeakLine", ACCENT_COLOR);
        drawCentered(dc, w / 2, 48, Graphics.FONT_SMALL,
                     headingLabel(_heading) + " " + _heading.toNumber().format("%03d") + " deg",
                     PEAK_COLOR);
        drawCentered(dc, w / 2, h - 48, Graphics.FONT_XTINY,
                     "Range " + rangeMi + " mi | Demo location",
                     MUTED_COLOR);
        drawCentered(dc, w / 2, h - 28, Graphics.FONT_XTINY,
                     _headingLocked ? "SELECT unlock | UP/DOWN heading" : "SELECT lock | UP/DOWN heading",
                     MUTED_COLOR);
    }

    function drawCompassMarks(dc, w, horizonY, leftX, rightX) as Void {
        var halfWindow = WINDOW_DEG / 2.0;
        for (var offset = -45; offset <= 45; offset += 15) {
            var markBearing = PeakMath.normalize360(_heading + offset);
            var x = (w / 2 + (offset.toFloat() / halfWindow) * ((rightX - leftX) / 2)).toNumber();
            var major = (offset % 45) == 0;
            dc.setColor(major ? LINE_COLOR : MUTED_COLOR, Graphics.COLOR_TRANSPARENT);
            dc.setPenWidth(major ? 2 : 1);
            dc.drawLine(x, horizonY - (major ? 12 : 7), x, horizonY + (major ? 12 : 7));
            if (major) {
                drawCentered(dc, x, horizonY + 15, Graphics.FONT_XTINY, headingLabel(markBearing), MUTED_COLOR);
            }
        }
    }

    function drawPeak(dc, x, horizonY, labelY, name, distanceMi) as Void {
        dc.setColor(ACCENT_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(x, horizonY - 24, x, horizonY + 2);
        dc.fillCircle(x, horizonY - 24, 3);

        drawCentered(dc, x, labelY, Graphics.FONT_XTINY, name, PEAK_COLOR);
        drawCentered(dc, x, labelY + 18, Graphics.FONT_XTINY, distanceMi.toNumber() + " mi", MUTED_COLOR);
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;
        var horizonY = h / 2 + 28;
        var leftX = 22;
        var rightX = w - 22;
        var halfWindow = WINDOW_DEG / 2.0;
        var rangeM = _ranges[_rangeIndex].toFloat() * METERS_PER_MILE;

        dc.setColor(BG_COLOR, BG_COLOR);
        dc.clear();

        drawStatus(dc, w, h);

        dc.setColor(LINE_COLOR, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(2);
        dc.drawLine(leftX, horizonY, rightX, horizonY);
        drawCompassMarks(dc, w, horizonY, leftX, rightX);

        var userLat = PeakMath.e7ToDeg(PeakData.CENTER_LAT_E7);
        var userLon = PeakMath.e7ToDeg(PeakData.CENTER_LON_E7);
        var labelsDrawn = 0;

        for (var i = 0; i < PeakData.PEAKS.size(); i++) {
            var peak = PeakData.PEAKS[i];
            var peakLat = PeakMath.e7ToDeg(peak[0]);
            var peakLon = PeakMath.e7ToDeg(peak[1]);
            var distanceM = PeakMath.distanceMeters(userLat, userLon, peakLat, peakLon);
            if (distanceM > rangeM) {
                continue;
            }

            var bearing = PeakMath.bearingDegrees(userLat, userLon, peakLat, peakLon);
            var relative = PeakMath.relativeBearing(bearing, _heading, 0.0);
            if (absFloat(relative) > halfWindow) {
                continue;
            }

            var x = (cx + (relative / halfWindow) * ((rightX - leftX) / 2)).toNumber();
            var row = labelsDrawn % 3;
            var labelY = horizonY - 92 - row * 30;
            var distanceMi = distanceM / METERS_PER_MILE;
            drawPeak(dc, x, horizonY, labelY, peak[4], distanceMi);

            labelsDrawn++;
            if (labelsDrawn >= MAX_LABELS) {
                break;
            }
        }

        if (labelsDrawn == 0) {
            drawCentered(dc, cx, horizonY - 70, Graphics.FONT_SMALL, "No peaks in window", MUTED_COLOR);
        }
    }
}
