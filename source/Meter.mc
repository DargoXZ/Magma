import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.UserProfile;

class Meter extends WatchUi.Drawable {

    // Constants
    private static var mBackgroundColor = Graphics.COLOR_DK_GRAY;
    private static var mNumSegments = 10;
    private static var mWidth = 8;
    private static var mHeight = 180;
    private static var mSeparator = 5;

    // Variables
    private var mSide;
    private var mType;
    private var mCurrent;
    private var mZones;
    private var mFillHeight;
    private var mColors as Array<Graphics.ColorType> = [];
    private var mSegmentHeight;
    private var mSegmentWidth;

    function initialize(params) {
        Drawable.initialize(params);
        mHeight = gHeight;
        mSide = params[:side];
        mType = params[:type];
        if (mSide == :left) {
            gLeftMeterWidth = mWidth;
        } else {
            gRightMeterWidth = mWidth;
        }
        mCurrent = 0.0;
        mColors.add(Graphics.COLOR_BLACK);
        if (mType == :strideRate) {
            mZones = [120, 153, 163, 173, 183, 216];
            mColors.addAll([Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_GREEN, Graphics.COLOR_BLUE, Graphics.COLOR_PINK]);
        } else if (mType == :heartRate) {
            mZones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_RUNNING);
            mColors.addAll([Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLUE, Graphics.COLOR_GREEN, Graphics.COLOR_ORANGE, Graphics.COLOR_RED]);
        }
        mFillHeight = 0.0;

        mSegmentHeight = 1.0 * (mHeight - ((mNumSegments - 1) * mSeparator)) / mNumSegments;
		if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE) {
			mSegmentWidth = mWidth;
		} else {
			var innerRadius = gCenterX - mWidth;
			mSegmentWidth = gCenterX - Math.sqrt(Math.pow(innerRadius, 2) - Math.pow(mHeight / 2, 2));
			mSegmentWidth = Math.ceil(mSegmentWidth).toNumber();
		}
    }

    function setValues(current) {
        mCurrent = current;
        updateFillHeight();
    }

    function updateFillHeight() {
        if (mCurrent < mZones[0]) {
            mFillHeight = 0;
            return;
        }
        var zonesFilled = 0.0;
        for (var i = 1; i < mZones.size(); i++) {
            if (mCurrent > mZones[i]) {
                zonesFilled += 1;
            } else {
                zonesFilled += 1.0 * (mCurrent - mZones[i - 1]) / (mZones[i] - mZones[i - 1]);
                break;
            }
        }
        var segmentsPerZone = 1.0 * mNumSegments / (mZones.size() - 1);
        var segmentsFilled = zonesFilled * segmentsPerZone;
        if (segmentsFilled > mNumSegments) {
            segmentsFilled = mNumSegments;
        }
        var segmentHeight = segmentsFilled * mSegmentHeight;
        var separatorHeight = Math.floor(segmentsFilled - 1) * mSeparator;
        if (separatorHeight < 0) {
            separatorHeight = 0;
        }
        mFillHeight = segmentHeight + separatorHeight;
    }

    function draw(dc as Dc) as Void {
        var x = (mSide == :left) ? 0 : (gWidth - mSegmentWidth);
        var y = (gHeight - mHeight) / 2;
        drawSegments(dc, x, y, mFillHeight, mHeight);
        drawCenterCircle(dc);
    }

    function drawCenterCircle(dc as Dc) {
        if (System.getDeviceSettings().screenShape != System.SCREEN_SHAPE_RECTANGLE) {
            var r = gCenterX - mWidth;
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(gCenterX, mHeight / 2, r);
        }
    }

    function drawSegments(dc as Dc, x, y, totalFillHeight, maxHeight) {
        y += maxHeight;
        var segmentStart = 0.0;
        var segmentEnd;
        for (var i = 0; i < mNumSegments; i++) {
            var color = mColors[i * (mColors.size() - 1) / mNumSegments + 1];
            segmentEnd = segmentStart + mSegmentHeight;
            var fillStart = segmentStart;
            var fillEnd = segmentEnd;
            if (segmentEnd >= totalFillHeight) {
                fillEnd = totalFillHeight;
            }
            var fillHeight = fillEnd - fillStart;
            if (fillHeight < 0) {
                fillHeight = 0;
            }
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x, Math.round(y - fillStart - fillHeight), mSegmentWidth, fillHeight);
            dc.setColor(mBackgroundColor, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(x, Math.round(y - fillStart - mSegmentHeight), mSegmentWidth, mSegmentHeight - fillHeight);
            segmentStart = segmentEnd + mSeparator;
        }
    }
}
