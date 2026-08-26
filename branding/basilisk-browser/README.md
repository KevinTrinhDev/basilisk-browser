# Branding directory (required before mozconfig can build)

Firefox's build system requires a populated `browser/branding/<name>/`
directory (icons at every size, `locales/en-US/brand.dtd`,
`locales/en-US/brand.properties`, `content/`, `VisualElements/` on Windows)
before `--with-branding` will produce a working build. Mozilla's own
official Firefox logo/wordmark are trademarked and **cannot** be used in a
non-Mozilla-distributed build — this is exactly why LibreWolf, Mullvad
Browser, and every other Firefox fork ship their own artwork here instead
of Firefox's.

## What needs to go here (not done yet — needs real design work, not code)

```
branding/basilisk-browser/
  configure.sh                    # sets MOZ_APP_DISPLAYNAME etc.
  content/
    about-logo.png / @2x.png      # about: page logo
    icon16.png ... icon128.png    # app icons, multiple sizes
    firefox.icns (macOS), .ico (Windows), various .png (Linux/desktop)
  locales/en-US/
    brand.dtd                     # brandShortName/brandFullName entities
    brand.properties               # same, properties format
  VisualElements/                 # Windows tile assets
  background.png / background.svg # first-run assets
```

## Recommended path

1. Design the actual BASILISK Browser mark (the extension's existing
   `sidebar-extension/icons/` set is a starting point/reference, but a
   desktop app icon set needs more sizes and a few Windows/macOS-specific
   formats).
2. Copy Firefox's own `browser/branding/unofficial/` directory (this one
   *is* free to use/modify — it's Mozilla's explicitly-provided placeholder
   for exactly this purpose) as the structural template, then swap in
   BASILISK artwork and strings.
3. Fill in `configure.sh` with `MOZ_APP_DISPLAYNAME=BASILISK Browser` and
   related vars (see any existing Firefox fork's `configure.sh` for the
   exact variable list — LibreWolf's is a good, current reference).

This is genuinely a design task, not an engineering one — nothing here
should be auto-generated placeholder art shipped as if it were final.
