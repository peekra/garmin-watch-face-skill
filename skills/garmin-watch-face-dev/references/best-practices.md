# Best practices

Each rule comes with its reason. If a situation is not covered, apply the reason.

## Energy and display modes

- **`onUpdate()` runs every second only in high-power mode** (about 10 s after a wrist turn), otherwise once
  per minute. Seconds and animations therefore exist only in high power. In sleep, draw neither: a stale
  seconds digit looks like a bug.
- **Timers only in high power.** Start in `onExitSleep()` (and in `onShow()` when already in high power),
  stop in `onEnterSleep()` and `onHide()`. Wrap `timer.start` in try/catch, the system may refuse it.
  No timer at all while the animation is switched off.
- **Keep seconds even while a timer runs.** If a timer redraws only during an animation phase, a second change
  in the pause appears late and the seconds look uneven. Let the timer callback also redraw when the clock
  second differs from the one drawn last. Put that decision into a pure function so it can be unit tested.
- **Animate sparingly.** Reuse the one-second `onUpdate` where the design allows it (e.g. a step per second),
  and precompute curve points in `setup()`.

## AMOLED always-on

- Draw the reduced always-on view only when always-on is really active:
  `requiresBurnInProtection == true` **and** `System.getDisplayMode() == System.DISPLAY_MODE_LOW_POWER`
  (check with `System has :getDisplayMode`). `requiresBurnInProtection` alone is always true on AMOLED, so
  without the second check the face switches to the reduced view after 10 s even when the user has always-on
  switched off.
- Limits in always-on: at most 10 % lit pixels and no pixel lit for more than 3 minutes, otherwise the system
  blanks the screen. Draw thin, dim content and shift its position every minute.
- The always-on view ignores the light/dark setting: always light on black.

## MIP displays

- 64 colours: each channel is one of `00`, `55`, `AA`, `FF`. Other colours are mapped by the system and
  gradients turn into bands. Define separate MIP palettes from these values and select them at compile time.
- No burn-in protection and no always-on view: in sleep the full face stays, without seconds and animation.
- Small screens (218–280 px): thin double lines and small decoration can merge. Offer fewer fields rather than
  smaller text.

## Colours and readability

A colour that reads well on black can vanish on white, and a colour that is fine on AMOLED may not exist on
MIP. Readability is therefore tested, not judged by eye.

- **Every colour exists four times:** light and dark background, each for AMOLED and for MIP. Keep them as
  tables in `UiColors` (index = stored value of the colour setting) and let `apply(dark, accent)` pick one.
  When the user can choose colours, offer for each background only colours that pass on that background;
  the same list entry ("Orange") may be a bright tone on black and a dark tone on white.
- **Contrast against the background** with the WCAG formula (relative luminance of sRGB):
  at least **4.5:1** for text, thin lines and small icons, at least **3:1** for large digits and filled
  shapes. `tests/ColorMath.mc` computes it, `tests/ColorTest.mc` walks through every background and every
  selectable colour, and a failure names the colour, the background and the value. Put every new colour
  role (muted text, gauge, dots) into that loop with the limit that fits its size.
- **MIP: only the 64 colours.** The same test checks in the MIP build that every channel is `00`, `55`, `AA`
  or `FF`. A colour outside is replaced by the system, and the replacement can have less contrast than the
  tested one. Fewer tones are available, so two AMOLED colours may share one MIP colour: say so to the user.
- **Unlit parts** (gauge tracks, inactive dots) are meant to be weak. Give them their own limit (e.g. visible
  at 1.5:1) instead of leaving them out of the test, and never use them for text.
- **Light background on AMOLED** costs battery and is never used in the always-on view. Tell the user when
  they ask for a white face.
- Run the colour test on one AMOLED and one MIP device (`scripts/test.sh fr165`, `scripts/test.sh fenix7`),
  and again whenever a colour changes. Show the user the palette with its contrast values before it is built in.
- What the test cannot show: the real panel. A MIP display reflects light and looks duller than the
  simulator, AMOLED dims in sunlight. List "readability on the watch, indoors and in sunlight" under
  "not checked" until the user has looked at it.

## Robustness

- **Every value can be `null` or unavailable.** Show `--` and never crash: a crashed watch face is replaced by
  the system default and the user sees an error icon.
- Guard API access with `has` checks and try/catch at the source (`DataProvider`, `ComplicationSource`,
  `SettingsStore`), so the rest of the code works with clean values.
- `FaceSettings.load()` falls back to defaults on any error. A stored value that the device does not offer
  (e.g. a data kind without the matching sport) counts as "off".
- Property values that are stored (data kinds, list entries) are permanent: never renumber them in an update.
- A watch face gets no short tap. Touch and hold arrives as `WatchFaceDelegate.onPress`. Return `false` when
  the point hits nothing so the system keeps its own behaviour.
- **Several pressable fields:** map each data kind to the complication type whose view it opens
  (`Complications.exitTo(new Complications.Id(type))`, inside try/catch, guarded with `Complications has :exitTo`).
  Kinds without a view return `false`. Two kinds can share a view (active and total calories both open the
  calories view): say so to the user. Give every field a hit box between its layout limits with a height that
  cannot reach the neighbouring row, make a field that is off no target, and ignore presses in the always-on
  view. Keep "which kinds open a view" a pure function and unit test it together with "which field lies under
  this point". Whether each view really opens can only be seen on the watch: list it under "not checked".
- Touch and hold needs a touchscreen. Say this in the store description when the feature is advertised.

## Memory and time budget

- **No allocations in the draw path.** No `new`, no string building that can be avoided, no resource loading
  in `onUpdate()`/`draw*()`. Load fonts and compute geometry in `onLayout()`/`computeLayout()`.
- **Watchdog:** each callback has a time budget, and some older devices have only half of it. Spread start-up
  work over callbacks: settings-independent work (fonts) in `FaceRenderer.initialize()`, layout in
  `computeLayout()`. Check heavy layout code on the slowest target with a cold start and non-default settings.
- Memory limits differ per device (see the device's `compiler.json`). Lazy-load rarely used fonts. On an
  out-of-memory or watchdog error, simplify the drawing first.
- Recompute the layout only at start and in `onSettingsChanged()`, never in `onUpdate()`.

## Layout and style

- Every size is a fraction of the display diameter, collected in `UiSizes`. Colours live in `UiColors`.
  No magic numbers in drawers.
- Keep everything inside the round display: check box corners against the circle, not only the centre line.
- Use `resources-round-<D>x<D>/` only when scaling demonstrably fails (bitmap fonts).
- Fit text by measuring the widest realistic value, not the value of the moment.
- Text that must not follow the system language (e.g. fixed weekday abbreviations) is built in code, not taken
  from the system formatter.

## Types and code

- Build with `TYPECHECK_LEVEL=3` (strict) from the beginning. Retrofitting types later is expensive.
- Short classes with one task, English identifiers and comments.
- Remove temporary debug output (`System.println`) before a handover.

## Settings

- The on-device menu (`getSettingsView`) also works for sideloaded apps. Phone settings (`settings.xml`) only
  work for store and beta apps. Offer the on-device menu when the user tests by USB.
- Apply each change immediately: store, then `onSettingsChanged()`.
- Keep variants of `settings.xml` identical except for the intended difference, and say so in a header comment.

## Honest limits

Tell the user what a watch face cannot do before designing around it, and check in the SDK documentation
instead of guessing. Mark unverified behaviour (e.g. how far the activity history reaches) in `STATUS.md` as a
point for the test on the real watch.
