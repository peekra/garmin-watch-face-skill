# Build, deliver, release

## Developer key

Every build is signed. The user creates the key once, keeps it outside the project and backs it up: store
updates must be signed with the same key. Two ways:

- VS Code with the Monkey C extension: command "Monkey C: Generate a Developer Key".
- Command line, as given in the SDK documentation (Monkey C Command Line Setup):

```bash
openssl genrsa -out developer_key.pem 4096
openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
```

The scripts expect `~/.garmin/developer_key.der` (on Windows `C:\Users\<name>\.garmin\`) (override with `DEVELOPER_KEY=...`). `.gitignore` contains
`*.der` and `*.pem` as a second line of defence.

## Scripts

Copy `scripts/` from this skill into the project and set in `scripts/env.sh`:

| Value | Meaning |
|---|---|
| `APP_NAME` | File name of the app, e.g. `MyFace` → `MyFace.prg`, `MyFace.iq` |
| `DEFAULT_DEVICE` | Device id of the user's watch, e.g. `fr165` |
| `BETA_APP_ID` | Only for beta packages: generate once with `uuidgen` (lower case) and never change |

The scripts find the SDK themselves: `$SDK_BIN`, then the SDK marked as current by the SDK Manager, then the
newest installed one. The core calls, in case a script has to be adapted:

```bash
# debug build of one device
monkeyc -d <device> -f monkey.jungle -o bin/<device>.prg -y <key> -w -l <0..3>
# unit test build: add -t, then run with: monkeydo bin/test-<device>.prg <device> -t
# release build: add -r
# store package for all devices of the manifest
monkeyc -e -r -f monkey.jungle -o bin/store/<APP_NAME>.iq -y <key> -w -l 3
```

## `.prg`: onto the user's watch by USB

`scripts/install-watch.sh <device>` builds `bin/release/<device>/<APP_NAME>.prg`. The user copies it to
`GARMIN/APPS/` on the watch. On macOS, watches that use MTP do not appear in Finder, so an MTP tool is needed
(e.g. OpenMTP), and Garmin Express must be closed first because it blocks the connection. On Windows the watch
appears in File Explorer under "This PC" (not verified). The script installs
nothing by itself and prints the steps.

A `.prg` fits one device type only. Sideloaded apps have no phone settings: use the on-device menu.

## `.iq`: for the Connect IQ Store

`scripts/package.sh` builds the public package with the app id from `manifest.xml`.
`scripts/package.sh --beta` builds a beta package with `BETA_APP_ID` from a temporary copy of the project, so
`manifest.xml` stays unchanged.

- Beta and public app need different ids. The store treats them as two apps.
- An `.iq` is a 7-zip archive. List it with `tar -tf <file>.iq` and check that every device of the manifest is
  inside. The package lists part numbers, not device ids (mapping in each device profile's `compiler.json`,
  one device id can have several part numbers).
- The manifest has no version field. The user enters the version in the upload form. Record the version in
  `STATUS.md` and as a git tag.

- **Check the app id inside every package before handing it over:**
  `tar -xOf bin/store/<APP_NAME>.iq manifest.xml | grep -o '<iq:application[^>]*'`. With several watch faces in
  neighbouring folders a wrong project root packages the wrong app, and the build still says "successful".
  This happened once when `scripts/env.sh` was sourced from zsh. Run the scripts as files, or wrap manual
  calls in `bash -c '...'`, and let the script print the project root it uses.

Recommended path: USB test → beta upload → test on the watch including phone settings → public upload.

## Store release

Packages alone are not a store release: icon, screenshots, texts and an upload guide belong to it. The whole
procedure is in [store-release.md](store-release.md).

## Document templates

`templates/project/CLAUDE.md` (the rules for every agent) and `templates/project/STATUS.md` (where the
next session starts) are the skeletons. Fill them during the question round and keep them current.

## Git

Local repository, one commit and tag per version that goes onto the watch or into the store, commit message
listing all changes of the version. Rolling back is `git checkout <tag>` and a rebuild. Commit and push only
when the user asks for it.
