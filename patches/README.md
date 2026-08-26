# Source patches (tier 2 — not needed for tier 1 policy hardening)

Most of BASILISK Browser's hardening (telemetry, fingerprinting resistance,
DoH, tracking protection, Pocket/sponsored content removal) is achievable
entirely through `policy/policies.json` and `pref/user.js` — see the repo
root README. That's tier 1: works today, no compiling, no source checkout.

Real source patches (this directory) are only for the handful of things
Firefox's preference/policy system genuinely can't control — things baked
into C++ or JS that don't have a pref, like hard-coded telemetry endpoints
or default-search-engine partner code. LibreWolf's actual patch set
(https://gitlab.com/librewolf-community/browser/source) is the best current
reference for what still needs a real patch versus what a pref now covers
— Firefox has grown more pref-controllable over time, so it's worth
re-checking there before writing a new patch instead of assuming one is
needed.

## Format

Standard unified diffs (`git format-patch` output), one logical change per
file, numbered `0001-`, `0002-`, ... applied in order against a
`mozilla-esr<N>` checkout by `.github/workflows/build.yml`. Name each patch
for what it does, e.g. `0001-remove-hardcoded-telemetry-pings.patch`.

## None written yet

Writing a patch that applies cleanly requires testing it against a real,
specific Firefox source checkout (multi-GB clone, hours to build) — not
something to fabricate without that checkout in hand, since an untested
patch is worse than no patch (silent merge conflicts, or worse, a patch
that "applies" but doesn't do what its name claims). The build workflow is
scaffolded and ready; patches land here once actually written and verified
against a checkout, most likely via `.github/workflows/build.yml` runs.
