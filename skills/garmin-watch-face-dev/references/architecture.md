# Project structure and classes

## Folder layout

```
manifest.xml              # app type watchface, id (UUID), entry class, minApiLevel, products, permissions, languages
monkey.jungle             # build configuration: source path, per-device annotations and resource paths
source/                   # logic: App, View, Delegate, WatchData, DataProvider, FaceSettings, pure helper modules
source/settings/          # on-device menu: SettingsMenu, delegates, SettingsStore
source/ui/                # drawing only: FaceRenderer, layout, drawers, fonts, colours, sizes
resources/                # drawables/ (launcher icon), strings/ (default language), settings/properties.xml
resources-<lang>/         # translated strings, e.g. resources-deu/
resources-settings-*/     # settings.xml variants, chosen per device in monkey.jungle (only if needed)
resources-round-<D>x<D>/  # per-resolution resources, e.g. bitmap fonts (only if scaling is not enough)
tests/                    # unit tests, every class or function annotated (:test)
scripts/                  # build.sh, test.sh, run.sh, package.sh, install-watch.sh, devices.sh, env.sh
design/                   # reference pictures, drafts, screenshots, store/ (store material, see store-release.md)
bin/                      # build output, not in git
CLAUDE.md                 # spec, decisions, interface, team rules
STATUS.md                 # current state for the next session
```

## Classes (logic)

| Class / module | Task |
|---|---|
| `<Name>App` (`AppBase`) | `getInitialView()` returns view and delegate. `onSettingsChanged()` reloads `FaceSettings`, recomputes the layout, requests an update. `getSettingsView()` returns the on-device menu |
| `<Name>View` (`WatchFace`) | Life cycle. Owns the single `WatchData`, the `DataProvider`, the `FaceRenderer` and the animation timer. Decides between full face and always-on view |
| `<Name>Delegate` (`WatchFaceDelegate`) | `onPress` (touch and hold) asks the view whether the point hits an element. `onPowerBudgetExceeded` if partial updates are used |
| `WatchData` | Plain data object. One instance, updated in place. Metrics are nullable: `null` means "not available" |
| `DataProvider` | Fills `WatchData` from the APIs, each read guarded. Slow or rarely changing sources are read at most once per minute and only if a visible field needs them |
| `ComplicationSource` | Subscribes to `Toybox.Complications`, keeps the last values, offers `exitTo...()` to open a system view (one per element, or `exitToKind(kind)` when selectable fields are pressable). Never throws |
| `FaceSettings` | Typed copy of the properties with defaults. `load()` never throws |
| `SettingsStore` | The only place that touches `Application.Properties`, with try/catch, typed getters with default, setters returning success |
| `DataKind` | Constants for selectable data kinds. They are stored in properties, so the numbers never change |
| `DataConversions`, `TextFormat`, animation timing modules | Pure functions without API calls. This is where most unit tests go |
| `DisplayType`, `DeviceSports` ... | Compile-time capability constants selected by annotations (see below) |

## Classes (UI)

| Class / module | Task |
|---|---|
| `FaceRenderer` | Only entry point of the view into the UI. `computeLayout()`, `drawFace()`, `drawAlwaysOn()`, hit tests |
| `LayoutEngine` or `FaceLayout` | Geometry. Two proven variants, see below |
| `FontSet` | Loads fonts once. Vector fonts with built-in fallback, or bitmap fonts per resolution |
| `UiColors` | Palettes per background and display type, selectable colours as tables. `apply(dark, accent)` sets the active colours. Checked by `tests/ColorTest.mc` |
| `UiSizes` | All proportions as fractions of the diameter |
| Drawers (`CounterDrawer`, `GaugeDrawer`, `FieldBox`, `AlwaysOnDrawer` ...) | One element each. `setup(...)` precomputes points and sizes, `draw(dc, ...)` only draws. Icons: vector drawers for two-colour icons, bitmap icon fonts for single-colour ones (see best-practices, "Sharp graphics and icons") |

## The interface between logic and UI

Write it into `CLAUDE.md` before coding. The UI never calls a sensor API, the logic never draws.

```monkeyc
class WatchData {
    public var hour as Number = 0;      // 0..23
    public var minute as Number = 0;
    public var second as Number = 0;
    public var heartRate as Number or Null = null;   // null -> UI shows "--"
    public var steps as Number or Null = null;
    public var phoneConnected as Boolean = false;
    // ... one field per value of the spec
}

class FaceSettings {
    public var blackBackground as Boolean = false;
    public var accent as Number;         // index into the UiColors tables, if colours are selectable
    public var showDate as Boolean = true;
    public var slots as Array<Number>;   // DataKind per slot, if fields are selectable
    function load() as Void;             // reads the properties, never throws
}

class FaceRenderer {
    function initialize();   // settings-independent work (font loading) goes here, see watchdog rule
    // From View.onLayout() and after onSettingsChanged(). Allocations are allowed here, never in draw*().
    function computeLayout(width as Number, height as Number, settings as FaceSettings) as Void;
    // highPower == false: no seconds, no animation.
    function drawFace(dc as Graphics.Dc, data as WatchData, highPower as Boolean) as Void;
    // Always-on: minimal content, position shifted every minute.
    function drawAlwaysOn(dc as Graphics.Dc, data as WatchData) as Void;
}
```

