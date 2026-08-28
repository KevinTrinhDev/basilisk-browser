# BASILISK Browser

A hardened Firefox distribution, built the way real privacy browsers
actually do it. LibreWolf, Mullvad Browser, and Brave all skip writing a
new engine and instead ship a patch set and hardened defaults on top of an
existing, professionally maintained engine (Firefox/Gecko or Chromium).
Engine-level security (sandboxing, JIT hardening, CVE response) is a
full-time job for hundreds of engineers, not something worth
reimplementing. This repo does the same thing for Firefox, with
[BASILISK](https://github.com/KevinTrinhDev/basilisk) (the AI copilot
extension and daemon) pre-configured to install alongside it.

## Two tiers, honestly labeled

**Tier 1: policy/pref hardening.** Works today, no compiling.
`policy/policies.json` and `pref/user.js` turn a stock Firefox install
into a hardened one: telemetry off, tracking protection on strict,
fingerprint resistance on, DNS-over-HTTPS on, Pocket and sponsored content
stripped, and Firefox's own password manager disabled (BASILISK's
Bitwarden vault bridge replaces it, see `docs/SECURITY-MODEL.md` in the
basilisk repo for why). Cross-platform: the same `policies.json` format
works on Firefox for Linux, Windows, and macOS.

```bash
# Linux
./scripts/install-linux.sh

# Windows (elevated PowerShell)
.\scripts\install-windows.ps1
```

### Why user.js is not optional

Firefox's enterprise `Preferences` policy only accepts an allowlist of
preferences. Ten of the prefs this project cares about, including
`privacy.resistFingerprinting`, `privacy.firstparty.isolate` and
`privacy.donottrackheader.enabled`, are refused with "Preference not
allowed for stability reasons" and are silently dropped. Verified against
Firefox 155 in `about:policies#errors`.

Those prefs have been removed from `policy/policies.json`, since listing
them there only created the impression they were being applied. They live
in `pref/user.js`, which is therefore the only thing that applies them, and
the install scripts now default that step to yes.

The top-level policies are unaffected and still do real work:
`DisableTelemetry`, `EnableTrackingProtection` (including cryptomining,
fingerprinting and email tracking), `DisablePocket`, `DNSOverHTTPS`,
`SanitizeOnShutdown` and the rest are applied normally. Only the
free-form `Preferences` block was being filtered.

### If your Firefox is a snap (Ubuntu default)

Snap Firefox keeps its profiles under
`~/snap/firefox/common/.mozilla/firefox`, not `~/.mozilla/firefox`, and it
is granted read-only access to the latter purely so it can migrate an old
.deb profile. Two consequences worth knowing:

- A machine that used to run the .deb usually still has a stale profile in
  `~/.mozilla/firefox`. `scripts/install-linux.sh` picks the most recently
  used profile across both locations rather than the first one matching
  `*.default*`, so it will not write `user.js` into a profile Firefox has
  not opened in a year.
- Native messaging manifests in `~/.mozilla/native-messaging-hosts` are
  invisible to snap Firefox. The basilisk daemon bridge needs its manifest
  in `~/snap/firefox/common/.mozilla/native-messaging-hosts` instead. The
  install script copies it across if it finds one in the old location.

Policy hardening is unaffected: the snap reads
`/etc/firefox/policies/policies.json`, which the install script already
targets.

**Tier 2: a real rebranded, source-patched build.** Scaffolded, not built
yet. `mozconfig`, `branding/basilisk-browser/`, `patches/`, and
`.github/workflows/build.yml` set up the actual pipeline LibreWolf uses:
clone Firefox ESR, apply patches, build with custom branding, package.
This produces a genuinely distinct binary you could ship to other people.
It isn't run yet because it needs two things that are real work, not
something to fake:

- **Branding art.** Mozilla's Firefox logo is trademarked and can't be
  used in a non-Mozilla build, so BASILISK Browser needs its own icon and
  logo set (see `branding/basilisk-browser/README.md`).
- **A real build environment.** A full Firefox build needs a 5-10GB source
  checkout, a specific toolchain, 30GB+ disk, and 1-3+ hours of compile
  time. Standard GitHub-hosted runners likely can't finish this within
  their limits, so a self-hosted or larger runner is the realistic path.
  The workflow is ready (manual `workflow_dispatch` trigger) for whenever
  that's set up.

## What tier 2 buys that tier 1 cannot

Tier 1 hardening gets you most of the privacy win with no compiling, so it
is fair to ask what the full build is actually for. Beyond a distinct
binary you can hand to someone and the usual PGO/LTO speed gains, there is
one capability tier 1 structurally cannot provide:

**Installing the BASILISK extension without Mozilla in the loop.** Stock
release Firefox refuses unsigned extensions, and
`xpinstall.signatures.required` does not override that on a release build.
So distributing the extension to anyone running stock Firefox means
uploading the `.xpi` to Mozilla's signing service first. That works, and
the signed result can be hosted on GitHub rather than listed on
addons.mozilla.org, but it still puts a third party in the middle of a
project built specifically to avoid required third parties.

A tier-2 build sets `MOZ_REQUIRE_SIGNING=` along with
`--with-unsigned-addon-scopes=app,system` and `--allow-addon-sideload`
(see `mozconfig`), the same combination LibreWolf ships. On that build,
"download the `.xpi` from GitHub and install it" just works. The tradeoff
is stated in the mozconfig: it also allows installing a malicious unsigned
extension, and users who want Mozilla's enforcement back can turn
`xpinstall.signatures.required` on, which does work on a build made this
way.

## Why not build a new engine from scratch

Because that isn't "fork and revamp," that's competing with Chromium and
Gecko's actual R&D budgets. Even well-resourced from-scratch attempts
(Servo, Ladybird) have taken years with growing teams and still aren't
daily-driver-ready. Building on Firefox gets Mozilla's engine security
team for free. A new engine gets you all of their bugs with none of their
staffing.

## Relationship to BASILISK

[`basilisk`](https://github.com/KevinTrinhDev/basilisk) is the AI copilot
extension and companion daemon: page reading and clicking, ad blocking,
vault bridge, VPN status, remote/CLI access. That's where the actual
features live. This repo (`basilisk-browser`) is the vehicle it runs in, a
browser that comes hardened and pre-configured out of the box instead of
requiring a dozen manual about:config changes after installing stock
Firefox. Neither replaces the other. BASILISK the extension works fine on
stock Firefox too, that's the whole current setup. This repo just makes
"hardened by default" not require any manual steps, and eventually gives
you a distinct binary you can hand to someone else, open source and all.

## Roadmap

- [x] Tier 1: policy/pref hardening, install scripts (Linux, Windows, macOS)
- [ ] BASILISK Browser branding/icon set (design work)
- [ ] First real tier-2 build (needs a self-hosted/larger CI runner)
- [ ] Firefox for Android fork (same GeckoView approach as Fennec/Focus
      forks). Feasible, not started. iOS isn't possible: Apple restricts
      iOS/iPadOS to WebKit-based extensions only, which rules out this
      entire architecture on that platform, not just this project.

## License

MPL-2.0, matching Firefox's own license and the basilisk repo.
