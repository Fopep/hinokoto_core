import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/src/ad_banner_stub.dart';

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

  // On web, the real ad is rendered by a position:fixed div in index.html
  // that overlays the viewport bottom independently of the Flutter canvas;
  // reserving height here as well would just add extra blank space below
  // it, so this stub renders nothing and takes up no space.
  testWidgets('広告非対応(web)では高さ0のまま何も描かない', (tester) async {
    await pump(tester);

    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.height, 0);
    expect(box.width, 0);
  });

  testWidgets('hideAdWidgetを渡してもwebでは高さ0のまま変わらない', (tester) async {
    await pump(tester, hideAdWidget: true);

    final box = tester.widget<SizedBox>(find.byType(SizedBox));
    expect(box.height, 0);
    expect(box.width, 0);
  });
}