Flow in the view:

- `onLayout` → `computeLayout`.
- `onUpdate` → `DataProvider` fills `WatchData` → `drawAlwaysOn` if sleeping and always-on is really active
  (see best practices), else `drawFace(dc, data, !sleeping)`.
- `onExitSleep` (and `onShow` in high power) → start the animation timer. `onEnterSleep`/`onHide` → stop it.
- `App.onSettingsChanged()` → `FaceSettings.load()` → `computeLayout(...)` → `WatchUi.requestUpdate()`.
- The on-device menu stores each change at once and then calls `Application.getApp().onSettingsChanged()`.

## Two layout variants

| | Solver (`LayoutEngine`) | Fixed fractions (`FaceLayout`) |
|---|---|---|
| Idea | Rows and fields are distributed by code. Hidden fields give their space to the others | Every element has a fixed position as a fraction of the diameter (`x()`, `y()`, `px()`) |
| Use when | Elements can be hidden or exchanged and the space must be redistributed | The design is fixed, or hidden elements may leave a gap |
| Cost | Large (over 1000 lines in a real face), needs many layout tests and watchdog care | Small, a few helper functions |

Choose the fixed variant unless the user wants redistribution. Both use only fractions of `dc.getWidth()`,
never fixed pixel values, so new resolutions scale without new resources.

## Two font variants

| | System vector fonts | Bitmap fonts per resolution |
|---|---|---|
| How | `Graphics.getVectorFont` with a face list, size computed from the layout | `.fnt` + `.png` in `resources-round-<D>x<D>/fonts/`, generated by a script |
| Good for | Any size, no resource memory, text fitted by measuring | A special typeface, glow effects |
| Watch out | Some devices have no vector fonts: fall back to built-in fonts and accept coarser sizes | One set per resolution, memory, font licence (keep a `NOTICE` file). Observed with SDK 9.3.0: antialiased bitmap fonts store 4 tones |

Text measuring needs a `Dc`, which `computeLayout` does not have. `Graphics.fitTextToArea` works without one
and can be bisected to find the largest font size at which the widest realistic text fits. Keep these
worst-case texts in one place (`FontFit.VALUES`, e.g. `99999`, `999.9`) and reuse them in the tests.

## monkey.jungle patterns

```
project.manifest = manifest.xml
base.sourcePath = source;tests          # tests carry (:test) and are compiled only with -t

# Capability pairs: exactly one annotation of each pair is excluded per device.
base.excludeAnnotations = mip;noslot3
fenix7.excludeAnnotations = amoled;slot3      # a device line REPLACES the base value: name every pair again
fenix7.resourcePath = $(fenix7.resourcePath);resources-settings-small
```

`scripts/devices.sh jungle` prints the `excludeAnnotations` lines for the AMOLED/MIP pair of all chosen
devices, `scripts/devices.sh manifest` the matching `<iq:product>` lines ([devices.md](devices.md)).

In code, the pair selects a constant at compile time, with no runtime cost and no dead code on the device:

```monkeyc
module DisplayType {
    (:amoled) const IS_MIP = false;
    (:mip)    const IS_MIP = true;
}
```

Use this for display type, optional layout slots and features that depend on what the watch can record.
When a capability changes both the on-device menu and the phone settings, drive both from the same jungle
lines so they cannot drift apart.

## Settings resources

- `resources/settings/properties.xml`: one `<property id="ShowDate" type="boolean">true</property>` per
  setting. Selectable fields are `type="number"` holding a `DataKind` value.
- `settings.xml` (phone app): `<setting propertyKey="@Properties.ShowDate" title="@Strings.ShowDateTitle">`
  with `<settingConfig type="boolean" />` or `type="list"` and `<listEntry value="1">`. Same order as the
  on-device menu.
- Strings used only by the phone settings get `scope="settings"` so they stay out of the watch's memory.
  The app name gets `translatable="false"`.
- On-device menu: `WatchUi.Menu2` with `ToggleMenuItem`, item id = property key. A sub menu is opened with
  `WatchUi.pushView` inside try/catch. The template's `SettingsMenu` shows the small form: two toggles and a
  colour item that steps to the next colour on each press. Strings used by this menu must not carry
  `scope="settings"`.
- More than about six entries: group them. The root menu holds one `WatchUi.IconMenuItem` per group (e.g.
  "Data", "Color"), each opens a `Menu2` with that group's entries. One delegate class can serve the root and
  the groups when the item ids are distinct. The icon can be a small `WatchUi.Drawable` that draws lines
  relative to `dc.getWidth()` / `dc.getHeight()` (the `Dc` is the icon area, as in the SDK's Menu2Sample), so
  no bitmap per resolution is needed. Draw it in a neutral tone such as `Graphics.COLOR_LT_GRAY`, because the
  system menu is dark on some watches and light on others. The look of the icons is a point for the watch test.
- Check phone settings without a phone: every build writes `bin/<device>-settings.json` (next to the `.prg`).
  It lists the settings and list entries this device really gets, so variants per device can be compared
  there (e.g. an entry that must be missing on some watches).
- Manifest permissions: look up what each API needs in the SDK documentation instead of guessing. Complications
  need `ComplicationSubscriber`, the user profile needs `UserProfile`. Properties and `getSettingsView` need none.
