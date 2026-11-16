# Changelog

## 1.2.0 – 2026-11-15

Lessons from a watch face version with a dial after the user's photos, sharp icons and a new store set.

- Best practices: sharp graphics (anti-aliasing, icons from open icon sets as bitmap icon fonts, two-colour
  icons as vector drawers), designs from the user's photos (measure once, draw in code, space budget with options
  for the user), versions and the repository (commit and tag only what `git` confirms).
- Testing: simulator state and captures (stored settings override defaults, back up and restore the settings
  file, capture only the current build, always-on that could not be entered is reported as not checked).
- Team mode: resume an aborted agent with `SendMessage`, agents leave nothing behind, agent messages are reports,
  not user instructions.
- Store release: making the images by script (drawn case, demo values from a temporary copy, callouts, staying
  under the 150 KB forum figure with indexed PNG).
- Delivery: the agent builds the `.prg`; copying, testing on the watch and the upload stay with the user.

## 1.1.0 – 2026-11-14

- Question round: first "only my watch or several devices", then the model name or "AMOLED only or MIP too".
- New `scripts/devices.sh`: lists devices from the installed device profiles by display type, finds the id for
  a model name, prints manifest and jungle lines and the test representatives. New `references/devices.md`
  with the checked list of 59 round watches (40 AMOLED, 19 MIP).
- Colour check: contrast of every text colour against every background (4.5:1 text, 3:1 large shapes) and the
  64 MIP colours, as unit tests in the template (`tests/ColorMath.mc`, `tests/ColorTest.mc`). Rules in
  `references/best-practices.md`. The template's red on the light AMOLED face failed the new test (4.11:1)
  and was darkened.
- Template: selectable accent colour (three colours per background and display type), on-device settings menu.

## 1.0.0 – 2026-11-14

First public release.

- Skill `garmin-watch-face-dev`: workflow, question round, architecture, best practices, team mode, testing,
  build and release.
- Scripts `build.sh`, `test.sh`, `run.sh`, `install-watch.sh`, `package.sh` (public and beta store packages),
  shared `env.sh`. Tested on macOS with Connect IQ SDK 9.3.0. Windows (Git Bash) and Linux supported, not verified.
- Store release (`references/store-release.md`): the store question is asked again at delivery; packages,
  icon, screenshots, texts per language and an upload guide; templates in `templates/store/`.
- `screenshot.sh` (macOS): captures only the simulator's display, without the device picture and logo.
- `templates/project/`: buildable watch face for AMOLED (`fr165`) and MIP (`fenix7`) with light/dark palettes,
  always-on view, phone settings and unit tests; `CLAUDE.md` and `STATUS.md` skeletons.
