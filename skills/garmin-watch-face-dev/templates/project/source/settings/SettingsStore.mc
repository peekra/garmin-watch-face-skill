import Toybox.Application;
import Toybox.Lang;

//! Property IDs (resources/settings/properties.xml) and safe access to them.
//! The only place that touches Application.Properties.
module SettingsStore {

    const BLACK_BACKGROUND = "BlackBackground";
    const SHOW_SECONDS = "ShowSeconds";
    const ACCENT = "Accent";

    const DEFAULT_BLACK_BACKGROUND = false;
    const DEFAULT_SHOW = true;
    const DEFAULT_ACCENT = UiColors.ACCENT_RED;

    //! Returns the stored Boolean, or defaultValue if the key is missing or has the wrong type.
    //! Never throws.
    function readBoolean(key as String, defaultValue as Boolean) as Boolean {
        var value = null;
        try {
            value = Application.Properties.getValue(key);
        } catch (e) {
            value = null;
        }
        return TextFormat.booleanOrDefault(value, defaultValue);
    }

    //! Stores a Boolean property (for an on-device menu). Returns false if it could not be stored.
    function writeBoolean(key as String, value as Boolean) as Boolean {
        try {
            Application.Properties.setValue(key, value);
        } catch (e) {
            return false;
        }
        return true;
    }

    //! Returns the stored index inside 0..count-1, or defaultValue if the key is missing, has the wrong
    //! type or is out of range. Never throws.
    function readIndex(key as String, count as Number, defaultValue as Number) as Number {
        var value = null;
        try {
            value = Application.Properties.getValue(key);
        } catch (e) {
            value = null;
        }
        return TextFormat.indexOrDefault(value, count, defaultValue);
    }

    //! Stores a Number property. Returns false if it could not be stored.
    function writeNumber(key as String, value as Number) as Boolean {
        try {
            Application.Properties.setValue(key, value);
        } catch (e) {
            return false;
        }
        return true;
    }
}
