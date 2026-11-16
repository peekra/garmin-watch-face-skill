# Devices

Which watches a face supports is the user's decision ([questions.md](questions.md), section 6). This file is
about turning the answer into a device list.

## From the installed device profiles (preferred)

`scripts/devices.sh` reads the device profiles that the SDK Manager downloaded (`compiler.json`: display type,
resolution, app types, Connect IQ version per part number; `simulator.json`: display shape). It needs no SDK
build and no developer key.

| Command | Result |
|---|---|
| `scripts/devices.sh find forerunner 165` | Device ids for a model name, with display type and resolution |
| `scripts/devices.sh list [amoled\|mip\|all]` | Table of round watch-face devices with Connect IQ 5.2.0 or newer |
| `scripts/devices.sh manifest [amoled\|mip\|all]` | `<iq:product>` lines for `manifest.xml` |
| `scripts/devices.sh jungle [amoled\|mip\|all]` | `excludeAnnotations` lines for `monkey.jungle` (base AMOLED, one line per MIP device) |
| `scripts/devices.sh groups` | The project's manifest devices grouped by display type and resolution, one representative each |

Options for `list`, `ids`, `manifest`, `jungle`: `--min-api X.Y.Z` (default 5.2.0, the template's
`minApiLevel`; a device counts only if every part number has at least this version) and `--any-shape`
(also rectangular and semi-round watches).

A profile that is not installed cannot be listed. If the list looks short, the user opens the SDK Manager,
tab "Devices", and downloads the missing ones. New watches appear there first, so the script finds devices
that this file does not know yet: show additions to the user instead of adding them silently.

A project with more capability pairs than AMOLED/MIP (see [architecture.md](architecture.md)) extends the
generated jungle lines by hand: every device line names every pair.

## Checked list (SDK 9.3.0, November 2026)

Round watches, Connect IQ 5.2.0 or newer, used by two shipped faces: 40 AMOLED and 19 MIP,
59 devices. Use it when profiles are missing, or to compare with the script's output.

**AMOLED (40)**

`approachs7243mm` `approachs7247mm` `d2mach1` `d2mach2` `d2mach2pro` `epix2` `epix2pro42mm` `epix2pro47mm`
`epix2pro51mm` `fenix843mm` `fenix847mm` `fenix8pro47mm` `fenix943mm` `fenix947mm` `fenix9pro43mm`
`fenix9pro47mm` `fenix9pro51mm` `fenixe` `fr165` `fr165m` `fr170` `fr170m` `fr265` `fr265s` `fr57042mm`
`fr57047mm` `fr70` `fr965` `fr970` `instinct3amoled45mm` `instinct3amoled50mm` `marq2` `marq2aviator`
`marq3` `venu3` `venu3s` `venu441mm` `venu445mm` `vivoactive5` `vivoactive6`

**MIP (19)**

`enduro3` `enduro4` `fenix7` `fenix7pro` `fenix7pronowifi` `fenix7s` `fenix7spro` `fenix7x` `fenix7xpro`
`fenix7xpronowifi` `fenix8solar47mm` `fenix8solar51mm` `fenix9prosolar47mm` `fenix9prosolar51mm` `fr255`
`fr255m` `fr255s` `fr255sm` `fr955`

Resolutions: AMOLED 360, 390, 416, 454, 466 px; MIP 218, 240, 260, 280 px.

Left out on purpose: `instinctcrossoveramoled`. The script lists it (round, AMOLED), but the shipped faces
did not support it. The Instinct Crossover line has physical hands over the display (not verified for this
model), so ask the user before adding it.

## What the list does not tell

- **Fonts.** Devices of one resolution can have different system fonts, which is why the text-fit test runs
  on all devices ([testing.md](testing.md)).
- **Capabilities** such as sports, sensors or touch. Check each API with `has` and the SDK documentation.
- **Memory.** The watch-face memory limit is in each `compiler.json` (`appTypes`, type `watchFace`).
