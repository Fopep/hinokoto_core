/// Shared codegen for the AdSense `<div id="adsense-bottom-banner">` block in
/// a consuming app's `web/index.html`. Not exported from `hinokoto_core.dart`
/// — this is a build-time tool API (used by `bin/apply_web_ads.dart` and by
/// `app_template`'s `tool/apply_settings.dart`), not a runtime widget API.
///
/// AdSense on web is deliberately kept outside the Flutter widget tree (see
/// `ad_banner_stub.dart`'s doc comment): a real ad is a `position:fixed` div
/// layered on by `index.html` independently of the Flutter canvas. This file
/// only edits the marker-delimited region between `<!-- ADSENSE:BEGIN -->`
/// and `<!-- ADSENSE:END -->`; everything else in `index.html` (including the
/// `#adsense-bottom-banner` CSS in `<head>`) is untouched.
library;

/// An app's AdSense identity, as declared in its `app_settings.yaml`'s `web`
/// section (`adsense_client`, `adsense_slot`, `adsense_enabled`).
class AdsenseConfig {
  const AdsenseConfig({
    required this.client,
    required this.slot,
    required this.enabled,
  });

  /// e.g. `ca-pub-1234567890123456`.
  final String client;

  /// Digits only, e.g. `6420852311`.
  final String slot;

  /// Whether to emit the live `<ins class="adsbygoogle">` snippet or a
  /// disabled placeholder comment.
  final bool enabled;
}

final RegExp _adsenseClientPattern = RegExp(r'^ca-pub-\d+$');
final RegExp _adsenseSlotPattern = RegExp(r'^\d+$');

/// Throws [FormatException] if [config]'s `client`/`slot` don't match the
/// shape AdSense expects.
void validateAdsenseConfig(AdsenseConfig config) {
  if (!_adsenseClientPattern.hasMatch(config.client)) {
    throw FormatException(
      'web.adsense_client must look like ca-pub-1234567890, got: ${config.client}',
    );
  }
  if (!_adsenseSlotPattern.hasMatch(config.slot)) {
    throw FormatException(
      'web.adsense_slot must contain digits only, got: ${config.slot}',
    );
  }
}

final RegExp _adsenseBlockPattern = RegExp(
  r'(<!-- ADSENSE:BEGIN -->)[\s\S]*?(<!-- ADSENSE:END -->)',
);

/// Regenerates the `<!-- ADSENSE:BEGIN --> ... <!-- ADSENSE:END -->` region
/// of [indexHtml] from [config], wholesale (not patched in place), so the
/// result is correct regardless of whether the region currently holds the
/// live snippet or the disabled placeholder.
///
/// Throws [FormatException] if the marker pair isn't present in [indexHtml],
/// or if [config] fails [validateAdsenseConfig].
String applyAdsenseBlock({
  required String indexHtml,
  required AdsenseConfig config,
}) {
  validateAdsenseConfig(config);

  if (!_adsenseBlockPattern.hasMatch(indexHtml)) {
    throw const FormatException(
      'web/index.html: expected marker pair not found: '
      '<!-- ADSENSE:BEGIN --> ... <!-- ADSENSE:END -->',
    );
  }

  final inner = config.enabled
      ? '''
    <script async="" src="https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=${config.client}" crossorigin="anonymous"></script>
    <ins class="adsbygoogle" style="display:inline-block;width:320px;height:100px" data-ad-client="${config.client}" data-ad-slot="${config.slot}"></ins>
    <script>
      (adsbygoogle = window.adsbygoogle || []).push({});
    </script>
  '''
      : '''
    <!-- AdSense disabled — set web.adsense_enabled: true in app_settings.yaml once you have a real client/slot, then rerun `make settings`. -->
  ''';

  return indexHtml.replaceFirstMapped(
    _adsenseBlockPattern,
    (match) => '${match[1]}\n$inner${match[2]}',
  );
}
