# Question round

Goal: understand the person who wants the watch face well enough that nothing has to be guessed. Ask in the
user's language, three or four questions at a time, each with a recommended default. Skip what is already
answered. Write every answer into `CLAUDE.md` with the date.

The questions marked **(must)** block the start. The others can be answered when their topic comes up.

## 1. Person and goal

- **(must)** Only your own watch or several devices, and which model do you wear? Asked in section 6, which
  comes first when the user has not named a watch yet.
- Is the watch face only for you, for friends, or for the Connect IQ Store?
- How experienced are you with Connect IQ? (decides how much you explain: key, simulator, sideload)
- What do you look at most often on your watch? (this becomes the largest element)

## 2. Look

- **(must)** Is there a reference: photo, sketch, existing watch face? Which parts of it count, which do not?
- Style: analog, digital, a real-world object (meter, dashboard), minimal?
- Light, dark, or both selectable? Accent colours: fixed, or a list to choose from, and how many?
  Every colour is needed once per background and once per display type and must pass the contrast test
  ([best-practices.md](best-practices.md), "Colours and readability"). Show the user the palette with its
  contrast values before building it in; a colour of the reference that is too weak on one background gets
  a darker or lighter variant there, and the user confirms it.
- **(must)** List the elements from top to bottom. The list decides, not the picture.
- What must be left out on purpose?
- Decorative elements (screws, frames, glow)? Custom font or system font?

## 3. Data

- **(must)** Which values: time, seconds, date, heart rate, steps, calories, distance, battery, VO2max,
  weekly sport totals, weather, notifications, Bluetooth, alarm ...?
- For each value: icon, unit text, number format (decimals, thousands separator)?
- Time: 12 h, 24 h, or follow the watch setting? Leading zero?
- Units: follow the watch (km/miles) or fixed?
- Date format and weekday language: fixed or follow the watch language?
- What is shown when a value is missing? (default `--`)
- Calories: the API gives total calories including basal rate, not "active calories". Is that fine?

Check each wish against the SDK documentation before promising it. Some things are not available to a watch
face (observed with SDK 9.3.0: no short tap, no alarm screen to open, activity history without sub-sport).
Tell the user early and offer what is possible.

## 4. Behaviour

- Seconds: shown? (only possible while the display is active, about 10 s after a wrist turn)
- Animation: none, or something small? How often, how long? (costs battery, only in active mode)
- Always-on display: what should the dimmed view show? (AMOLED limit: under 10 % lit pixels)
- Touch: should touch-and-hold on an element open something (e.g. the system view of that value)?

## 5. Settings

- Should elements be switchable on and off? Which ones?
- Should data fields be selectable (slots with a list of data kinds)?
- Where: on the watch (works for sideloaded apps too), in the phone app (store and beta apps only), or both?
- Menu languages? (default English, plus the user's language)
- What happens with the free space when an element is hidden: redistribute or leave empty?

## 6. Devices

Ask these in this order. The answer decides the manifest, the palettes and the test effort, so it blocks the
start. Do not pick a device list for the user.

1. **(must)** Is the watch face only for your own watch, or for several devices?
2. **Only my watch:** which model exactly? (e.g. "Forerunner 165") Look up the device id with
   `scripts/devices.sh find <name>` and show the user the match, including the display type (AMOLED or MIP)
   it brings. If several ids match (sizes, music editions), ask which one.
3. **Several devices:** **(must)** only AMOLED watches, or MIP watches too? Show what each answer means with
   `scripts/devices.sh list amoled` and `scripts/devices.sh list mip`: round watches from the installed device
   profiles (with SDK 9.3.0: 40 AMOLED and 19 MIP, 59 in all, see [devices.md](devices.md)). MIP needs its
   own 64-colour palette and has small screens of 218–280 px. Then ask for the model of the user's own watch
   as well: it becomes the primary device and the default of the scripts.
- Round only? (default yes. Rectangular and semi-round watches need their own layout:
  `scripts/devices.sh list all --any-shape`)
- Oldest watches to support? (sets `minApiLevel`, default 5.2.0; `--min-api` shows what an older level adds.
  Newer API features need a fallback or exclude old devices)

Write the chosen list into `CLAUDE.md` (id, resolution, display type) and generate the manifest and jungle
lines with `scripts/devices.sh manifest` and `scripts/devices.sh jungle` instead of typing them.

## 7. Delivery

- **(must)** What do you want at the end: a `.prg` for your watch, an `.iq` for the store, or both?
- Store: beta first, then public? (recommended: test the beta on the own watch, including phone settings)
- App name, and for the store: description languages, icon, screenshots?
- Ask the store question again when the face is ready to be delivered
  ([store-release.md](store-release.md)). A "no" at the start is not a "no" at the end.
- Who uploads? (default: the user. The agent builds the package and writes the steps.)

## 8. Way of working

- Team mode with sub-agents or one agent? Is there a token or time budget?
- Git: local repository with a tag per version? Remote yes or no?
- How should the build be checked: simulator screenshots for you to review, or only the test on the watch?
- Language for chat, and for code and commits? (default: chat in the user's language, code in English)
- Is there a developer key already? Where? (never inside the project)

## After the round

Summarise the answers as a spec in `CLAUDE.md`: goal, element list top to bottom, data sources, settings,
devices, delivery, open points. Mark where each decision came from (user, reference picture, your proposal) so
that proposals are not mistaken for wishes. Add "non-goals" (left out on purpose) and "anti-goals" (must not
happen, e.g. "no new layout machine"). Let the user confirm the spec before code is written.
