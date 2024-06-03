import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;
using Toybox.System as Sys;

// Global Variables
var gBackgroundColor;
var gWidth;
var gHeight;
var gCenterX;
var gCenterY;
var gMeterPadding;
var gLeftMeterWidth;
var gRightMeterWidth;
var gIconsFont;

class MagmaView extends WatchUi.DataField {

    private var mDrawables as Array<Drawable> = [];
    private var mDistance;
    private var mTime;
    private var mLastLapDistance;

    function initialize() {
        DataField.initialize();
        gBackgroundColor = Graphics.COLOR_BLACK;
        gWidth = Sys.getDeviceSettings().screenWidth;
        gHeight = Sys.getDeviceSettings().screenHeight;
        gIconsFont = WatchUi.loadResource(Rez.Fonts.IconsFont);
        gCenterX = gWidth / 2;
        gCenterY = gHeight / 2;
        mDistance = 0.0f;
        mTime = 0;
        mLastLapDistance = 0.0f;
    }

    function onLayout(dc as Dc) as Void {
        View.setLayout(Rez.Layouts.MainLayout(dc));
        cacheDrawables();
    }

    function cacheDrawables() {
        mDrawables.add(View.findDrawableById("Magma"));
        mDrawables.add(View.findDrawableById("LeftDataCircle"));
        mDrawables.add(View.findDrawableById("RightDataCircle"));
        mDrawables.add(View.findDrawableById("LeftMeter"));
        mDrawables.add(View.findDrawableById("RightMeter"));
        mDrawables.add(View.findDrawableById("DistanceBox"));
        mDrawables.add(View.findDrawableById("TimeBox"));
        mDrawables.add(View.findDrawableById("PaceBox"));
    }

    function compute(info as Activity.Info) as Void {
        if (info == null || mDrawables.size() < 8) {
            return;
        }
        var cadence = (info has :currentCadence && (info.currentCadence != null)) ? info.currentCadence : 0; // rpm
        var heartRate = (info has :currentHeartRate && (info.currentHeartRate != null)) ? info.currentHeartRate : 0; // bpm
        mDistance = (info has :elapsedDistance && (info.elapsedDistance != null)) ? info.elapsedDistance : 0.0f; // m
        mTime = (info has :timerTime && (info.timerTime != null)) ? info.timerTime : 0; // ms
        var currentSpeed = (info has :currentSpeed && (info.currentSpeed != null)) ? info.currentSpeed : 0.0f; // m/s
        
        var lapDistance = mDistance - mLastLapDistance;
        
        (mDrawables[0] as Magma).setValues(lapDistance, currentSpeed);
        (mDrawables[1] as DataCircle).setValues(cadence);
        (mDrawables[2] as DataCircle).setValues(heartRate);
        (mDrawables[3] as Meter).setValues(cadence);
        (mDrawables[4] as Meter).setValues(heartRate);
        (mDrawables[5] as DataBox).setValues(mDistance);
        (mDrawables[6] as DataBox).setValues(mTime);
        (mDrawables[7] as DataBox).setValues(currentSpeed);
    }

    function onUpdate(dc as Dc) as Void {
        View.onUpdate(dc);
    }

    function onTimerLap() {
        mLastLapDistance = mDistance;
    }
}
