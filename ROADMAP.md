# Roadmap: performance, efficiency, decentralization, differentiators

This is the honest plan for "make it faster / more efficient / less
storage / decentralized / genius features" — split into what's done, what's
concretely plannable now, and what's genuinely open-ended R&D so it doesn't
get promised as if it were scheduled work.

## Performance & storage — done

- Extension bundles now built with esbuild `minify: true` (basilisk repo).
  Real, measured effect: background bundle 14.1kb → 8.4kb (~40% smaller),
  sidebar UI 10.2kb → 6.3kb (~38%), several content scripts nearly halved.
  Free win, zero behavior change, verified via build output + typecheck.

## Performance & storage — planned for the tier-2 build (mozconfig)

These are standard, well-understood Firefox build flags — real, not
speculative — to add once a real build environment exists (see
`README.md`'s tier 2 section for why that's not today):

- **PGO (Profile-Guided Optimization) + LTO (Link-Time Optimization)** —
  `ac_add_options --enable-lto=cross` and a PGO training pass. This is what
  makes official Firefox release builds meaningfully faster than a plain
  `--enable-release` build; skipping it is the single biggest performance
  gap between "compiles" and "actually fast."
- **Single-locale build** (English only, or your target locales) instead of
  the ~100-locale official build — meaningfully smaller installer/binary
  for close to zero effort (`--enable-single-locale`).
- **Strip unused feature surface** you don't need for this browser's
  purpose — evaluate case by case (e.g. VR/WebXR support) rather than
  blanket-disabling; some "unused" features (accessibility APIs
  especially) should stay regardless of binary size.
- **jemalloc** (Firefox's default allocator) — confirm it's on; it already
  measurably beats glibc malloc for this workload, just verify the mozconfig
  doesn't accidentally disable it.

None of this is exotic — it's the same list every serious Firefox fork's
build docs cover. The reason it's "planned" not "done" is purely that it
needs a real build to verify against, not because it's uncertain.

## Decentralization & privacy — reframing what's actually true

"Decentralized browser" isn't a coherent claim on its own — a browser talks
to whatever servers a website's owner controls; that's inherent to HTTP,
not something a browser vendor can decentralize away. What *is* real and
already substantially built (in the `basilisk` repo) is **removing
required third parties**:

| Thing | Default elsewhere | Here |
|---|---|---|
| AI backend | OpenAI/Anthropic cloud | Your own key, your own OpenRouter/local model, your choice |
| Password vault | Browser vendor's cloud sync | Bitwarden, self-hostable as Vaultwarden |
| VPN | Trust a VPN vendor blindly | Status/kill-switch on your own WireGuard config |
| Remote access | A vendor's relay server | Your own Tailscale/WireGuard mesh |
| Automation/agent access | N/A (doesn't exist elsewhere) | Your own daemon, your own token, nobody else's cloud |

That's the honest version of "decentralized": no single vendor is a
mandatory dependency for any of it. Two more pieces worth adding to that
list, concretely plannable:

- **Self-hosted DNS-over-HTTPS resolver option** — `policy/policies.json`
  currently points DoH at Cloudflare by default (a reasonable default, not
  a lock-in); document swapping in a self-run resolver (NextDNS, or your
  own `dnscrypt-proxy`) as a one-line config change.
- **Self-hosted sync** — Mozilla's sync server (`syncserver`) is open
  source and self-hostable; document pointing BASILISK Browser's sync
  prefs at your own instance instead of Mozilla's, for bookmarks/history
  without a vendor in the loop. Real, bounded, not yet written up.

## What actually sets this apart (the genuine differentiators)

Being honest about the landscape: LibreWolf/Mullvad Browser/Brave compete
on *hardening a browser*. None of them have an AI agent layer at all — that
gap is BASILISK's actual moat, not the browser wrapper around it:

- **Visible, confirmed AI page interaction** — no other browser has this.
- **Multi-client, safety-gated automation** (the CLI, just shipped) — any
  agent can drive it through the exact same allowlist/kill-switch/download
  caps as the human UI. Nobody else exposes this at all, let alone safely.
- **Vault autofill that's *more* paranoid than mainstream password
  managers**, not less: two separate explicit confirms (sidebar click +
  on-page click), AI categorically excluded from the path, value never
  logged or displayed in the fill flow. Most browser-integrated password
  managers auto-fill silently on page load; this deliberately doesn't.
- **AI-action-level kill switch** — most VPN kill switches block network
  traffic; this additionally refuses to let the *agent* act at all when
  the tunnel drops, a layer other setups don't have because they don't
  have an agent to gate in the first place.

The realistic "genius feature" isn't a browser trick — it's that the AI
layer already does things no browser (hardened or not) does, and the
browser-hardening work makes the environment it runs in match that same
bar. Positioning-wise, "the browser with a safety-gated AI agent built in,
that also happens to be hardened" is the actual pitch — not "yet another
Firefox fork," which is a crowded, already-well-served space on its own.
