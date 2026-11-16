# Worked example: Neon Frosh

A finished face built with this skill (version 1.3.0 of the skill, SDK 9.3.0, 2026-11-15). Look at it when you
want to see how a rule looks in code. It is the user's own project on their Mac, so the paths below are not part
of this repository; if they do not exist, work from the rules in the other reference files.

Project: [github.com/peekra/neon-frosh](https://github.com/peekra/neon-frosh) (spec in `CLAUDE.md`, state and "not checked" list in `STATUS.md`).

## What it shows

Round face for 59 devices (40 AMOLED, 19 MIP): light and dark background, 8 colours in two roles, solid hours with
outlined minutes, six user-selectable data slots, battery and Bluetooth icon from a user SVG, pressable fields,
white always-on view, store package `.iq` with images and texts in EN and DE.

## Where to look for what

| Topic | File in the project | Rule in this skill |
|---|---|---|
| Interface (data object, settings, renderer signatures), written before any code | `CLAUDE.md` section "Interface UI <-> logic" | architecture.md |
| User decisions with date, newest wins | `CLAUDE.md` section "User decisions" | SKILL.md, principle 2 |
| Data kinds, 6 slots, never-renumber values | `source/DataKind.mc`, `source/FaceSettings.mc` | best-practices.md, Settings |
| Two colour roles, palettes per background and display | `source/ui/UiColors.mc`, `design/drafts/palette.md`, `tests/ColorTest.mc` | best-practices.md, outline digits and colour roles |
| Outline digits as bitmap fonts, generator script | `design/drafts/fonts/`, `resources-round-*/fonts/` | best-practices.md, outline digits |
| Battery and Bluetooth drawn from the user's SVG | `design/battery_bluetooth.svg`, `source/ui/FaceRenderer.mc` (`drawBattery`, `drawBluetooth`) | best-practices.md, status icons |
| Weather icons, generator and contact sheet | `source/ui/WeatherIcons.mc`, `design/drafts/weather_icons.py`, `design/drafts/weather_icons.png` | best-practices.md, weather icons |
| Touch and hold on fields, hit test, kind to view mapping | `source/FaceDelegate.mc`, `source/FaceView.mc` (`openFieldAt`), `source/ui/FaceRenderer.mc` (`kindAt`), `source/ComplicationSource.mc` | best-practices.md, several pressable fields |
| Unit tests for touch, slots, colours | `tests/TouchTest.mc`, `tests/SlotLogicTest.mc`, `tests/ColorTest.mc` | testing.md |
| Always-on (AMOLED, white) | `FaceRenderer.drawAlwaysOn`, `FaceView.isAlwaysOnActive` | best-practices.md, always-on |
| Store set: images by script, texts, upload guide | `design/store/`, `design/drafts/store_tools/`, `design/drafts/captures/` | store-release.md |
| Honest status | `STATUS.md` ("Not checked") | testing.md, Reporting |

## How the work was split

Setup agent (cheap model), UI designer (strongest model), developer and tester (mid model) in parallel against the
interface in `CLAUDE.md`, then a store agent and a package agent. See team-mode.md, "Model per role".
