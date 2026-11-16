# Store material <APP_NAME> (<x.y.z>)

Prepared by the agent, checked and uploaded by you. "Not verified" means: no source in the SDK documentation
or on Garmin's pages. Field names in the upload form may differ slightly.

## 0. Once, before the first release
1. Create a Garmin developer account (Garmin Developer Agreement).
2. Back up the developer key (`~/.garmin/developer_key.der`) in several places outside the project. Every
   update must be signed with the same key; without it there are no more updates.

## 1. USB test on your watch
1. File: `bin/release/<device>/<APP_NAME>.prg` (`scripts/install-watch.sh <device>`).
2. Copy it to `GARMIN/APPS/` on the watch (macOS: MTP tool such as OpenMTP, quit Garmin Express first;
   Windows: File Explorer). Select the face on the watch.
3. Check everything from section 3 except the phone settings (they need a store or beta install).
4. Delete the USB version from the watch before installing the beta.

## 2. Upload the beta
1. File: `bin/store/<APP_NAME>-beta.iq` (own, fixed beta app id <beta id>).
2. Developer page "Submit an App", upload the file, tick **Beta App**, enter version <x.y.z>.
3. If the form asks for images or texts already, use the files from section 5.

## 3. Test the beta on your watch
- <Checks from STATUS.md "Not checked": seconds, animation, always-on on/off, menus, touch and hold ...>
- Phone settings: every setting appears and every change arrives on the watch.
- Report findings to the agent. The beta can be updated with the same id as often as needed.

## 4. Upload the public version (only when the beta is fine)
1. File: `bin/store/<APP_NAME>.iq` (public app id <public id>), **without** the Beta App tick.
2. Version <x.y.z>, images and texts from section 5.
3. Review: usually within 72 hours according to the SDK documentation; a rejection comes by e-mail with reasons.
4. Beta and public app are two apps: remove the beta from the watch when the public one is installed.

## 5. Which file goes where

| File | Content | Store field |
|---|---|---|
| `icon_500.png` | App icon, 500 × 500 px | Icon |
| `screenshot_01_*.png` … | Screenshots | Screenshots |
| `hero_1440x720.png` | Hero image (optional) | Hero image |
| `listing_<lang>.md` | Name, short and full description, What's new, permissions | Texts of that language |

## 6. After the release
- Crash reports: ERA viewer of the SDK tools.
- Updates: new `.iq`, same developer key, higher version number.
