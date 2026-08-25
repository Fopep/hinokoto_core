import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/src/ad_banner_stub.dart';
import 'package:hinokoto_core/src/ad_layout.dart';

// `AdBannerSlot`'s conditional export picks this stub only on web (no
// dart:io); `flutter test` runs on the Dart VM, where dart:io is always
// available, so the widget under test is imported directly here to reach
// the web behavior at all.
void main() {
  Future<void> pump(WidgetTester tester, {bool hideAdWidget = false}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdBannerSlot(
            androidBannerId: 'android-id',
            iosBannerId: 'ios-id',
            hideAdWidget: hideAdWidget,
          ),
        ),
      ),
    );
  }

  testWidgets('広告非対応(web)では常に予約高さ分のSizedBoxだけを描く', (tester) async {
    await pump(tester);

    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.height, adBannerReservedHeight);
    expect(box.width, double.infinity);
  });

  testWidgets('hideAdWidgetを渡してもwebでは高さの確保だけで変わらない', (tester) async {
    await pump(tester, hideAdWidget: true);

    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.height, adBannerReservedHeight);
  });
}
