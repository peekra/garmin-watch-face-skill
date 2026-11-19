# Changelog

## 1.3.2 – 2026-11-19

- README: install with `npx skills add peekra/garmin-watch-face-skill -g -a claude-code`; manual install kept.

## 1.3.1 – 2026-11-16

- New `references/examples.md`: the face Neon Frosh as a worked example, with a table from topic to file in that
  project and to the matching rule; linked from the reference table in `SKILL.md`.
- README shows the reference image next to the result (`docs/neon-frosh.png`); `examples.md` links the public
  Neon Frosh repository.

## 1.3.0 – 2026-11-15

Lessons from the face "Neon Frosh" (outline time, two colour roles, 6 pressable fields, 59 devices, store set).

- Best practices: hit-test in drawing order (a field drawn over a panel is tested first), mapping data kind to
  watch view with the kinds that have none, always-on always white when the user decides so, outline digits as
  bitmap fonts per resolution, status icons drawn as vectors from a user SVG, weather icon size and drawing,
  two colour roles with a pair test.
- Testing: forced states in a temporary copy (battery steps, Bluetooth, all weather kinds), touch parts as
  unit tests, touch-and-hold views listed as not checked without the watch.
- Team mode: model per role (cheap model for setup/builds/packages, mid model for developer/tester/store,
  strongest model for a new UI layout), parallel designer and developer, resume with `SendMessage`.
- Store release: keep raw captures and the composing script, recapture once after the last visible change,
  callouts and limits for hardware-dependent features.

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
