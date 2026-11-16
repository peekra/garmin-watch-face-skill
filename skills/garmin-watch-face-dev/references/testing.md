# Efficient testing

Quality over quantity: every test should be able to fail for a reason the user would care about, and no
device is tested twice for the same reason.

## Representatives instead of all devices

Devices with the same **resolution** and the same **font kind** behave the same. Group the manifest's devices
by these two properties (from each device profile's `compiler.json` and `simulator.json`) and pick one
representative per group. `scripts/devices.sh groups` prints the groups by display type and resolution for
the project's manifest; split a group further when its devices have different font kinds. In a shipped face 16 representatives stood for 59 devices. Font kinds seen
there: condensed vector fonts, wider "Regular" vector fonts, devices without a regular face, built-in fonts
only. Write the table of representatives into `CLAUDE.md`.

| Check | Where | When |
|---|---|---|
| Strict build `TYPECHECK_LEVEL=3 scripts/build.sh all` | all devices | every handover (the store package also compiles all) |
| Full unit tests `scripts/test.sh <device>` | representatives | after logic, layout or drawing changes |
| Text-fit test with the real fonts | all devices | only when fonts, texts or field sizes changed |
| Colour test (contrast, MIP colours) | one AMOLED and one MIP device | whenever a colour or background changed |
| Screenshots | representatives, second palette on two or three of them | new look, new palette |
| Behaviour (animation, sleep, always-on, menu) | primary device | it is the same code everywhere |
| Watchdog cold start | slowest device, non-default settings | after changes to start-up or layout code |
| Memory | simulator, primary and smallest-memory device | before a release |

**After a small change, test only what the change can touch.** A string fix needs no layout run on 16 devices.
Say which checks were skipped and why.

## Unit tests

Tests live in `tests/`, carry `(:test)`, take a `Test.Logger` and return a Boolean. They are compiled only
with `-t`, so they cost nothing in the release.

What to test, ordered by value per effort:

1. **Pure functions:** conversions, text formats, animation timing, week sums. Fast and exact.
2. **Settings:** defaults, invalid stored values, values the device does not offer.
3. **Layout:** for every combination of visible elements, everything inside the circle, nothing overlapping,
   the main element never smaller than in the default configuration.
4. **Drawing** with a recording `Dc` (below): the right primitives in the right mode.
5. **Text fit** on the device's real fonts.
6. **Colours:** contrast of every text colour against every background, and the 64 MIP colours
   (`tests/ColorTest.mc` in the template, rules in [best-practices.md](best-practices.md)).

### Soft assertions

A helper that logs and returns Boolean lets one test report all its failures at once:

```monkeyc
(:test) module TestCheck {
    function num(logger as Test.Logger, label as String, actual as Number, expected as Number) as Boolean {
        if (actual == expected) { return true; }
        logger.error(label + ": expected " + expected + ", got " + actual);
        return false;
    }
}
// in a test:  ok = TestCheck.num(logger, "hour", data.hour, 9) && ok;
```

### Recording Dc

Monkey C cannot read pixels back. A test double for `Graphics.Dc` that records each primitive (kind, colour,
pen width, coordinates) makes drawing testable: "in low power no seconds text is drawn", "the marker is one
red rectangle inside the band", "the MIP build uses only MIP colours". Preallocate its arrays and let it take
text widths from a real `Dc`.

### Golden hashes

To prove "the default layout is unchanged compared with the last version", hash the computed geometry per
screen size and compare with stored values. A refactoring that must not move anything is then checked in
seconds on every size. Update the hashes on purpose when the layout is meant to change.

### Text fit on real fonts

One test walks through all layout cases and checks that the widest realistic text of every field fits with
the device's actual fonts. Failure lines name device, field and pixels. This is the test worth running on all
devices, because fonts are the main thing that differs inside a resolution group.

### Watchdog in tests

A single test also has a time budget. Split long loops into chunks (e.g. 32 layouts per test
function).

## Simulator

- `scripts/test.sh` starts the simulator when needed. Observed with SDK 9.3.0: `monkeydo` returns exit code 1
  even when all tests pass, so the script reads the `PASSED (` / `FAILED (` line. Exit 2 means neither was
  found (no tests compiled in, simulator unreachable, crash).
- If the simulator hangs on its loading screen and a test prints nothing: quit the simulator process and
  start again. Run tests with a time limit.
- On-device menu: simulator menu **Settings > Trigger App Settings**. Stored properties:
  **File > Edit Persistent Storage**.
- When the simulator's menus cannot be operated, properties can be set in its settings file under
  `$TMPDIR/com.garmin.connectiq/GARMIN/APPS/SETTINGS/` (observed on macOS) followed by a reload. Check the file name with `ls`
  first. Unit tests write to the same file and should restore what they change.
- Low power and always-on are simulator menu functions. Check them on the primary device.
- Loss-free screenshots on macOS: `scripts/screenshot.sh <device>` cuts the display out of the simulator
  window (no device picture, no logo).
- Controlling the simulator window by automation needs the user's permission. Ask first, and limit it to the
  simulator.

### Simulator state and captures

- **Stored settings override `properties.xml` defaults.** A capture that should show other settings (accent,
  light background, other fields) must change the stored settings, or force the values in a **temporary copy**
  of the project. Never put demo values into the shipped code.
- Back up the simulator settings file before a test or capture run that touches it and restore it
  byte-identically afterwards (compare a hash). Tests and captures write their own values into it, and the next
  run would start from those.
- A screenshot is only valid if the build it shows is the current one: rebuild, reload, then capture. Check the
  image itself (time, values, the element that changed), not only the file date. This applies to screenshots
  from a tester agent too.
- Killing a load can leave the simulator on its launcher screen. Quit it completely and start it again.
- Entering low power or always-on needs the simulator menu (and the user's permission to drive it). If that is
  not possible, render the always-on drawing once in the temporary copy and say in the report that the real
  `onEnterSleep` / display-mode path was **not** exercised.

## What tests and simulator cannot show

Say these openly in `STATUS.md` and hand them to the user as a test list for the real watch:

- Real memory use: the test environment reports far more memory than a watch face gets. Measure in the
  simulator with an instrumented copy.
- The watchdog limit is not enforced in unit tests.
- Sensor and history data: observed with SDK 9.3.0, the simulator has no activity history.
- Timer smoothness, battery use, readability in sunlight, the real always-on behaviour.
- Phone settings: only with a beta or store installation.

## Phone settings

Phone settings only appear for store and beta installs, so they cannot be tried from a USB build. Before the
upload, check `bin/<device>-settings.json` of one device per settings variant: keys, order, defaults and list
entries. After the upload the user checks them once in the phone app. Report this as not checked until then.

## Reporting

Report per check: what ran, on which devices, result, and what did not run. "176 tests passed on 16
representatives, text fit on all 59, always-on only in the simulator, memory not measured" lets the user
decide. "All good" does not.
