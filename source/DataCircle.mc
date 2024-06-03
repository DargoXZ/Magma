import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.UserProfile;

class DataCircle extends WatchUi.Drawable {

    // Constants
    private static var mRadius = 42;
    private static var mNumPoints = 30;

    // Variables
    private var mSide;
    private var mType;
    private var mCurrent;
    private var mZones;
    private var mColors as Array<Graphics.ColorType> = [];
    private var mColor;
    private var mIcon;

    function initialize(params) {
        Drawable.initialize(params);
        mSide = params[:side];
        mType = params[:type];
        mCurrent = 0;
        if (mType == :strideRate) {
            mZones = [120, 153, 163, 173, 183, 216];
            mColors.addAll([Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_GREEN, Graphics.COLOR_BLUE, Graphics.COLOR_PINK]);
            mIcon = "0";
        } else if (mType == :heartRate) {
            mZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
            mColors.addAll([Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLUE, Graphics.COLOR_GREEN, Graphics.COLOR_ORANGE, Graphics.COLOR_RED]);
            mIcon = "3";
        }
        mColor = mColors[0];
    }

    function setValues(current) {
        var color = mColors[mColors.size() - 1];
        for (var i = 1; i < mZones.size(); i++) {
            if (current <= mZones[i]) {
                color = mColors[i - 1];
                break;
            }
        }
        mCurrent = current.toString();
        mColor = color;
    }

    function draw(dc as Dc) as Void {
        // Semi-Circle
        var r1 = gCenterX - 1;
        if (mSide == :left) {
            r1 -= gLeftMeterWidth;
        } else {
            r1 -= gRightMeterWidth;
        }
        var r2 = mRadius;
        var x1 = gCenterX; // middle circle
        var x2 = (mSide == :left) ? (gLeftMeterWidth) : (gWidth - gRightMeterWidth); // small circle
        var y = gCenterY;
        var xIntersection = ((Math.pow(r1, 2) - Math.pow(r2, 2)) + (Math.pow(x2, 2) - Math.pow(x1, 2))) / (2.0 * (x2 - x1));
        var yIntersection = Math.sqrt(Math.pow(r1, 2) - Math.pow((xIntersection - x1), 2)) + y;
        var angle1Start = Math.atan2(yIntersection - y, xIntersection - x1);
        var angle2Start = Math.atan2(yIntersection - y, xIntersection - x2);
        var angle1End = (mSide == :left) ? (Math.PI + (Math.PI - angle1Start)) : (-angle1Start);
        var angle2End = (mSide == :left) ? (-angle2Start) : (Math.PI + (Math.PI - angle2Start));
        var points = getPointsOnArc(x1, y, r1, angle1Start, angle1End, mNumPoints);
        var points2 = getPointsOnArc(x2, y, r2, angle2Start, angle2End, mNumPoints);
        for (var i = 0; i < mNumPoints; i++) {
            points.add(points2[i]);
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(points);

        // Text/Image
        var x3 = (mSide == :left) ? (x2 + r2 / 2 - 1) : (x2 - r2 / 2 + 1);
        var y3 = Math.floor(y + r2 * 0.3);
        var y4 = Math.floor(y - r2 * 0.3);
        dc.setColor(mColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x3, y3, Graphics.FONT_SYSTEM_NUMBER_MILD, mCurrent, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(x3, y4, gIconsFont, mIcon, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
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
