# Garmin watch face skill for Claude Code

A [Claude Code](https://claude.com/claude-code) skill that builds Garmin Connect IQ watch faces in Monkey C, from
the first idea to an installable `.prg` and a store-ready `.iq`.

It comes from two watch faces that were built with Claude Code and published in the Connect IQ Store. It holds
what those projects learned the hard way: energy and always-on rules, AMOLED and MIP palettes, testing on
representative devices instead of all of them, build scripts that work around SDK quirks, and an interview that
makes Claude ask instead of guess.

## What it does

- **Interviews you** about the watch face: watch model, look, data, behaviour, settings, devices, delivery.
- **Asks which watches**: only yours (by model name) or several, AMOLED only or MIP too, and builds the device
  list from your installed device profiles (currently 59 round watches).
- **Sets up a project** from a small, buildable template (AMOLED and MIP, light/dark, selectable accent colour,
  on-device menu, unit tests).
- **Checks colours**: every text colour against every background by contrast, and the 64-colour limit of MIP
  displays, as a unit test.
- **Writes the code** with a fixed interface between data and drawing, so several agents can work in parallel.
- **Tests efficiently**: strict type checking, unit tests in the simulator, one representative per resolution
  and font kind.
- **Builds the outputs**: a `.prg` for your own watch (USB) and `.iq` packages for the store (public and beta).
- **Prepares a store release** when you plan one: icon, screenshots of the face without the simulator's device
  picture, store texts per language and a step-by-step upload guide. You upload everything yourself.

## Requirements

- Claude Code
- [Connect IQ SDK](https://developer.garmin.com/connect-iq/sdk/) installed with Garmin's SDK Manager, plus the
  device profiles of your target watches
- A Java runtime (JDK 11 or newer)
- A developer key outside your project, by default `~/.garmin/developer_key.der`
  (see `skills/garmin-watch-face-dev/references/build-release.md`)
- **Windows only:** [Git for Windows](https://gitforwindows.org/), whose Git Bash runs the scripts

## Platforms

| Platform | Status |
|---|---|
| macOS | Tested (Connect IQ SDK 9.3.0) |
| Windows (Git Bash) | Supported by the scripts, **not verified** |
| Linux | Supported by the scripts, **not verified** |
| WSL | Treated as Linux, needs the Linux SDK or `SDK_BIN`; **not verified** |

`screenshot.sh` (display-only captures for store images) is macOS only; elsewhere the skill asks you to crop
the screenshot by hand. Reports from Windows and Linux are welcome: open an issue with the command and its output.

## Installation

Clone the repository, then make the skill available to Claude Code.

**For all your projects** (recommended), link or copy the skill folder into `~/.claude/skills/`:

```bash
git clone https://github.com/peekra/garmin-watch-face-skill.git
mkdir -p ~/.claude/skills
ln -s "$PWD/garmin-watch-face-skill/skills/garmin-watch-face-dev" "$HOME/.claude/skills/garmin-watch-face-dev"
```

On Windows, copy the folder instead of linking it (a symbolic link needs developer mode), or create a junction in
`cmd`:

```bat
mklink /J "%USERPROFILE%\.claude\skills\garmin-watch-face-dev" "C:\path\to\garmin-watch-face-skill\skills\garmin-watch-face-dev"
```

**For one project only**, copy `skills/garmin-watch-face-dev` into that project's `.claude/skills/`.

With a link, `git pull` updates the skill. With a copy, copy it again after pulling.

## Usage

Start Claude Code in an empty folder and describe what you want, for example:

> Build me a watch face for my Forerunner 265: big digital time, heart rate and steps below it, a dark and a
> light variant. I want to try it on my watch first and publish it in the store later.

Claude loads the skill, asks its questions, and works through setup, code, tests and packaging. You can also
call it directly with `/garmin-watch-face-dev`.

## What is inside

```
skills/garmin-watch-face-dev/
├── SKILL.md            workflow and principles (loaded first)
├── references/         loaded when needed
│   ├── questions.md        interview with the person who wants the watch face
│   ├── devices.md          device lists from the installed profiles, checked list of 59
│   ├── architecture.md     project structure, classes, interface, monkey.jungle patterns
│   ├── best-practices.md   energy, always-on, MIP, robustness, memory
│   ├── team-mode.md        working with sub-agents
│   ├── testing.md          representative devices, unit tests, simulator
│   ├── build-release.md    developer key, .prg, .iq
│   └── store-release.md    store release: packages, images, texts, upload guide
├── scripts/            build.sh, test.sh, run.sh, install-watch.sh, package.sh, devices.sh, screenshot.sh, env.sh
└── templates/
    ├── project/        buildable starting point, CLAUDE.md and STATUS.md skeletons
    └── store/          listing.md (store texts), UPLOAD-GUIDE.md (steps for you)
```

## Not affiliated with Garmin

This is an independent project. It is not made, endorsed or supported by Garmin. Garmin, Connect IQ, Forerunner,
fēnix and the other product names are trademarks of Garmin Ltd. or its subsidiaries. The Connect IQ SDK is not
included; download it from Garmin under its own licence.

## License

[MIT](LICENSE)
