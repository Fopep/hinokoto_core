import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('レビュー依頼は起動20回目と100回目だけを対象にする', () async {
    SharedPreferences.setMockInitialValues({});

    for (var launch = 1; launch <= 100; launch++) {
      expect(
        await recordAppLaunch(),
        defaultReviewPromptLaunchCounts.contains(launch),
        reason: '$launch回目の起動',
      );
    }
  });
}
