# Store release

Read this when the user wants the watch face in the Connect IQ Store. The agent builds and prepares
everything; the user owns the developer account and does every upload. Never upload, create accounts or fill
in store forms.

## 1. Ask before delivering

The question round asks early whether the face is meant for the store. Plans change, so ask again when the
face is ready to be delivered:

- Is a release in the Connect IQ Store coming up? (yes / not now / never)
- If yes: beta first, then public? (recommended: test the beta on the own watch, including phone settings)
- Store languages? (default: English, plus the user's language)
- Version number of this release? (the user enters it in the upload form)

"Not now" or "never": deliver the `.prg` (`scripts/install-watch.sh`) and stop here. Mention that the store
material can be made later from the same project.

## 2. What a store release contains

Put everything into `design/store/` and list it in its `README.md` (the upload guide):

| File | Content | How |
|---|---|---|
| `bin/store/<APP_NAME>-beta.iq` | Beta package, own fixed app id | `TYPECHECK_LEVEL=3 scripts/package.sh --beta` |
| `bin/store/<APP_NAME>.iq` | Public package, app id from `manifest.xml` | `TYPECHECK_LEVEL=3 scripts/package.sh` |
| `design/store/icon_500.png` | App icon | section 4 |
| `design/store/screenshot_*.png` | 2–4 screenshots | section 5 |
| `design/store/hero_1440x720.png` | Hero image (optional) | section 4 |
| `design/store/listing_<lang>.md` | Name, short and full description, "What's new", permissions note, one file per language | `templates/store/listing.md` |
| `design/store/README.md` | Step-by-step upload guide for the user | `templates/store/UPLOAD-GUIDE.md` |

Build the packages only after the tests passed, and check the app id inside each package
(see [build-release.md](build-release.md)).

## 3. Requirements: verify at release time

Garmin changes the upload form, and parts of it are only visible after login. Check the developer pages
(SDK documentation `Core_Topics/Publishing_to_the_Store.html` and `Beta_Apps.html`) and mark in the guide what
could not be verified. Collected in October 2026:

| Item | Requirement | Source |
|---|---|---|
| Icon | 500 × 500 px, sRGB, no alpha channel, about 10 px margin, plain background (not black, not transparent), no text, no shadow, no Garmin branding. For a watch face a preview of the face works well | Garmin developer pages; file size limit 300 KB from the forum, not verified |
| Screenshots | Square 1024 × 1024 px worked; at most 150 KB each according to the forum | Not verified by Garmin |
| Hero image | Optional, exactly 1440 × 720 px, at most 2048 KB | Upload form |
| Texts | No Garmin trademarks or device names in texts and images. Health values (heart rate, VO2max ...) as information, not as medical statements | Store guidelines |
| Beta | Upload with the "Beta App" checkbox; a beta can be updated any number of times with the same id | SDK documentation |
| Review | Usually within 72 hours; rejection comes by e-mail with reasons | SDK documentation |
| Updates | Same developer key, higher version number | SDK documentation |

## 4. Images without Garmin branding

The simulator window shows the face inside a picture of the real watch with the Garmin logo. That picture
must not appear in store images (and should not appear in a public repository either).

- `scripts/screenshot.sh <device> <out.png>` (macOS) captures only the round display of the running simulator,
  at the display's native size, with transparent corners. Load the face first with `scripts/run.sh <device>`.
- Take the captures on the device with the largest display of the manifest, light and dark, with realistic
  values. Demo values belong in a temporary copy of the project, never in the shipped code.
- Compose icon, screenshots and hero image from these captures: plain background, optionally a device frame
  drawn by the agent (no photos, no logo, no lettering on bezel or buttons). Keep the tools that draw them in
  `design/drafts/` so the images can be made again for the next version.
- On Windows and Linux there is no capture script yet: ask the user to save the screenshot and crop it, or to
  provide one, and say that this step is manual there.

## 5. Screenshots that explain the face

A stranger decides in seconds. Each screenshot answers one question:

1. What does it look like? The face with short labels pointing at the elements.
2. Which variants are there? Light and dark side by side.
3. What can I change? Different field selections, or elements switched off.

Same background and caption style on every image. Captions in English unless the user wants more languages.

### Making the images

- Compose the images with a small script kept in `design/drafts/store_tools/` (Swift with CoreGraphics works on
  macOS with no extra install): HUD or plain background, a case drawn by the script (no photo, no logo), the
  title in the face's own font where its licence allows (e.g. Saira, OFL), the captures from the simulator.
- Captures come from a **temporary copy** with demo values (a round time like `10:08`, realistic numbers, the
  weather you want to show). The real date in the simulator shows the real weekday and language; say so, or set
  the date in the copy.
- Callout lines (labels with a line to the element) must not cross digits or values; place the anchor points on
  empty parts of the face and look at the result.
- **File size.** The forum limit of about 150 KB per screenshot (not documented by Garmin) is hard to meet with
  glow gradients, grids and many colours. What worked: indexed PNG with few colours (64 to 192), dithering off,
  **no per-row PNG filters** for these flat images, a coarser background grid (64 px), weaker halos. Let the
  script try colour counts from high to low until the file is small enough, and print the sizes. The icon may be
  larger (300 KB forum figure) but stays simple: plain background, no text.
- Look at every image after rendering. Typical faults: two watches touching, a glow that bands into patches
  with few colours, a title wider than the picture.
- A set that explains the face: overview with callouts, dark and light, accent colours, the main data element
  (e.g. weather), the field choices.

### After the images exist

- Keep the raw simulator captures in `design/drafts/captures/` and the composing script in `design/drafts/store_tools/`:
  every visible change (icons, colours, always-on) means recapture from a fresh temporary copy and regenerate all
  images, then rebuild the packages. Do this once at the end of the changes, not after each one.
- Features that depend on the hardware (touch and hold on fields, always-on) get a short callout in one image and a
  line in the texts, with the limit ("watches with a touchscreen").

## 6. Texts

Use `templates/store/listing.md`, one file per store language:

- Written for a stranger who installs the face, not for the developer. No class names, property ids or
  internal terms.
- Name limits honestly ("on watches with a touchscreen", "depending on your watch").
- Use a neutral word for brand names of platform features (e.g. "energy level") and the same word in the images.
- "What's new" answers in this order: what is new, where to find it (which app, which menu), what exactly can
  be done, when it takes effect, what stays as it was.
- If a humanizer skill is installed, run the texts through it and keep every fact.
- Only the fenced blocks are copied into the form; the note lines at the top of the file stay out.

## 7. Hand over

1. Fill `design/store/README.md` from `templates/store/UPLOAD-GUIDE.md`: files, order (USB test → beta →
   test on the watch → public), what to check on the watch, which store field gets which file.
2. Record the version, package files and app ids in `STATUS.md` and as a git tag.
3. Tell the user what was verified and what was not (e.g. the upload form itself, the phone settings before
   the beta is installed).
