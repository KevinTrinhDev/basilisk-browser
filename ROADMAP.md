# Roadmap: performance, efficiency, decentralization, differentiators

This is the honest plan for "make it faster, more efficient, less
storage, decentralized, genius features." Split into what's done, what's
concretely plannable now, and what's genuinely open-ended R&D, so nothing
here reads as promised work that isn't actually scheduled.

## Performance and storage: done

- Extension bundles now built with esbuild `minify: true` (basilisk repo).
  Real, measured effect: background bundle 14.1kb to 8.4kb (about 40%
  smaller), sidebar UI 10.2kb to 6.3kb (about 38%), several content
  scripts nearly halved. Free win, zero behavior change, verified via
  build output and typecheck.
- Ad/tracker blocklist rebuilt from real EasyList and EasyPrivacy data
  (basilisk repo, `scripts/update-blocklist.mjs`) instead of a small hand
  curated list. This surfaced and fixed a real lookup performance bug: the
  old linear scan took 8.3 seconds for 10,000 lookups at this size; a
  Set-based label walk brought that to 8.4ms for 100,000 lookups.
- The blocklist is no longer capped at 20,000 domains on Firefox. That cap
  existed for Chrome's declarativeNetRequest static rule ceiling, which
  never applied to Firefox's webRequest path, so it was discarding about
  75,000 domains on the platform this project actually targets. The
  generator now emits a full list for Firefox and a capped one for Chrome
  from the same extraction run, and honors EasyList exception rules instead
  of dropping them. Firefox coverage went from 20,000 to 95,355 domains.

## Performance and storage: planned for the tier-2 build (mozconfig)

Standard, well understood Firefox build flags, not speculative, to add
once a real build environment exists (see `README.md`'s tier 2 section for
why that isn't today):

- **PGO (Profile-Guided Optimization) plus LTO (Link-Time Optimization)**:
  `ac_add_options --enable-lto=cross` and a PGO training pass. This is
  what makes official Firefox release builds meaningfully faster than a
  plain `--enable-release` build. Skipping it is the single biggest gap
  between "compiles" and "actually fast."
- **Single-locale build** (English only, or your target locales) instead
  of the roughly 100-locale official build. Meaningfully smaller
  installer and binary for close to zero effort
  (`--enable-single-locale`).
- **Strip unused feature surface** case by case rather than blanket
  disabling. Some "unused" features, accessibility APIs especially,
  should stay regardless of binary size.
- **jemalloc** (Firefox's default allocator): confirm it's on. It already
  measurably beats glibc malloc for this workload, just verify the
  mozconfig doesn't accidentally disable it.

None of this is exotic. It's the same list every serious Firefox fork's
build docs cover. It's "planned" rather than "done" purely because it
needs a real build to verify against, not because it's uncertain.

## Decentralization and privacy: reframing what's actually true

"Decentralized browser" isn't a coherent claim on its own. A browser talks
to whatever servers a website's owner controls, and that's inherent to
HTTP, not something a browser vendor can decentralize away. What is real,
and already substantially built in the `basilisk` repo, is removing
required third parties:

| Thing | Default elsewhere | Here |
|---|---|---|
| AI backend | OpenAI/Anthropic cloud | Your own key, your own OpenRouter/local model, your choice |
| Password vault | Browser vendor's cloud sync | Bitwarden, self-hostable as Vaultwarden |
| VPN | Trust a VPN vendor blindly | Status and kill switch on your own WireGuard config |
| Remote access | A vendor's relay server | Your own Tailscale/WireGuard mesh |
| Automation and agent access | Doesn't exist elsewhere | Your own daemon, your own token, nobody else's cloud |

That's the honest version of "decentralized": no single vendor is a
mandatory dependency for any of it. Two more pieces worth adding to that
list, concretely plannable:

- **Self-hosted DNS-over-HTTPS resolver option.** `policy/policies.json`
  currently points DoH at Cloudflare by default, a reasonable default and
  not a lock-in. Document swapping in a self-run resolver (NextDNS, or
  your own `dnscrypt-proxy`) as a one-line config change.
- **Self-hosted sync.** Mozilla's sync server (`syncserver`) is open
  source and self-hostable. Document pointing BASILISK Browser's sync
  prefs at your own instance instead of Mozilla's, for bookmarks and
  history without a vendor in the loop. Real and bounded, just not
  written up yet.

## What actually sets this apart

Being honest about the landscape: LibreWolf, Mullvad Browser, and Brave
compete on hardening a browser. None of them have an AI agent layer at
all. That gap is BASILISK's actual moat, not the browser wrapper around
it.

- **Visible, confirmed AI page interaction.** No other browser has this.
- **Multi-client, safety-gated automation** (the CLI, just shipped). Any
  agent can drive it through the exact same allowlist, kill switch, and
  download caps as the human UI. Nobody else exposes this at all, let
  alone safely.
- **Vault autofill that's more paranoid than mainstream password
  managers, not less.** Two separate explicit confirms (sidebar click,
  then on-page click), the AI categorically excluded from the path, and
  the value never logged or displayed during the fill. Most
  browser-integrated password managers auto-fill silently on page load.
  This deliberately doesn't.
- **AI-action-level kill switch.** Most VPN kill switches block network
  traffic. This additionally refuses to let the agent act at all when the
  tunnel drops, a layer other setups don't have because they don't have
  an agent to gate in the first place.

The realistic "genius feature" isn't a browser trick. It's that the AI
layer already does things no browser, hardened or not, does, and the
browser-hardening work makes the environment it runs in match that same
bar. The actual pitch is "the browser with a safety-gated AI agent built
in, that also happens to be hardened," not "yet another Firefox fork,"
which is a crowded, already well-served space on its own.
