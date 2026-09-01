# Privacy Policy — Pop to Pane

*Last updated: 1 September 2026*

## The short version

Pop to Pane collects nothing, stores nothing about you, and sends nothing
anywhere. There is no server, no account, no analytics, and no third party
involved.

## What the extension handles

**The address of the page you are currently on.** When you trigger Pop to Pane —
by clicking the toolbar button, choosing "Pop into clean pane" from the
right-click menu, or pressing the keyboard shortcut — the extension reads the
current tab's address so it can open that same address in a new window. The
address is used at that moment and is not written down, kept, or transmitted.

**A counter.** A single number is kept in the browser's local extension storage
(`chrome.storage.local`) so that each new pane is offset slightly from the last
one instead of landing in the same spot. It counts panes. It contains no
addresses and nothing about you, it never leaves your computer, and you can clear
it at any time by removing the extension.

## What the extension does not do

- It does not read, alter, or transmit the content of any page.
- It does not track browsing history, and it keeps no record of pages you pop.
- It requests no host permissions, so it has no standing access to any website.
- It contains no analytics, telemetry, crash reporting, or advertising code.
- It makes no network requests of its own.
- Nothing is sold or shared with anyone, because nothing is collected.

## Why the permissions are what they are

- **`activeTab`** — grants access to the current tab's address only at the moment
  you invoke the extension, and only for that tab. It is the narrowest permission
  that allows a "pop this page" action to work. The access lapses when you
  navigate away or close the tab.
- **`contextMenus`** — adds the "Pop into clean pane" entry to the right-click
  menu.
- **`storage`** — holds the pane counter described above.

No host permissions (`<all_urls>` or otherwise) are requested, which is why the
extension cannot see any page you have not explicitly acted on.

## The companion script

The repository also contains `borderless-pane.sh`, an optional macOS shell script
for opening a fully borderless window. It runs on your own machine, is not part of
the extension, is not distributed through the Chrome Web Store, and likewise sends
nothing anywhere.

## Changes

If this policy ever changes, the revision will appear in this file and its date
will be updated. The repository's history is the full record.

## Contact

Questions or concerns: open an issue at
<https://github.com/cscmsg/pop-to-pane/issues>.
