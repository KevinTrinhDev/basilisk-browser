// BASILISK Browser additional hardening — copy into your Firefox profile
// directory as user.js (find it via about:support -> "Profile Folder").
// policy/policies.json (installed system-wide) already covers telemetry,
// tracking protection, DoH, and fingerprint resistance; this file adds
// prefs that aren't exposed through the enterprise policy schema. Modeled
// on the same category of hardening as arkenfox/user.js and LibreWolf's
// defaults, trimmed to what doesn't break normal browsing.

// --- Fingerprinting / telemetry (belt-and-suspenders with policies.json) ---
user_pref("privacy.resistFingerprinting", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.fingerprinting.enabled", true);
user_pref("privacy.trackingprotection.cryptomining.enabled", true);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.coverage.opt-out", true);
user_pref("browser.discovery.enabled", false);
user_pref("browser.tabs.crashReporting.sendReport", false);
user_pref("breakpad.reportURL", "");
user_pref("captivedetect.canonicalURL", ""); // no captive-portal detection ping

// --- Referrer / cross-site leakage ---
user_pref("network.http.referer.XOriginTrimmingPolicy", 2); // send only scheme+host+port cross-origin
user_pref("network.http.referer.XOriginPolicy", 2); // only send referrer to same eTLD+1

// --- Disable prefetching (leaks intent to third parties) ---
user_pref("network.dns.disablePrefetch", true);
user_pref("network.predictor.enabled", false);
user_pref("network.prefetch-next", false);
user_pref("browser.urlbar.speculativeConnect.enabled", false);

// --- WebRTC IP leak protection (relevant when using a VPN — see BASILISK's
// vpn-status kill switch, this closes the classic "VPN is up but WebRTC
// leaks your real IP anyway" hole) ---
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("media.peerconnection.ice.no_host", true);

// --- No Pocket, no sponsored content, no "recommendations" ---
user_pref("extensions.pocket.enabled", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);

// --- Password manager off (BASILISK uses the Bitwarden vault bridge
// instead — see agent-daemon/src/vault-bridge.ts in the basilisk repo —
// so Firefox's own store is intentionally unused to avoid two credential
// stores drifting out of sync) ---
user_pref("signon.rememberSignons", false);
user_pref("signon.autofillForms", false);

// --- HTTPS-only mode ---
user_pref("dom.security.https_only_mode", true);
