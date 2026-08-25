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
      ref: v0.5.1
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
- `app_theme.dart` — `buildAppTheme(Brightness, {seedColor, primaryColor, onPrimaryColor,
  secondaryColor, tertiaryColor, errorColor})`. Every color defaults to `AppPalette`'s values but is
  overridable — apps are not stuck with the same brand colors just because they share this theme
  builder. `AppPalette` itself (color constants) is still here as the shared default palette.
- `svg_logo.dart` — `SvgLogo`, a parameterized SVG logo widget.
- `app_review.dart` — `supportsInAppReview`, `requestAppReview()`, `showRateMenuItem()`,
  `isAndroidPlatform`, `isIosPlatform`.
- `external_url.dart` — `openUrlWithFallbackSnackbar`.
- `review_prompt.dart` — `recordAppLaunch()`, launch-count-based review-prompt milestones.

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

## Development

```sh
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm dart run dependency_validator
```

This package must not depend on any specific app's domain concepts. If a change requires knowing
about a specific app's data model, screens, or branding, it belongs in that app's own repo instead.
