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

  test('defaults to AppPalette colors', () {
    final scheme = buildAppTheme(Brightness.light).colorScheme;
    expect(scheme.primary, AppPalette.blue);
    expect(scheme.secondary, AppPalette.purple);
    expect(scheme.tertiary, AppPalette.orange);
    expect(scheme.error, AppPalette.red);
  });

  for (final brightness in Brightness.values) {
    test(
      'switch thumb is white only when on, default otherwise in ${brightness.name}',
      () {
        final thumbColor = buildAppTheme(brightness).switchTheme.thumbColor!;
        expect(thumbColor.resolve({WidgetState.selected}), Colors.white);
        expect(thumbColor.resolve({}), isNull);
        expect(thumbColor.resolve({WidgetState.disabled}), isNull);
      },
    );
  }

  test(
    'elevated/filled/outlined/text buttons use primary/onPrimary colors',
    () {
      final theme = buildAppTheme(Brightness.light);
      final scheme = theme.colorScheme;

      Color? resolve(WidgetStateProperty<Color?>? property) =>
          property?.resolve({});

      expect(
        resolve(theme.elevatedButtonTheme.style?.backgroundColor),
        scheme.primary,
      );
      expect(
        resolve(theme.elevatedButtonTheme.style?.foregroundColor),
        scheme.onPrimary,
      );
      expect(
        resolve(theme.outlinedButtonTheme.style?.foregroundColor),
        scheme.primary,
      );
      expect(
        resolve(theme.textButtonTheme.style?.foregroundColor),
        scheme.primary,
      );
    },
  );

  test('button label style comes from the passed-in textTheme', () {
    const customTextTheme = TextTheme(
      labelLarge: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
    );
    final theme = buildAppTheme(Brightness.light, textTheme: customTextTheme);

    final labelStyle = theme.elevatedButtonTheme.style?.textStyle?.resolve({});

    expect(labelStyle?.fontSize, 22);
    expect(labelStyle?.fontStyle, FontStyle.italic);
    expect(labelStyle?.fontWeight, FontWeight.w700);
  });

  test('every color is overridable so apps are not stuck with AppPalette', () {
    const seed = Color(0xFF00AA00);
    const secondary = Color(0xFF00BB00);
    const tertiary = Color(0xFF00CC00);
    const error = Color(0xFF00DD00);
    final scheme = buildAppTheme(
      Brightness.light,
      seedColor: seed,
      secondaryColor: secondary,
      tertiaryColor: tertiary,
      errorColor: error,
    ).colorScheme;

    expect(scheme.primary, seed);
    expect(scheme.secondary, secondary);
    expect(scheme.tertiary, tertiary);
    expect(scheme.error, error);
  });
}
