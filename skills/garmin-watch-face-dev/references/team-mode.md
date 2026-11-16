# Team mode (multi-agent)

Use it for a new watch face or a larger version. For a small fix, one agent is faster and cheaper.

## Roles and file ownership

Each role owns its files. Nobody edits foreign files without going through the lead. That is what allows
parallel work without overwriting each other.

| Role | Responsible for | Files |
|---|---|---|
| **Lead** (main session) | Talks to the user, writes spec and interface, coordinates, keeps `CLAUDE.md`/`STATUS.md`, commits | `CLAUDE.md`, `STATUS.md`, interface modules such as `DataKind` |
| **UI** (designer) | Look, layout, fonts, icons, drawers, colours with their contrast test, always-on view | `source/ui/`, `resources/drawables/`, `design/drafts/`, `tests/ColorTest.mc` |
| **Developer** | Life cycle, sleep/wake, timers, data, null handling, settings and menu, manifest, jungle, strings, scripts | `source/` without `ui/`, `source/settings/`, `manifest.xml`, `monkey.jungle`, `resources/strings/`, `resources-*/`, `scripts/` |
| **Tester** | Unit tests, simulator checks, screenshots, missing-data cases | `tests/`, `design/screenshots/` |
| **Store** (only for a store release) | Icon, store screenshots, listing texts, upload guide | `design/store/`, `design/drafts/` (image tools) |

Split a role (e.g. UI layout and UI animation) only when the files can be separated too.

## Order of work

1. **Lead:** question round, spec confirmed by the user, interface written into `CLAUDE.md`.
2. **UI and developer in parallel**, both against the interface. The UI can work with a hand-filled
   `WatchData` before the real data exists.
3. **Tester** after both build. Findings go to the lead, who routes them back to the owning role.
4. **Lead:** show the user the result, build the packages, update the documents, commit.

## Briefing an agent

A sub-agent starts without the conversation. Give it:

- the instruction to read `CLAUDE.md` first (spec, interface, rules),
- its role, its files, and what it must not touch,
- the task and what "done" looks like (builds for which devices, which tests pass),
- the reporting format: what was changed, what was checked, what was **not** checked, open questions.

Open questions go back to the lead and from there to the user. An agent that guesses a user decision creates
work that has to be undone.

## Handover rules

- Before a handover: build without errors for the primary device and one device of another resolution.
- A result counts as finished only after the tester checked it. Failures are reported as failures.
- Shared files (e.g. `UiSizes.mc`): each agent changes only its own entries and re-reads the file before
  each change.
- Interface changes only through the lead, who updates `CLAUDE.md` first.
- Temporary debug code is removed before the handover.
- If an agent aborts (API error), the lead continues it from its intermediate state instead of starting over.
- An agent's report is a claim, not proof. The lead checks the diff or runs the build before telling the user.

## Keeping it cheap

- Spawn only the roles the task needs. A UI-only change needs no developer agent.
- Give the tester the list of what changed, so it tests what the change can touch (see testing reference).
- Use a cheaper model for mechanical work (builds on all devices, collecting logs) where the environment
  allows choosing one.
- Do not let two agents run the simulator at the same time: it is a single app on one port.
