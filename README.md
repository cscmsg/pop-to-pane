# Pop to Pane

A Manifest V3 Chrome extension (macOS-friendly) that pops the current tab into a
clean, chrome-less popup window — so you can arrange site "panes" around your
desktop for monitoring.

The popup opens in your **current Chrome profile**, so existing logins/sessions
just work: no re-auth, no separate `--user-data-dir`.

## What it does

- Opens the active tab's URL in a new `popup`-type window: no tab strip, no
  toolbar, no address bar. (A thin OS title bar remains — see
  [Fully borderless](#fully-borderless-optional-macos).)
- Default size **640 × 900**.
- **Cascades** each new pane by 36px, cycling every 6, so panes staircase
  instead of stacking on top of each other.
- Only acts on **http(s)** pages — `chrome://`, extension, `file://`, and New
  Tab pages are ignored (the toolbar badge shows `skip` until the next real pop).
- **Non-destructive** — your original tab stays open.
- Popups are independent OS windows: moving or closing one doesn't affect the
  others.

## Three ways to trigger it

Chrome does **not** let extensions add items to the *tab-strip* right-click
menu, so the trigger is offered three other ways — all calling the same
`popToPane(url)`:

1. **Right-click the page** → "Pop into clean pane".
2. **Keyboard:** `⌘⇧U` (Command+Shift+U) on macOS — rebindable.
3. **Toolbar button** — click the Pop to Pane action icon.

## Install (Load unpacked)

1. Open `chrome://extensions`.
2. Toggle **Developer mode** (top-right) on.
3. Click **Load unpacked** and select this folder (`pop-to-pane/`).
4. The "Pop to Pane" action button appears in the toolbar. Pin it via the
   puzzle-piece menu if it's hidden.

There is no build step — it loads as-is.

## Rebinding the keyboard shortcut

1. Open `chrome://extensions/shortcuts`.
2. Find **Pop to Pane** and set "Pop the current tab into a clean pane" to
   whatever combo you like.

If `⌘⇧U` is already claimed by another extension, Chrome leaves it unset — just
assign a free combo here.

## Fully borderless (optional, macOS)

The extension API **cannot** remove the popup's thin OS title bar. For a truly
borderless, app-style frame, use the included **`borderless-pane.sh`**, which
launches Chrome in `--app` mode:

```sh
/Applications/Google Chrome.app/Contents/MacOS/Google Chrome \
  --app="<URL>" --user-data-dir=<per-pane profile> \
  --window-position=X,Y --window-size=640,900
```

**The trade-off:** `--app` mode requires a separate `--user-data-dir`, i.e. a
**separate Chrome profile per pane** — so each pane needs a **one-time login**.
The script cycles through 6 reusable pane profiles under `~/.pop-to-pane/panes/`,
so it's 6 logins total and each slot is re-poppable, matching the 6-step cascade.

### Run it directly

```sh
./borderless-pane.sh
```

It reads the front Chrome window's active-tab URL via AppleScript, then opens it
borderless at the next cascade slot.

### Bind it to a global hotkey

1. Open the **Shortcuts** app → **+** (new shortcut).
2. Add a **Run Shell Script** action.
3. Paste this file's absolute path, e.g. `/Users/<you>/pop-to-pane/borderless-pane.sh`.
4. Open the shortcut's details and assign a keyboard shortcut.

It then fires from any tab regardless of which app is focused — it targets
Chrome's front window directly.

> First launch of each slot shows the page logged-out; sign in once and that
> slot remembers it. Re-popping a slot whose window is still open reuses that
> profile (Chrome may add a window to the running instance rather than spawning
> a fresh process).

## Files

| File | Purpose |
|------|---------|
| `manifest.json` | MV3 manifest — name, permissions (`contextMenus`, `activeTab`, `storage`), service worker, action, keyboard command. |
| `background.js` | Service worker. Wires all three triggers to one `popToPane(url)`; persists the cascade counter in `chrome.storage.local`. |
| `borderless-pane.sh` | Optional macOS `--app`-mode launcher for a fully borderless frame. |
| `LICENSE` | MIT. |
| `PRIVACY.md` | Privacy policy (nothing is collected; required as a Web Store listing field). |
| `README.md` | This file. |

No icon files are bundled, so Chrome shows a default action icon. Add a
`default_icon` entry to `manifest.json` if you want a custom one.

## Notes

- The cascade counter lives in `chrome.storage.local` and only advances (mod 6
  for position). It is not reset on browser restart — it just continues the
  staircase, which is fine.
- **`activeTab` is what lets the extension read the current tab's address**, and
  only at the moment you invoke it — the grant is scoped to that one tab and
  lapses when you navigate away. All three triggers (action click, context menu,
  keyboard command) are gestures Chrome accepts as granting it, so the broader
  `tabs` permission is not needed. No host permissions are requested, and the
  extension never reads page content.
- The `chrome.tabs.query` call in the command handler is a fallback for the case
  where Chrome does not pass a tab to the listener. `tabs.query` itself needs no
  permission; the address comes back populated because `activeTab` has just been
  granted for that tab. If it ever is not, `isPoppable` rejects the empty value
  and the toolbar badge shows `skip` rather than the extension failing.

## Privacy

Nothing is collected, stored about you, or transmitted. See [PRIVACY.md](PRIVACY.md).

## License

MIT — see [LICENSE](LICENSE).
