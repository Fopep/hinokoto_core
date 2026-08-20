import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  test('評価メニューはデバッグ時またはスマホで表示する', () {
    expect(showRateMenuItem(isDebug: true, isMobile: false), isTrue);
    expect(showRateMenuItem(isDebug: false, isMobile: true), isTrue);
    expect(showRateMenuItem(isDebug: false, isMobile: false), isFalse);
  });
}
