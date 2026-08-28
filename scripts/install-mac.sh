#!/usr/bin/env bash
# Installs BASILISK Browser's policy-based hardening onto an existing
# Firefox install on macOS (tier 1, no compiling, works today). Firefox on
# macOS reads policies.json from inside the app bundle itself.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICIES_SRC="$REPO_ROOT/policy/policies.json"
USER_JS_SRC="$REPO_ROOT/pref/user.js"

echo "BASILISK Browser, tier 1 hardening installer (policy + pref overrides)"
echo

FIREFOX_APP="/Applications/Firefox.app"
installed_policy=false

if [[ -d "$FIREFOX_APP" ]]; then
  DIST_DIR="$FIREFOX_APP/Contents/Resources/distribution"
  sudo mkdir -p "$DIST_DIR"
  sudo cp "$POLICIES_SRC" "$DIST_DIR/policies.json"
  echo "installed: $DIST_DIR/policies.json"
  installed_policy=true
fi

if [[ "$installed_policy" == false ]]; then
  echo "warning: Firefox.app not found in /Applications. Copy"
  echo "  $POLICIES_SRC"
  echo "  to <Firefox.app>/Contents/Resources/distribution/policies.json manually."
fi

echo
# Firefox's enterprise Preferences policy only accepts an allowlist of prefs.
# Ten of the hardening prefs this project cares about (resistFingerprinting,
# firstparty.isolate, donottrackheader, and others) are rejected with
# "Preference not allowed for stability reasons" and were silently dropped,
# so user.js is not an optional extra: it is the only thing that applies
# them. Default to yes accordingly.
read -r -p "Copy pref/user.js into your Firefox profile? [Y/n] " reply
if [[ ! "$reply" =~ ^[Nn]$ ]]; then
  profile_dir=$(find "$HOME/Library/Application Support/Firefox/Profiles" -maxdepth 1 -name "*.default*" -type d 2>/dev/null | head -1)
  if [[ -z "$profile_dir" ]]; then
    echo "no default profile found. Find yours via about:support -> Profile Folder,"
    echo "then copy $USER_JS_SRC there yourself."
  else
    cp "$USER_JS_SRC" "$profile_dir/user.js"
    echo "installed: $profile_dir/user.js"
  fi
fi

echo
echo "Done. Restart Firefox for policies.json to take effect (check"
echo "about:policies in the browser to confirm it loaded)."
echo
echo "This is tier 1 (policy/pref hardening on stock Firefox). See the"
echo "repo README for tier 2 (a fully rebranded, source-patched build)."
