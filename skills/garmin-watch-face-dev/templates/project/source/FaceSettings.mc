import Toybox.Lang;

//! Typed copy of the user settings with defaults. load() never throws.
class FaceSettings {
    // false = light face (default), true = dark face
    public var blackBackground as Boolean = false;
    public var showSeconds as Boolean = true;
    // UiColors.ACCENT_*
    public var accent as Number = SettingsStore.DEFAULT_ACCENT;

    function initialize() {
    }

    //! Reads all settings from the application properties.
    function load() as Void {
        blackBackground = SettingsStore.readBoolean(
            SettingsStore.BLACK_BACKGROUND, SettingsStore.DEFAULT_BLACK_BACKGROUND);
        showSeconds = SettingsStore.readBoolean(SettingsStore.SHOW_SECONDS, SettingsStore.DEFAULT_SHOW);
        accent = SettingsStore.readIndex(SettingsStore.ACCENT, UiColors.ACCENT_COUNT, SettingsStore.DEFAULT_ACCENT);
    }
}
