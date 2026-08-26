#!/usr/bin/env bash
# Installs BASILISK Browser's policy-based hardening onto an existing
# Firefox install (tier 1 — no compiling, works today). Tries every policy
# location Mozilla's Firefox builds actually read on Linux, since it varies
# by how Firefox was installed (apt .deb, Mozilla's official .tar.bz2, or a
# snap package). Also offers to copy the pref/user.js overrides into your
# active profile.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
POLICIES_SRC="$REPO_ROOT/policy/policies.json"
USER_JS_SRC="$REPO_ROOT/pref/user.js"

echo "BASILISK Browser — tier 1 hardening installer (policy + pref overrides)"
echo

# --- 1. Install policies.json wherever this Firefox build will read it ---
installed_policy=false

# Mozilla's snap package reads system policy from /etc/firefox/policies/.
if snap list firefox >/dev/null 2>&1; then
  sudo mkdir -p /etc/firefox/policies
  sudo cp "$POLICIES_SRC" /etc/firefox/policies/policies.json
  echo "installed: /etc/firefox/policies/policies.json (snap Firefox)"
  installed_policy=true
fi

# apt (.deb) and Mozilla's official tarball both read distribution/policies.json
# next to the firefox binary.
for candidate in /usr/lib/firefox /usr/lib64/firefox /opt/firefox; do
  if [[ -d "$candidate" ]]; then
    sudo mkdir -p "$candidate/distribution"
    sudo cp "$POLICIES_SRC" "$candidate/distribution/policies.json"
    echo "installed: $candidate/distribution/policies.json"
    installed_policy=true
  fi
done

if [[ "$installed_policy" == false ]]; then
  echo "warning: couldn't find a known Firefox install location — copy"
  echo "  $POLICIES_SRC"
  echo "  to <your-firefox-install-dir>/distribution/policies.json manually."
fi

# --- 2. Offer to copy user.js into the active profile ---
echo
read -r -p "Copy pref/user.js into your Firefox profile too? [y/N] " reply
if [[ "$reply" =~ ^[Yy]$ ]]; then
  profile_dir=$(find "$HOME/.mozilla/firefox" -maxdepth 1 -name "*.default*" -type d 2>/dev/null | head -1)
  if [[ -z "$profile_dir" ]]; then
    echo "no default profile found under ~/.mozilla/firefox — find yours via"
    echo "about:support -> Profile Folder, then copy $USER_JS_SRC there yourself."
  else
    cp "$USER_JS_SRC" "$profile_dir/user.js"
    echo "installed: $profile_dir/user.js"
  fi
fi

echo
echo "Done. Restart Firefox for policies.json to take effect (check"
echo "about:policies in the browser to confirm it loaded)."
echo
echo "This is tier 1 (policy/pref hardening on stock Firefox) — see the"
echo "repo README for tier 2 (a fully rebranded, source-patched build)."
