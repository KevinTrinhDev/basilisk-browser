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
#
# Profile location depends on how Firefox was installed, and the snap keeps
# its profiles under ~/snap/firefox/common/.mozilla/firefox. A machine that
# used to run the .deb often still has a stale ~/.mozilla/firefox profile
# sitting there from before the switch, so searching that path first would
# happily install user.js into a profile Firefox hasn't opened in a year.
# Pick by most recently used instead of by name, across both roots.
echo
# Firefox's enterprise Preferences policy only accepts an allowlist of prefs.
# Ten of the hardening prefs this project cares about (resistFingerprinting,
# firstparty.isolate, donottrackheader, and others) are rejected with
# "Preference not allowed for stability reasons" and were silently dropped,
# so user.js is not an optional extra: it is the only thing that applies
# them. Default to yes accordingly.
read -r -p "Copy pref/user.js into your Firefox profile? [Y/n] " reply
if [[ ! "$reply" =~ ^[Nn]$ ]]; then
  profile_dir=""
  newest_stamp=0
  for root in "$HOME/snap/firefox/common/.mozilla/firefox" "$HOME/.mozilla/firefox"; do
    [[ -d "$root" ]] || continue
    while IFS= read -r candidate; do
      # A profile that has never been launched has no places.sqlite; skip it
      # rather than treating a directory that merely exists as "active".
      [[ -f "$candidate/places.sqlite" ]] || continue
      stamp=$(stat -c %Y "$candidate/places.sqlite" 2>/dev/null || echo 0)
      if (( stamp > newest_stamp )); then
        newest_stamp=$stamp
        profile_dir="$candidate"
      fi
    done < <(find "$root" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
  done

  if [[ -z "$profile_dir" ]]; then
    echo "no Firefox profile found under ~/snap/firefox/common/.mozilla/firefox"
    echo "or ~/.mozilla/firefox — find yours via about:support -> Profile"
    echo "Folder, then copy $USER_JS_SRC there yourself."
  else
    echo "most recently used profile: $profile_dir"
    echo "  (last activity: $(date -d "@$newest_stamp" '+%Y-%m-%d %H:%M'))"
    read -r -p "  install user.js there? [Y/n] " confirm
    if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
      cp "$USER_JS_SRC" "$profile_dir/user.js"
      echo "installed: $profile_dir/user.js"
    else
      echo "skipped. Copy $USER_JS_SRC into your profile manually."
    fi
  fi
fi

# --- 3. Native messaging host, if the basilisk extension is set up ---
#
# Snap Firefox only gets read access to $HOME/.mozilla/firefox (for migrating
# an old .deb profile). It cannot see $HOME/.mozilla/native-messaging-hosts,
# which is where a non-snap Firefox looks, so a manifest installed only there
# leaves the daemon bridge silently dead under the snap.
if snap list firefox >/dev/null 2>&1; then
  snap_nmh="$HOME/snap/firefox/common/.mozilla/native-messaging-hosts"
  legacy_nmh="$HOME/.mozilla/native-messaging-hosts"
  if [[ -f "$legacy_nmh/com.basilisk.agentdaemon.json" && ! -f "$snap_nmh/com.basilisk.agentdaemon.json" ]]; then
    echo
    echo "note: found a BASILISK native-messaging manifest at"
    echo "  $legacy_nmh/com.basilisk.agentdaemon.json"
    echo "which snap Firefox cannot read. Copying it to:"
    echo "  $snap_nmh/"
    mkdir -p "$snap_nmh"
    cp "$legacy_nmh/com.basilisk.agentdaemon.json" "$snap_nmh/"
  fi
fi

echo
echo "Done. Restart Firefox for policies.json to take effect (check"
echo "about:policies in the browser to confirm it loaded)."
echo
echo "This is tier 1 (policy/pref hardening on stock Firefox) — see the"
echo "repo README for tier 2 (a fully rebranded, source-patched build)."
