import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_layout.dart';
import 'ad_privacy_mobile.dart';

/// Google's shared public test ad unit IDs — see
/// https://developers.google.com/admob/flutter/test-ads. Used whenever the
/// caller doesn't supply a real banner ID, so a misconfigured app serves test
/// ads instead of another app's production ads.
const _androidTestBannerId = 'ca-app-pub-3940256099942544/6300978111';
const _iosTestBannerId = 'ca-app-pub-3940256099942544/2934735716';
const _hideAds = bool.fromEnvironment('HIDE_ADS_FOR_SCREENSHOTS');

class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({
    super.key,
    this.androidBannerId,
    this.iosBannerId,
    this.hideAdWidget = false,
  });

  /// Real AdMob banner unit IDs for this app. Leave null/empty to serve
  /// Google's test ads.
  final String? androidBannerId;
  final String? iosBannerId;

  /// While true, the reserved space is kept but the ad (PlatformView) itself
  /// isn't rendered. Use this to hide the ad behind a dialog on iOS, where
  /// the PlatformView would otherwise float above dialog content.
  final bool hideAdWidget;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  BannerAd? _bannerAd;
  bool _isLoading = false;

  bool get _isSupported => Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    super.initState();
    if (_isSupported && !_hideAds) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initializeAds());
    }
  }

  Future<void> _initializeAds() async {
    final parameters = ConsentRequestParameters(tagForUnderAgeOfConsent: false);
    ConsentInformation.instance.requestConsentInfoUpdate(
      parameters,
      () async {
        await updateAdPrivacyOptionsRequired();
        ConsentForm.loadAndShowConsentFormIfRequired((error) async {
          if (error != null) {
            debugPrint('[AdMob] Consent form error: ${error.message}');
          }
          await updateAdPrivacyOptionsRequired();
          await _requestAdIfAllowed();
        });
      },
      (error) async {
        debugPrint('[AdMob] Consent update error: ${error.message}');
        await updateAdPrivacyOptionsRequired();
        await _requestAdIfAllowed();
      },
    );
  }

  Future<void> _requestAdIfAllowed() async {
    if (!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(
        maxAdContentRating: MaxAdContentRating.g,
        ageRestrictedTreatment: AgeRestrictedTreatment.unspecified,
      ),
    );
    await MobileAds.instance.initialize();
    _loadBanner();
  }

  void _loadBanner() {
    if (!mounted || _isLoading || _bannerAd != null) return;
    _isLoading = true;
    final configuredAndroidId = widget.androidBannerId;
    final configuredIosId = widget.iosBannerId;
    final androidBannerId =
        (configuredAndroidId != null && configuredAndroidId.isNotEmpty)
        ? configuredAndroidId
        : _androidTestBannerId;
    final iosBannerId = (configuredIosId != null && configuredIosId.isNotEmpty)
        ? configuredIosId
        : _iosTestBannerId;
    final ad = BannerAd(
      adUnitId: Platform.isAndroid ? androidBannerId : iosBannerId,
      size: AdSize.largeBanner,
      // Never request tracking-based (personalized) ads — this app doesn't
      // show the ATT prompt, so always ask for non-personalized ads
      // explicitly rather than relying on IDFA/consent-signal defaults.
      request: const AdRequest(nonPersonalizedAds: true),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isLoading = false;
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _bannerAd = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          _isLoading = false;
          ad.dispose();
          debugPrint('[AdMob] Banner failed to load: $error');
        },
      ),
    );
    ad.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSupported) return const SizedBox.shrink();
    if (_hideAds) return const SizedBox(height: adBannerReservedHeight);
    final ad = _bannerAd;
    return SafeArea(
      top: false,
      child: SizedBox(
        width: double.infinity,
        height: adBannerReservedHeight,
        child: (ad == null || widget.hideAdWidget)
            ? null
            : Center(
                child: SizedBox(
                  width: ad.size.width.toDouble(),
                  height: ad.size.height.toDouble(),
                  child: AdWidget(ad: ad),
                ),
              ),
      ),
    );
  }
}
