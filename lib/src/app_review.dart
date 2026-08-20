import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';

bool get isAndroidPlatform =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
bool get isIosPlatform =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
bool get supportsInAppReview => isAndroidPlatform || isIosPlatform;

bool showRateMenuItem({bool isDebug = kDebugMode, bool? isMobile}) =>
    isDebug || (isMobile ?? (isAndroidPlatform || isIosPlatform));

Future<void> requestAppReview() async {
  if (!supportsInAppReview) return;
  try {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  } catch (error) {
    debugPrint('[Review] Failed to request a review: $error');
  }
}
