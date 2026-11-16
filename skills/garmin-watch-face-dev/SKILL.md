---
name: garmin-watch-face-dev
description: Develop Garmin Connect IQ watch faces in Monkey C from the first idea to an installable .prg and a store-ready .iq. Use this skill whenever the user wants to create, extend, port, debug, test, package or publish a Garmin watch face (Forerunner, fenix, Venu, epix, Instinct, vivoactive, Enduro, MARQ ...), mentions Connect IQ, Monkey C, monkeyc, monkey.jungle, manifest.xml, the Connect IQ simulator, AMOLED or MIP watches, always-on display, or asks for a ".prg" or ".iq" file, even if they do not say "watch face" explicitly. Covers the interview with the person who wants the watch face, project structure and classes, energy and display rules, multi-agent team mode, efficient testing on representative devices, and the build scripts.
---

# Garmin watch face development

This skill captures what worked in two watch faces shipped to the Connect IQ Store: one with a layout solver,
system vector fonts, phone settings and 59 devices (AMOLED and MIP), and one with a fixed layout and bitmap fonts
with glow. `templates/project/` is a small, buildable starting point that follows the structure described here.

Everything here was observed with **Connect IQ SDK 9.3.0 on macOS**. Where a statement depends on that version it
says so. On another SDK version, check the SDK documentation (`<sdk>/doc/`) before relying on it.

## Principles

1. **Ask, never invent.** A watch face is personal. Layout, data, units and behaviour are the user's decisions.
   Open points go to the user before implementation. Facts you could not check are marked "not verified".
2. **Decisions live in files, not in the chat.** `CLAUDE.md` holds the spec and every user decision with its date,
   `STATUS.md` holds what was built, what was checked and what was **not** checked. A new session starts there.
3. **Interface first.** Logic produces one plain data object, the UI only draws. This is what makes parallel
   agents and fast unit tests possible.
4. **Cheap tests first.** Unit tests in the simulator replace most screenshots. Devices with the same resolution
   and font kind behave the same, so test representatives, not every device.
5. **The user owns the outside world.** Developer key, store account, uploads and the watch belong to the user.
   Build the files and write the step-by-step guide. Do not upload, create accounts or fill store forms.

## Workflow

### 1. Check the toolchain

Needed: the Connect IQ SDK (installed with Garmin's SDK Manager), a JDK, a developer key outside the project
(default `~/.garmin/developer_key.der`), device profiles for the target watches (downloaded in the SDK Manager).
`scripts/env.sh` finds the SDK itself (macOS, Windows, Linux paths) and reports what is missing. On Windows the
scripts need Git Bash. If the key is missing, the user creates it
(see [references/build-release.md](references/build-release.md)). The key never goes into the repository:
every store update must be signed with the same key, and a leaked key lets others sign as the user.

### 2. Interview the user

Run the question round in [references/questions.md](references/questions.md) in the user's language. Two
questions always come first: only the user's own watch (then its model name) or several devices (then AMOLED
only, or MIP too). Ask in
small batches, skip what the user already said, and offer a recommended default for each question. Write the
answers into `CLAUDE.md` right away, with the date. Later decisions are appended with their date and override
older ones, so the history of "why" stays readable.

### 3. Set up the project

Copy `templates/project/` (a small face that builds on AMOLED and MIP, with light/dark, selectable accent
colour, on-device menu, and unit tests including the colour test) and this skill's
`scripts/` folder into the project. Then:

- `manifest.xml`: a new app id from `uuidgen` (lower case), the products from the question round
  (`scripts/devices.sh manifest [amoled|mip|all]` prints the lines, see
  [references/devices.md](references/devices.md)).
- `monkey.jungle`: one `excludeAnnotations` line per MIP device (`scripts/devices.sh jungle` prints them), see
  [references/architecture.md](references/architecture.md).
- `resources/strings/strings.xml`: `AppName`. `scripts/env.sh`: the three values marked `SET PER PROJECT`
  (`APP_NAME`, `DEFAULT_DEVICE`, `BETA_APP_ID` only when a beta package is wanted).
- `CLAUDE.md` and `STATUS.md` from the template: fill in the answers of the question round.

Build once (`TYPECHECK_LEVEL=3 scripts/build.sh all`) and run `scripts/test.sh` before changing anything, so a
broken toolchain shows up before the first own line of code. Then grow the template along
[references/architecture.md](references/architecture.md); rename classes only if the user wants it. Start a local git repository
with a `.gitignore` for `bin/`, `*.der`, `*.pem`, `.DS_Store`. Push to a remote only if the user asks.

