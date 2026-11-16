import Toybox.Graphics;
import Toybox.Lang;

//! Only entry point of the view into the UI. computeLayout() does all geometry, draw*() only draws.
class FaceRenderer {
    private const CENTER = Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER;

    private var _diameter as Number = 0;
    private var _centerX as Number = 0;
    private var _dateY as Number = 0;
    private var _timeY as Number = 0;
    private var _secondsY as Number = 0;
    private var _dataY as Number = 0;
    private var _heartRateX as Number = 0;
    private var _stepsX as Number = 0;
    private var _statusY as Number = 0;
    private var _statusDotR as Number = 1;
    private var _alwaysOnShift as Number = 0;
    private var _showSeconds as Boolean = true;

    function initialize() {
    }

    //! From View.onLayout() and after a settings change. Allocations are allowed here, never in draw*().
    function computeLayout(width as Number, height as Number, settings as FaceSettings) as Void {
        _diameter = width < height ? width : height;
        _centerX = width / 2;
        _dateY = at(UiSizes.DATE_Y);
        _timeY = at(UiSizes.TIME_Y);
        _secondsY = at(UiSizes.SECONDS_Y);
        _dataY = at(UiSizes.DATA_Y);
        _heartRateX = at(UiSizes.HEART_RATE_X);
        _stepsX = at(UiSizes.STEPS_X);
        _statusY = at(UiSizes.STATUS_Y);
        var dotR = at(UiSizes.STATUS_DOT_R);
        _statusDotR = dotR > 1 ? dotR : 1;
        _alwaysOnShift = at(UiSizes.ALWAYS_ON_SHIFT);
        _showSeconds = settings.showSeconds;
        UiColors.apply(settings.blackBackground, settings.accent);
    }

    //! Full face. highPower == false: no seconds.
    function drawFace(dc as Graphics.Dc, data as WatchData, highPower as Boolean) as Void {
        dc.setColor(UiColors.ink, UiColors.background);
        dc.clear();

        dc.drawText(_centerX, _dateY, Graphics.FONT_XTINY,
            TextFormat.date(data.day, data.month, data.year), CENTER);
        dc.drawText(_centerX, _timeY, Graphics.FONT_NUMBER_HOT,
            TextFormat.pad2(data.hour) + ":" + TextFormat.pad2(data.minute), CENTER);
        if (highPower && _showSeconds) {
            dc.setColor(UiColors.accent, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_centerX, _secondsY, Graphics.FONT_TINY, TextFormat.pad2(data.second), CENTER);
            dc.setColor(UiColors.ink, Graphics.COLOR_TRANSPARENT);
        }
        dc.drawText(_heartRateX, _dataY, Graphics.FONT_XTINY,
            TextFormat.numberOrDash(data.heartRate) + " bpm", CENTER);
        dc.drawText(_stepsX, _dataY, Graphics.FONT_XTINY,
            TextFormat.numberOrDash(data.steps), CENTER);
        if (data.phoneConnected) {
            dc.fillCircle(_centerX, _statusY, _statusDotR);
        }
    }

    //! Always-on: only HH:MM, dim on black, shifted every minute so no pixel stays lit for long.
    function drawAlwaysOn(dc as Graphics.Dc, data as WatchData) as Void {
        dc.setColor(UiColors.ALWAYS_ON_INK, Graphics.COLOR_BLACK);
        dc.clear();
        var step = data.minute % 5 - 2;   // -2..2
        dc.drawText(_centerX + step * _alwaysOnShift, _timeY + step * _alwaysOnShift,
            Graphics.FONT_NUMBER_MEDIUM,
            TextFormat.pad2(data.hour) + ":" + TextFormat.pad2(data.minute), CENTER);
    }

    //! Fraction of the diameter in pixels.
    private function at(fraction as Float) as Number {
        return (_diameter * fraction + 0.5).toNumber();
    }
}
