import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

//! On-device settings menu, shown by the system for "Customize" in the watch face menu
//! (AppBase.getSettingsView()). Item ids are the property keys. Same order as the phone settings.
//! Built once per opening; allocations are fine here because it is not the face's draw path.
class SettingsMenu extends WatchUi.Menu2 {

    function initialize() {
        Menu2.initialize({ :title => Rez.Strings.AppName });
        addItem(new WatchUi.ToggleMenuItem(Rez.Strings.BlackBackgroundTitle, null, SettingsStore.BLACK_BACKGROUND,
            SettingsStore.readBoolean(SettingsStore.BLACK_BACKGROUND, SettingsStore.DEFAULT_BLACK_BACKGROUND), null));
        addItem(new WatchUi.MenuItem(Rez.Strings.AccentTitle, accentLabel(SettingsStore.readIndex(
            SettingsStore.ACCENT, UiColors.ACCENT_COUNT, SettingsStore.DEFAULT_ACCENT)), SettingsStore.ACCENT, null));
        addItem(new WatchUi.ToggleMenuItem(Rez.Strings.ShowSecondsTitle, null, SettingsStore.SHOW_SECONDS,
            SettingsStore.readBoolean(SettingsStore.SHOW_SECONDS, SettingsStore.DEFAULT_SHOW), null));
    }

    //! Name of an accent colour (UiColors.ACCENT_*).
    static function accentLabel(accent as Number) as ResourceId {
        if (accent == UiColors.ACCENT_BLUE) {
            return Rez.Strings.AccentBlue;
        }
        return accent == UiColors.ACCENT_GREEN ? Rez.Strings.AccentGreen : Rez.Strings.AccentRed;
    }
}

//! Stores each change at once and lets the app apply it, so the face behind the menu is already right.
class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId();
        if (!(id instanceof String)) {
            return;
        }
        if (item instanceof WatchUi.ToggleMenuItem) {
            SettingsStore.writeBoolean(id, item.isEnabled());
        } else if (id.equals(SettingsStore.ACCENT)) {
            // Each press selects the next colour; the sub label shows the choice.
            var next = (SettingsStore.readIndex(SettingsStore.ACCENT, UiColors.ACCENT_COUNT,
                SettingsStore.DEFAULT_ACCENT) + 1) % UiColors.ACCENT_COUNT;
            SettingsStore.writeNumber(id, next);
            item.setSubLabel(SettingsMenu.accentLabel(next));
            WatchUi.requestUpdate();
        }
        Application.getApp().onSettingsChanged();
    }
}
