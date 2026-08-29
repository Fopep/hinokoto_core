# hinokoto_core

Shared Flutter foundation for Hinokoto Studio apps: ad banners/consent, platform setup, common UI
chrome, and a few small generic utilities (review prompts, external URL launching).

This package intentionally contains **no app-specific logic** — no domain models, no screens, no
branding. It exists to be depended on by multiple separate Hinokoto Studio apps (e.g.
`regionaldata_app`, `countrydata_app`) without pulling in any of their domain code.

## Usage

Add as a `git` dependency, pinned to a tag:

```yaml
dependencies:
  hinokoto_core:
    git:
      url: https://github.com/Fopep/hinokoto_core.git
      ref: v0.8.1
```

Then import the single barrel file — do not import files under `lib/src/` directly:

```dart
import 'package:hinokoto_core/hinokoto_core.dart';
```

Everything in this package is generic and takes the app-specific values it needs (asset paths, ad
unit IDs, l10n strings) as constructor arguments or function parameters — it never hardcodes a real
app's identity. See the consuming app's own `AppConfig` (e.g. `lib/src/app_config.dart` in
`app_template`) for where those values should live on the app side.

## What's here

- `ad_banner*.dart`, `ad_privacy*.dart`, `ad_layout.dart` — AdMob banner + UMP consent flow.
  `AdBannerSlot` falls back to Google's public test ad unit IDs whenever the caller doesn't supply
  real ones, in both debug and release builds. `hideAdWidget` keeps the reserved space but skips
  rendering the ad's `PlatformView` — useful for hiding a native ad behind an open dialog on iOS.
  On web, `AdBannerSlot` renders nothing and reserves no space at all — a real ad on web is a
  `position:fixed` div layered on by `index.html` independently of the Flutter canvas, so reserving
  height here too would just add extra blank space below it.
  `ad_privacy.dart` exposes `adPrivacyOptionsRequired` (a `ValueNotifier<bool>`) and
  `showAdPrivacyOptions()` for a "privacy settings" menu entry.
- `platform_setup_io.dart` / `platform_setup_stub.dart` — `setupPlatformDatabase()`, a
  `sqflite_common_ffi` init for Linux/Windows (conditionally a no-op elsewhere).
- `app_bar_layout.dart` — `HinokotoAppBar` (a `PreferredSizeWidget` app bar pairing a logo with a
  menu action) and `AppBackButton`, content-width-aware back button placement.
- `app_dialog.dart` — `AppDialog` / `showAppDialog`, a generic dialog shell with the shared
  open/close blur-and-scale animation. `showAppDialog` also takes `onOpen`/`onClose` callbacks (e.g.
  to hide a native ad overlay while a dialog is up) and an optional `bottomReservedSpace` /
  `bottomReservedSpaceListenable` pair so the dialog can pad itself clear of bottom-anchored chrome
  (like an ad banner) — including chrome whose height changes while the dialog is already open.
- `app_bottom_sheet.dart` — `showAppModalBottomSheet`, a blurred-barrier modal bottom sheet to match
  `showAppDialog`'s look.
- `pinned_close_menu.dart` — `MenuWithPinnedClose`, a popup-menu-style panel whose header and close
  button stay pinned while its items scroll.
- `dialog_button.dart` — `DialogButton` / `DialogButtonType` (`normal`, `inverse`, `destructive`,
  `outlined`) and `buildDialogButtonStyle`, the shared button styling for dialog actions.
- `selector_row.dart` — `SelectorRow<T>` / `SelectorOption<T>`, a horizontal single-choice selector.
- `switch_row.dart` — `SwitchRow`, a labeled on/off row matching the shared dialog styling.
- `horizontal_scroll_row.dart` — `HorizontalScrollRow`, a row that scrolls horizontally instead of
  wrapping when it overflows, with edge fade affordances.
- `app_theme.dart` — `buildAppTheme(Brightness, {seedColor, colorScheme, primaryColor, ...})`.
  The default uses the purpose-built `buildHinokotoColorScheme`: a deeper accessible blue in light
  mode, a confident non-pastel brand blue in dark mode, and restrained cool-neutral surfaces. Pass
  another `seedColor` for Material's generated palette, a complete `colorScheme` for full control,
  or individual role overrides for a small exception. A role override automatically gets a
  high-contrast black/white foreground unless its matching `on*Color` is supplied explicitly.
  `AppPalette` remains available for charts and categorical accents.
- `svg_logo.dart` — `SvgLogo`, a parameterized SVG logo widget.
- `app_review.dart` — `supportsInAppReview`, `requestAppReview()`, `showRateMenuItem()`,
  `isAndroidPlatform`, `isIosPlatform`.
