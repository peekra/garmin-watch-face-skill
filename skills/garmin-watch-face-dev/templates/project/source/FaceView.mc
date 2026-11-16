import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

//! Watch face view: owns data, settings, provider and renderer and drives the update cycle.
//! All drawing is delegated to FaceRenderer.
class FaceView extends WatchUi.WatchFace {
    private var _data as WatchData;
    private var _settings as FaceSettings;
    private var _provider as DataProvider;
    private var _renderer as FaceRenderer;
    private var _width as Number = 0;
    private var _height as Number = 0;
    private var _hasLayout as Boolean = false;
    private var _sleeping as Boolean = false;

    function initialize() {
        WatchFace.initialize();
        _data = new WatchData();
        _settings = new FaceSettings();
        _settings.load();
        _provider = new DataProvider();
        _renderer = new FaceRenderer();
    }

    //! Computes all geometry once per screen size.
    function onLayout(dc as Dc) as Void {
        _width = dc.getWidth();
        _height = dc.getHeight();
        _hasLayout = true;
        _renderer.computeLayout(_width, _height, _settings);
    }

    function onUpdate(dc as Dc) as Void {
        _provider.update(_data);
        if (_sleeping && isAlwaysOnActive()) {
            _renderer.drawAlwaysOn(dc, _data);
        } else {
            _renderer.drawFace(dc, _data, !_sleeping);
        }
    }

    //! High power mode (about 10 s after a wrist turn): onUpdate runs every second.
    function onExitSleep() as Void {
        _sleeping = false;
        WatchUi.requestUpdate();
    }

    //! Low power mode: onUpdate runs once per minute, no seconds.
    function onEnterSleep() as Void {
        _sleeping = true;
        WatchUi.requestUpdate();
    }

    //! Called by the app after the user changed the settings.
    function applySettings() as Void {
        _settings.load();
        if (_hasLayout) {
            _renderer.computeLayout(_width, _height, _settings);
        }
    }

    //! True only if the user switched "always on" on: requiresBurnInProtection alone is always true on
    //! AMOLED, so the display mode decides. MIP watches have no burn-in protection and keep the full face.
    private function isAlwaysOnActive() as Boolean {
        var deviceSettings = System.getDeviceSettings();
        if (!(deviceSettings has :requiresBurnInProtection) || !deviceSettings.requiresBurnInProtection) {
            return false;
        }
        if (System has :getDisplayMode) {
            return System.getDisplayMode() == System.DISPLAY_MODE_LOW_POWER;
        }
        return true;
    }
}
