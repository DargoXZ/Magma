import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class DataBox extends WatchUi.Drawable {

    // Constants
    private static var mOutlineColor = 0x36454F;
    private static var mTextColor = 0xC8C8C8;
    private static var mWidth = 100;
    private static var mHeight = 25;
    private static var mRadius = 5;
    private static var mSmallWidth = 60;
    private static var mSmallHeight = 15;
    private static var mSmallRadius = 3;
    private static var mOverlap = 0;
    private static var mPadding = 2;

    // Variables
    private var mLocY;
    private var mType;
    private var mCurrent;
    private var mTitle;

    function initialize(params) {
        Drawable.initialize(params);
        mLocY = params[:locY];
        mType = params[:type];
        if (mType == :distance) {
            mTitle = "Distance";
        } else if (mType == :time) {
            mTitle = "Time";
        } else if (mType == :pace) {
            mTitle = "Pace";
        }
        setValues(0);
    }

    function setValues(current) {
        if (mType == :distance) {
            var miles = current / 1609.344;
            mCurrent = miles.format("%.2f");
        } else if (mType == :time) {
            var hours;
            var minutes;
            var seconds;
            hours = (current / 3600000);
            current -= hours * 36000000;
            if (hours > 0) {
                hours = hours.toString + ":";
            } else {
                hours = "";
            }
            minutes = (current / 60000);
            current -= minutes * 60000;
            seconds = (current / 1000);
            mCurrent = hours + minutes.format("%01d") + ":" + seconds.format("%02d");
        } else if (mType == :pace) {
            if (current == 0) {
                mCurrent = "--:--";
            } else {
                var secondsPerMile = Math.floor((1.0 / current) * 1609.344).toNumber();
                var minutes = secondsPerMile / 60;
                if (minutes >= 60) {
                    mCurrent = "--:--";
                } else {
                    var seconds = secondsPerMile % 60;
                    mCurrent = minutes.toString() + ":" + seconds.format("%02d");
                }
            }
        } else {
            mCurrent = current;
        }
    }

    function draw(dc as Dc) as Void {
        var height = mHeight + mSmallHeight - mOverlap;
        var x1 = gCenterX - mWidth / 2;
        var x2 = gCenterX - mSmallWidth / 2;
        var y2 = gCenterY + mLocY - height / 2;
        var y1 = y2 + mSmallHeight - mOverlap;

        // Main Box
        dc.setColor(mOutlineColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x1 - mPadding, y1 - mPadding, mWidth + mPadding * 2, mHeight + mPadding * 2, mRadius); // Outline
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x1, y1, mWidth, mHeight, mRadius); // Actual box
        dc.setColor(mTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x1 + mWidth / 2, y1 + mHeight / 2 + mOverlap / 2, Graphics.FONT_SYSTEM_NUMBER_MILD, mCurrent, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Title Box
        dc.setColor(mOutlineColor, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x2 - mPadding, y2 - mPadding, mSmallWidth + mPadding * 2, mSmallHeight + mPadding * 2, mSmallRadius); // Outline
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.fillRoundedRectangle(x2, y2, mSmallWidth, mSmallHeight, mSmallRadius); // Actual box
        dc.setColor(mTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x2 + mSmallWidth / 2, y2 + mSmallHeight / 2 - 1, Graphics.FONT_SYSTEM_SMALL, mTitle, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

}