- `external_url.dart` — `openUrlWithFallbackSnackbar`.
- `review_prompt.dart` — `recordAppLaunch()`, launch-count-based review-prompt milestones.
- `web_ads_codegen.dart` (not exported from `hinokoto_core.dart` — a build-time tool API, not a
  runtime widget API) + `bin/apply_web_ads.dart` — shared codegen for the AdSense `<div
  id="adsense-bottom-banner">` block in a consuming app's `web/index.html`. Run `dart run
  hinokoto_core:apply_web_ads` (optionally `--check`) from the app's repo root; it reads
  `web.adsense_client`/`adsense_slot`/`adsense_enabled` from that app's own `app_settings.yaml` and
  regenerates the region between `<!-- ADSENSE:BEGIN -->`/`<!-- ADSENSE:END -->` markers in
  `web/index.html`. See "Usage" above for why AdSense itself isn't a widget in this package.

## Versioning

Tag a new version for any change consuming apps should be able to pick up; apps pin `ref:` to a
specific tag rather than tracking `main`, so bumping is an explicit, per-app decision.

- `v0.1.0` — initial extraction from `app_template`.
- `v0.2.0` — `buildAppTheme`'s colors (seed/primary/onPrimary/secondary/tertiary/error) are now
  optional constructor-style parameters instead of hardcoded `AppPalette` values, so apps can use a
  different brand palette without forking the theme builder. Defaults are unchanged, so this is a
  backward-compatible addition.
- `v0.2.1`–`v0.2.3` — incremental fixes to the pieces above.
- `v0.5.0` (`v0.3.0`/`v0.4.0` were pubspec-only bumps, not separately tagged) — added
  `DialogButton`, `SelectorRow`, `SwitchRow`, `showAppModalBottomSheet`, `MenuWithPinnedClose`,
  `HinokotoAppBar`, and `HorizontalScrollRow`; extended `AdBannerSlot` with `hideAdWidget` and
  `showAppDialog` with `onOpen`/`onClose`/`bottomReservedSpace` for apps consolidating their own
  ad-aware dialog/banner code onto this package.
- `v0.5.1` — direct tests for `HorizontalScrollRow`, `SelectorRow`, `showAppModalBottomSheet`, and
  the web `AdBannerSlot` stub; tightened the `google_mobile_ads` constraint to `^9.1.0` (`ageRestrictedTreatment`,
  used since v0.5.0, doesn't exist before 9.1.0 — `^9.0.0` could silently resolve to a version that
  fails to compile).
- `v0.5.2` — the web `AdBannerSlot` stub now renders nothing and reserves no space, instead of
  reserving `adBannerReservedHeight`; a real ad on web is laid on top by `index.html` as a
  `position:fixed` div independent of the Flutter canvas, so reserving height in Flutter as well
  just added extra blank space beneath it.
- `v0.5.3` — `MenuWithPinnedClose`'s border/divider colors switched from `outlineVariant` to
  `outline` (with higher alpha) so the panel's edges and header divider read more clearly against
  the background; added this package's own `analyze`/`test`/`dependency_validator` CI workflow.
- `v0.6.0` — added `bin/apply_web_ads.dart` / `lib/web_ads_codegen.dart`, a shared AdSense
  `web/index.html` codegen tool apps can invoke via `dart run hinokoto_core:apply_web_ads`,
  extracted from `app_template`'s local `tool/apply_settings.dart` so every app generates
  byte-identical AdSense markup from its own `app_settings.yaml`.
- `v0.7.0` — added shared app-bar shadow wrappers for regular and sliver app bars.
- `v0.8.0` — rebuilt the shared theme around Material 3's brightness-aware tonal roles, added full
  `ColorScheme` and matching `on*` overrides, derived surfaces/borders/control colors from the
  scheme, and made `SelectorRow` use an accessible theme-aware Material button instead of fixed
  black/white/blue-grey colors.
- `v0.8.1` — replaced the overly pastel generated defaults with a purpose-built Hinokoto light/dark
  scheme, restored strong brand-blue primary actions, and made selected switches use a clear blue
  track with a white thumb in both brightness modes.
- `v0.8.2` — gave `HinokotoPinnedHeader` a subtle brand-tinted background and high-contrast
  foreground in both brightness modes, with optional per-instance color overrides.

## Development

```sh
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm dart run dependency_validator
```

This package must not depend on any specific app's domain concepts. If a change requires knowing
about a specific app's data model, screens, or branding, it belongs in that app's own repo instead.
