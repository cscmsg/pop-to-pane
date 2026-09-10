# Chrome Web Store — submission prep

*Prepared 2026-09-01. Everything the Developer Dashboard asks for, drafted in advance so the
submission is a paste rather than a writing exercise. Not part of the extension.*

## Before you start

- **One-time US$5 developer registration** (verified 2026-09-01), per account rather than per
  extension, and it covers multiple extensions.
- **A privacy policy URL is required only if the extension handles user data.** Google's wording:
  *"If your Product handles any user data, then you must post an accurate and up to date privacy
  policy."* This extension collects nothing, so it is arguably exempt — but it does read the current
  tab's address to do its job, and reviewers respond better to a policy than to an argument about
  whether one is needed. [PRIVACY.md](PRIVACY.md) exists for this. Host it somewhere with a stable
  URL (GitHub's rendered view of `PRIVACY.md` is acceptable) and paste that link into the dashboard.
- **Icons are not bundled.** Chrome falls back to a default action icon, which looks unfinished on a
  store listing. Add a `default_icon` (16/32/48/128 px) before submitting.

## Single purpose

The dashboard requires a single-purpose statement, and under the **Limited Use policy enforced from
2026-08-01** everything the extension collects must be strictly necessary to it.

> Pop to Pane opens the page you are currently viewing in a clean, chrome-less popup window, so it
> can be arranged on the desktop as a monitoring pane.

That is the whole extension. Nothing it does falls outside it.

## Permission justifications

The dashboard asks for one per permission. Keep these literal — reviewers compare them against the
code.

**`activeTab`**
> Used to read the address of the tab the user is currently viewing, at the moment they invoke the
> extension, so that the same address can be opened in a new popup window. The extension is invoked
> only by an explicit user gesture (toolbar button, context menu item, or keyboard shortcut), each of
> which grants this permission for that one tab. No page content is read.

**`contextMenus`**
> Used to add a single "Pop into clean pane" item to the page right-click menu, which is one of the
> three ways the user invokes the extension.

**`storage`**
> Used to persist one integer, the pane cascade counter, in local extension storage so consecutive
> popup windows are offset from one another instead of stacking. It holds no addresses and no user
> information, and never leaves the device.

**Host permissions**
> None requested.

**Remote code**
> None. The extension is a single service worker bundled with the package; it loads no external
> scripts and makes no network requests.

## Data usage disclosures

The dashboard presents these as checkboxes with a certification. All should be answered **no / not
collected**:

| Category | Answer |
|---|---|
| Personally identifiable information | Not collected |
| Health information | Not collected |
| Financial and payment information | Not collected |
| Authentication information | Not collected |
| Personal communications | Not collected |
| Location | Not collected |
| Web history | **Not collected.** The current tab's address is read transiently to open it and is never stored or transmitted. |
| User activity | Not collected |
| Website content | Not collected |

Then certify: data is not sold to third parties, is not used or transferred for purposes unrelated to
the single purpose, and is not used to determine creditworthiness or for lending.

## Listing copy

**Name:** Pop to Pane

**Short description** (132 char limit):
> Pop the current tab into a clean, chrome-less window you can park anywhere. Keeps your login. Great for monitoring panes.

**Detailed description:**
> Pop to Pane opens whatever page you are on in a bare popup window — no tab strip, no toolbar, no
> address bar — so you can arrange pages around your desktop and watch them.
>
> It opens in your current Chrome profile, so anything you are already signed in to just works. No
> re-authentication, no separate profile.
>
> - Three ways to trigger it: the toolbar button, "Pop into clean pane" in the right-click menu, or a
>   keyboard shortcut (rebindable at chrome://extensions/shortcuts).
> - Panes cascade by 36px and cycle every six, so they staircase instead of landing on top of each
>   other.
> - Your original tab stays open. Panes are independent windows — moving or closing one does not
>   affect the others.
> - Only works on http(s) pages; browser and extension pages are skipped.
>
> Privacy: it collects nothing, stores nothing about you, and sends nothing anywhere. There is no
> server and no analytics. It requests no host permissions, so it has no standing access to any
> site — it reads the current tab's address only at the moment you invoke it, and never reads page
> content.
>
> Open source (MIT): https://github.com/cscmsg/pop-to-pane

**Category:** Workflow & Planning · **Language:** English

## Known limitation to state honestly

The extension API cannot remove the popup's thin OS title bar. For a genuinely borderless frame the
repository includes `borderless-pane.sh`, a macOS script that launches Chrome in `--app` mode. It
cannot ship through the Web Store, and it carries a real trade-off: `--app` mode needs a separate
`--user-data-dir`, so each pane needs a one-time sign-in. Do not imply the extension itself produces
a fully borderless window.

## Pre-submit checklist

- [x] Icons added (16/32/48/128 in `icons/`, drawn by `scripts/make_icons.swift`), wired as both `icons` and the action's `default_icon`
- [ ] Screenshots (1280×800 or 640×400), at least one
- [ ] Privacy policy hosted at a stable URL and pasted into the dashboard
- [ ] `$5` registration paid
- [ ] Version in `manifest.json` set for the release (currently `1.0.0`)
- [ ] Loaded unpacked and all three triggers re-tested **after the `activeTab` change**
