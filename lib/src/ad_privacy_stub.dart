import 'package:flutter/foundation.dart';

// ウェブはgoogle_mobile_ads未対応でUMPが動かないため、デバッグビルドでは
// メニュー項目の見た目だけ確認できるようにする(タップしても何も起きない)。
final ValueNotifier<bool> adPrivacyOptionsRequired = ValueNotifier(kDebugMode);

Future<void> showAdPrivacyOptions() async {}