### 4. Fix the interface

Before any drawing or data code, write the interface between logic and UI into `CLAUDE.md`: `WatchData`,
`FaceSettings`, `FaceRenderer` (signatures in [references/architecture.md](references/architecture.md)).
Changes to it go through the lead. Read [references/best-practices.md](references/best-practices.md) before
writing code: most watch face bugs are energy, memory or null-value problems that the rules there prevent.
Colours are part of this step: every colour per background and display type, shown to the user with its
contrast value and covered by the colour test before it is used.

### 5. Build, alone or as a team

For a small face or a small change, work alone. For a new face or a larger version, use team mode
([references/team-mode.md](references/team-mode.md)): lead, UI agent, developer agent, tester, each owning
its own files. Agents cost tokens, so ask the user before spawning them if a budget was mentioned.

### 6. Test efficiently

Follow [references/testing.md](references/testing.md). In short: strict build for all devices, full unit tests
on one representative per resolution and font kind, colour test on one AMOLED and one MIP device, text-fit test on all devices only when fonts, texts or
field sizes changed, screenshots only for what tests cannot prove. After a small change, test only what the
change can touch. Report failures and untested points honestly: the user decides with that information.

### 7. Deliver

When the face is ready, **ask again whether a Connect IQ Store release is coming up**, even if the question round
said no. Then build what is wanted ([references/build-release.md](references/build-release.md)):

| Wanted | Command | Result |
|---|---|---|
| Try on the own watch (USB) | `scripts/install-watch.sh <device>` | `bin/release/<device>/<APP_NAME>.prg` |
| Store, public | `TYPECHECK_LEVEL=3 scripts/package.sh` | `bin/store/<APP_NAME>.iq` |
| Store, beta | `TYPECHECK_LEVEL=3 scripts/package.sh --beta` | `bin/store/<APP_NAME>-beta.iq` |

A `.prg` runs on exactly one device type. An `.iq` contains all devices of the manifest and is what the store
accepts. **A store release is more than the `.iq`:** follow [references/store-release.md](references/store-release.md)
for icon, screenshots without the Garmin device picture (`scripts/screenshot.sh`), texts per store language and the
upload guide for the user. Then update `STATUS.md`, commit with a message that lists the changes, and tag the
version if the user wants commits.

## Scripts

All scripts live in `scripts/`, source `env.sh`, and tolerate spaces in paths. Tested on macOS. Windows (Git Bash,
which comes with Git for Windows) and Linux are supported by `env.sh` but not verified: say so to the user and
report what fails.

| Script | Purpose |
|---|---|
| `env.sh` | Shared settings: SDK discovery, key path, app name, default device, beta id, helpers |
| `build.sh [device\|all]` | Debug build → `bin/<device>.prg`. `TYPECHECK_LEVEL=3` for strict typing |
| `test.sh [device [test ...]]` | Builds with `-t`, starts the simulator, runs the `(:test)` functions, log in `bin/test-<device>.log` |
| `run.sh [device]` | Starts the simulator and loads the app |
| `install-watch.sh [device]` | Release `.prg` and copy instructions for the watch |
| `package.sh [--beta]` | Store package `.iq` for all devices in the manifest |
| `devices.sh <list\|ids\|manifest\|jungle\|groups\|find>` | Devices from the installed profiles by display type; manifest and jungle lines; test representatives |
| `screenshot.sh [device [out.png]]` | macOS: only the display of the running simulator, native size, no device picture |

## Reference files

| File | Read it when |
|---|---|
| [references/questions.md](references/questions.md) | Starting a project or a new version: the interview |
| [references/devices.md](references/devices.md) | Choosing devices, filling manifest and jungle, the checked list of 59 |
| [references/architecture.md](references/architecture.md) | Setting up the project, naming classes, defining the interface |
| [references/best-practices.md](references/best-practices.md) | Before writing or reviewing Monkey C code |
| [references/team-mode.md](references/team-mode.md) | Working with sub-agents |
| [references/testing.md](references/testing.md) | Writing tests, choosing devices, using the simulator |
| [references/build-release.md](references/build-release.md) | Building `.prg`/`.iq`, developer key |
| [references/store-release.md](references/store-release.md) | A Connect IQ Store release: packages, icon, screenshots, texts, upload guide |
| `templates/project/` | Starting a project: buildable skeleton, `CLAUDE.md`/`STATUS.md` skeletons |
| `templates/store/` | Store release: `listing.md` (texts per language), `UPLOAD-GUIDE.md` (steps for the user) |
