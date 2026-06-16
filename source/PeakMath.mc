import Toybox.Math;

module PeakMath {
    const EARTH_RADIUS_M = 6371000.0;
    const DEG_TO_RAD = Math.PI / 180.0;
    const RAD_TO_DEG = 180.0 / Math.PI;

    function degToRad(deg) {
        return deg * DEG_TO_RAD;
    }

    function radToDeg(rad) {
        return rad * RAD_TO_DEG;
    }

    function normalize360(deg) {
        var value = deg;
        while (value >= 360.0) {
            value -= 360.0;
        }
        while (value < 0.0) {
            value += 360.0;
        }
        return value;
    }

    function normalize180(deg) {
        var value = normalize360(deg);
        if (value > 180.0) {
            value -= 360.0;
        }
        return value;
    }

    function distanceMeters(lat1Deg, lon1Deg, lat2Deg, lon2Deg) {
        var lat1 = degToRad(lat1Deg);
        var lat2 = degToRad(lat2Deg);
        var dLat = degToRad(lat2Deg - lat1Deg);
        var dLon = degToRad(lon2Deg - lon1Deg);
        var avgLat = (lat1 + lat2) / 2.0;
        var x = dLon * Math.cos(avgLat);
        var y = dLat;
        return EARTH_RADIUS_M * Math.sqrt(x * x + y * y);
    }

    function bearingDegrees(lat1Deg, lon1Deg, lat2Deg, lon2Deg) {
        var lat1 = degToRad(lat1Deg);
        var lat2 = degToRad(lat2Deg);
        var dLon = degToRad(lon2Deg - lon1Deg);
        var y = Math.sin(dLon) * Math.cos(lat2);
        var x = Math.cos(lat1) * Math.sin(lat2) -
                Math.sin(lat1) * Math.cos(lat2) * Math.cos(dLon);
        return normalize360(radToDeg(Math.atan2(y, x)));
    }

    function relativeBearing(peakBearing, heading, correction) {
        return normalize180(peakBearing - heading - correction);
    }

    function e7ToDeg(value) {
        return value.toFloat() / 10000000.0;
    }
}
