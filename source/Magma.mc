import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class Magma extends WatchUi.Drawable {
    
    // Constants
    private var mColors = [Graphics.COLOR_DK_BLUE, Graphics.COLOR_BLUE, Graphics.COLOR_DK_GREEN, Graphics.COLOR_GREEN, Graphics.COLOR_YELLOW, Graphics.COLOR_ORANGE, Graphics.COLOR_RED, Graphics.COLOR_PINK];
    private var mPaces = [12, 10, 8, 7, 6, 5, 4, 0];
    private var mPadding = 5;
    private var mNumPoints = 60;

    // Variables
    private var mLapDistance;
    private var mColor;

    function initialize(params) {
        Drawable.initialize(params);
        mLapDistance = 0.0;
        mColor = mColors[0];
    }

    function setValues(lapDistance, currentSpeed) {
        var color;
        if (currentSpeed > 0) {
            var secondsPerMile = Math.floor((1.0 / currentSpeed) * 1609.344).toNumber();
            var minutes = secondsPerMile / 60;
            color = mColors[mColors.size() - 1];
            for (var i = 0; i < mColors.size(); i++) {
                if (minutes >= mPaces[i]) {
                    color = mColors[i];
                    break;
                }
            }
        } else {
            color = mColors[0];
        }
        mLapDistance = lapDistance / 1609.344;
        mColor = color;
    }

    function draw(dc as Dc) as Void {
        dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
        if (System.getDeviceSettings().screenShape != System.SCREEN_SHAPE_RECTANGLE) {
            var r = gCenterX - mPadding;
            if (gLeftMeterWidth > gRightMeterWidth) {
                r -= gLeftMeterWidth;
            } else {
                r -= gRightMeterWidth;
            }
            var x = gCenterX;
            var y1 = gCenterY; // top circle
            var y2 = Math.floor(gHeight * (1 - mLapDistance * 1.0));
            var xIntersection = Math.sqrt(Math.pow(r, 2) - Math.pow((y2 - y1), 2)) + x; // right intersection
            var angle = Math.atan2(y2 - y1, xIntersection - x);
            var points = getPointsOnArc(x, y1, r, Math.PI - angle, angle, mNumPoints);
            dc.fillPolygon(points);
        } else {
            var x = gLeftMeterWidth;
            var y = Math.floor(gHeight * (1 - mLapDistance * 1.0));
            dc.fillRectangle(x, y, gWidth - gLeftMeterWidth - gRightMeterWidth, gHeight - y);
        }
    }

    function getPointsOnArc(x, y, r, startAngle, endAngle, numPoints) {
        var points = [];
        for (var i = 0; i < numPoints; i++) {
            var angle = startAngle + (endAngle - startAngle) * (1.0 * i / (numPoints - 1));
            var pointX = Math.floor(x + r * Math.cos(angle));
            var pointY = Math.floor(y + r * Math.sin(angle));
            if (pointY < 0) {
                pointY = 0;
            } else if (pointY > gHeight) {
                pointY = gHeight;
            }
            var point = [pointX, pointY];
            points.add(point);
        }
        return points;
    }

}
