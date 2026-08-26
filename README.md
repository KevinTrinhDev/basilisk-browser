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

- [x] Tier 1: policy/pref hardening, install scripts (Linux, Windows)
- [ ] BASILISK Browser branding/icon set (design work)
- [ ] First real tier-2 build (needs a self-hosted/larger CI runner)
- [ ] macOS install script (tier 1)
- [ ] Firefox for Android fork (same GeckoView approach as Fennec/Focus
      forks). Feasible, not started. iOS isn't possible: Apple restricts
      iOS/iPadOS to WebKit-based extensions only, which rules out this
      entire architecture on that platform, not just this project.

## License

MPL-2.0, matching Firefox's own license and the basilisk repo.
