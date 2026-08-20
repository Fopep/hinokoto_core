import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

final ValueNotifier<bool> adPrivacyOptionsRequired = ValueNotifier(false);

bool get _isSupported => Platform.isAndroid || Platform.isIOS;

Future<void> updateAdPrivacyOptionsRequired() async {
  if (!_isSupported) return;
  if (kDebugMode) {
    // デバッグビルドでは実際の地域に関わらずメニュー項目を確認できるようにする。
    adPrivacyOptionsRequired.value = true;
    return;
  }
  final status = await ConsentInformation.instance
      .getPrivacyOptionsRequirementStatus();
  adPrivacyOptionsRequired.value =
      status == PrivacyOptionsRequirementStatus.required;
}

Future<void> showAdPrivacyOptions() async {
  if (!_isSupported) return;
  final completer = Completer<FormError?>();
  ConsentForm.showPrivacyOptionsForm((formError) {
    if (formError != null) {
      debugPrint('[AdMob] Privacy options error: ${formError.message}');
    }
    completer.complete(formError);
  });
  await completer.future;
  await updateAdPrivacyOptionsRequired();
}
