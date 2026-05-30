// Pop to Pane — MV3 service worker.
//
// Wires all three triggers (page context menu, keyboard command, toolbar action
// button) to one popToPane(url). The cascade counter is persisted in
// chrome.storage.local so panes keep staircasing across service-worker restarts.
//
// MV3 note: the service worker is ephemeral, so every event listener is
// registered at the top level — they re-bind each time the worker spins up.

const MENU_ID = "pop-to-pane";       // page context-menu item id
const COMMAND_NAME = "pop-to-pane";  // keyboard command name (see manifest.json)

// Pane geometry.
const PANE_WIDTH = 640;
const PANE_HEIGHT = 900;
const CASCADE_STEP = 36; // px offset added per pane
const CASCADE_CYCLE = 6; // restart the staircase every N panes
const BASE_LEFT = 80;
const BASE_TOP = 80;

// Only http(s) pages can be popped. chrome://, extension pages, file://,
// the New Tab page, etc. are ignored.
function isPoppable(url) {
  if (!url) return false;
  try {
    const protocol = new URL(url).protocol;
    return protocol === "http:" || protocol === "https:";
  } catch (e) {
    return false;
  }
}

// Read the current cascade index, persist the incremented value, return the
// value to use for this pane.
async function nextCascadeIndex() {
  const { cascadeIndex = 0 } = await chrome.storage.local.get("cascadeIndex");
  await chrome.storage.local.set({ cascadeIndex: cascadeIndex + 1 });
  return cascadeIndex;
}

// Core: open `url` in a clean, chrome-less popup window in the CURRENT profile
// (so existing logins/sessions are reused — no re-auth).
async function popToPane(url) {
  if (!isPoppable(url)) {
    // Non-web page — ignore, but surface why on the toolbar badge.
    await chrome.action.setBadgeBackgroundColor({ color: "#9CA3AF" });
    await chrome.action.setBadgeText({ text: "skip" });
    return;
  }

  // A real page is being popped — clear any prior "skip" badge.
  await chrome.action.setBadgeText({ text: "" });

  const i = await nextCascadeIndex();
  const offset = (i % CASCADE_CYCLE) * CASCADE_STEP;

  await chrome.windows.create({
    url,
    type: "popup", // no tab strip, no toolbar (a thin OS title bar remains — see README)
    width: PANE_WIDTH,
    height: PANE_HEIGHT,
    left: BASE_LEFT + offset,
    top: BASE_TOP + offset,
    focused: true,
  });
  // The original tab is left untouched (non-destructive).
}

// --- Trigger wiring (all listeners registered synchronously at top level) ---

// 1. Page context-menu item. Created in onInstalled; removeAll() first so a
//    reload of the unpacked extension doesn't hit a duplicate-id error.
chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.removeAll(() => {
    chrome.contextMenus.create({
      id: MENU_ID,
      title: "Pop into clean pane",
      contexts: ["page"],
    });
  });
});

chrome.contextMenus.onClicked.addListener((info, tab) => {
  if (info.menuItemId !== MENU_ID) return;
  // info.pageUrl is the page that was right-clicked; fall back to the tab URL.
  popToPane(info.pageUrl || (tab && tab.url));
});

// 2. Keyboard command (Command+Shift+U on mac; rebindable at
//    chrome://extensions/shortcuts).
chrome.commands.onCommand.addListener((command, tab) => {
  if (command !== COMMAND_NAME) return;
  if (tab && tab.url) {
    popToPane(tab.url);
  } else {
    // Older Chrome (or edge cases) may not pass the tab — query for it.
    chrome.tabs.query({ active: true, lastFocusedWindow: true }, (tabs) => {
      if (tabs && tabs[0]) popToPane(tabs[0].url);
    });
  }
});

// 3. Toolbar action button. No default_popup in the manifest, so onClicked fires.
chrome.action.onClicked.addListener((tab) => {
  popToPane(tab && tab.url);
});
