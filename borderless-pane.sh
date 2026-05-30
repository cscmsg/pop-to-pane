#!/usr/bin/env bash
#
# Pop to Pane — borderless (app-mode) variant for macOS.
#
# The extension's popup window keeps a thin OS title bar that the extension API
# cannot remove. This script gets a truly borderless frame by launching Chrome
# in --app mode instead.
#
# Trade-off: --app mode requires a separate --user-data-dir, i.e. a separate
# Chrome profile per pane, so each pane needs a ONE-TIME login. To keep that
# bounded, this script cycles through 6 reusable pane profiles (under
# ~/.pop-to-pane/panes/) and matches the extension's 6-step position cascade —
# 6 logins total, each slot re-poppable.
#
# Bind to a global hotkey with the macOS Shortcuts app:
#   Shortcuts.app -> new shortcut -> add a "Run Shell Script" action ->
#   paste the absolute path to this file -> assign a keyboard shortcut.
# It then fires from any app, targeting Chrome's front window directly.

set -euo pipefail

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
STATE_DIR="${HOME}/.pop-to-pane"
PROFILES_DIR="${STATE_DIR}/panes"
COUNTER_FILE="${STATE_DIR}/counter"

# Pane geometry — mirrors the extension.
WIDTH=640
HEIGHT=900
STEP=36
CYCLE=6
BASE_X=80
BASE_Y=80

notify() { osascript -e "display notification \"$1\" with title \"Pop to Pane\"" >/dev/null 2>&1 || true; }

if [[ ! -x "${CHROME}" ]]; then
  notify "Google Chrome not found at the default path."
  echo "Google Chrome not found at: ${CHROME}" >&2
  exit 1
fi

mkdir -p "${PROFILES_DIR}"

# Read the front Chrome window's active-tab URL.
URL="$(osascript -e 'tell application "Google Chrome" to get URL of active tab of front window' 2>/dev/null || true)"

if [[ -z "${URL}" ]]; then
  notify "No Chrome window/tab found."
  exit 1
fi

# Only act on http(s) URLs.
case "${URL}" in
  http://*|https://*) ;;
  *)
    notify "Skipped non-web URL."
    exit 0
    ;;
esac

# Read + advance the cascade counter (defensive against a corrupted file).
COUNT=0
if [[ -f "${COUNTER_FILE}" ]]; then
  COUNT="$(cat "${COUNTER_FILE}" 2>/dev/null || echo 0)"
  [[ "${COUNT}" =~ ^[0-9]+$ ]] || COUNT=0
fi
echo "$(( COUNT + 1 ))" > "${COUNTER_FILE}"

SLOT=$(( COUNT % CYCLE ))
OFFSET=$(( SLOT * STEP ))
X=$(( BASE_X + OFFSET ))
Y=$(( BASE_Y + OFFSET ))
PROFILE="${PROFILES_DIR}/pane-${SLOT}"

# Launch a borderless app window in its own profile, detached so a hotkey
# binding returns immediately.
"${CHROME}" \
  --app="${URL}" \
  --user-data-dir="${PROFILE}" \
  --window-position="${X},${Y}" \
  --window-size="${WIDTH},${HEIGHT}" \
  --no-first-run \
  --no-default-browser-check \
  >/dev/null 2>&1 &

disown 2>/dev/null || true
