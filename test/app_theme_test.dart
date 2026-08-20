import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  for (final brightness in Brightness.values) {
    test('input controls have visible state borders in ${brightness.name}', () {
      final theme = buildAppTheme(brightness).inputDecorationTheme;
      final enabledBorder = theme.enabledBorder! as OutlineInputBorder;
      final focusedBorder = theme.focusedBorder! as OutlineInputBorder;
      final errorBorder = theme.errorBorder! as OutlineInputBorder;
      final disabledBorder = theme.disabledBorder! as OutlineInputBorder;

      expect(enabledBorder.borderSide.style, BorderStyle.solid);
      expect(enabledBorder.borderSide.color, isNot(Colors.transparent));
      expect(focusedBorder.borderSide.width, 2);
      expect(errorBorder.borderSide.width, 1.5);
      expect(disabledBorder.borderSide.style, BorderStyle.solid);
    });
  }
}
