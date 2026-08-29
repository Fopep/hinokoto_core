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

  for (final brightness in Brightness.values) {
    test('defaults to the Hinokoto brand palette in ${brightness.name}', () {
      final scheme = buildAppTheme(brightness).colorScheme;
      final expected = buildHinokotoColorScheme(brightness);

      expect(scheme, expected);
      for (final pair in [
        (scheme.primary, scheme.onPrimary),
        (scheme.primaryContainer, scheme.onPrimaryContainer),
        (scheme.secondary, scheme.onSecondary),
        (scheme.tertiary, scheme.onTertiary),
        (scheme.error, scheme.onError),
        (scheme.surface, scheme.onSurface),
        (scheme.surfaceContainerHighest, scheme.onSurfaceVariant),
      ]) {
        expect(_contrastRatio(pair.$1, pair.$2), greaterThan(4.5));
      }
    });
  }

  test('uses strong brand blues for primary actions', () {
    final light = buildHinokotoColorScheme(Brightness.light);
    final dark = buildHinokotoColorScheme(Brightness.dark);

    expect(light.primary, const Color(0xFF086FA8));
    expect(light.onPrimary, Colors.white);
    expect(dark.primary, AppPalette.blue);
    expect(dark.onPrimary, const Color(0xFF00243A));
  });

  for (final brightness in Brightness.values) {
    test('switch uses a strong blue track in ${brightness.name}', () {
      final theme = buildAppTheme(brightness);
      final thumbColor = theme.switchTheme.thumbColor!;
      final trackColor = theme.switchTheme.trackColor!;
      expect(thumbColor.resolve({WidgetState.selected}), Colors.white);
      expect(
        trackColor.resolve({WidgetState.selected}),
        theme.colorScheme.primary,
      );
      expect(thumbColor.resolve({}), isNull);
      expect(thumbColor.resolve({WidgetState.disabled}), isNull);
      expect(
        trackColor.resolve({WidgetState.selected, WidgetState.disabled}),
        isNull,
      );
    });
  }

  test('a non-Hinokoto seed still uses Material color generation', () {
    const seed = Color(0xFF008577);
    final scheme = buildAppTheme(Brightness.light, seedColor: seed).colorScheme;

    expect(
      scheme,
      ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
    );
  });

  for (final brightness in Brightness.values) {
    test('buttons use strong semantic colors in ${brightness.name}', () {
      final theme = buildAppTheme(brightness);
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
        resolve(theme.filledButtonTheme.style?.backgroundColor),
        scheme.primary,
      );
      expect(
        resolve(theme.filledButtonTheme.style?.foregroundColor),
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
    });
  }

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

  test('role overrides automatically receive a contrasting foreground', () {
    const seed = Color(0xFF00AA00);
    const primary = Color(0xFFFFD54F);
    const secondary = Color(0xFF152238);
    const tertiary = Color(0xFFB8F2E6);
    const error = Color(0xFF8B1E2D);
    final scheme = buildAppTheme(
      Brightness.light,
      seedColor: seed,
      primaryColor: primary,
      secondaryColor: secondary,
      tertiaryColor: tertiary,
      errorColor: error,
    ).colorScheme;

    expect(scheme.primary, primary);
    expect(scheme.onPrimary, Colors.black);
    expect(scheme.secondary, secondary);
    expect(scheme.onSecondary, Colors.white);
    expect(scheme.tertiary, tertiary);
    expect(scheme.onTertiary, Colors.black);
    expect(scheme.error, error);
    expect(scheme.onError, Colors.white);
  });

  test('a complete custom ColorScheme drives surfaces and controls', () {
    final customScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.green,
      brightness: Brightness.dark,
    );
    final theme = buildAppTheme(Brightness.dark, colorScheme: customScheme);

    expect(theme.colorScheme, customScheme);
    expect(theme.scaffoldBackgroundColor, customScheme.surface);
    expect(theme.cardTheme.color, customScheme.surfaceContainerLow);
    expect(
      theme.dialogTheme.backgroundColor,
      customScheme.surfaceContainerHigh,
    );
    expect(
      theme.navigationBarTheme.indicatorColor,
      customScheme.primaryContainer,
    );
  });

  test('rejects a ColorScheme with a mismatched brightness', () {
    final darkScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.blue,
      brightness: Brightness.dark,
    );

    expect(
      () => buildAppTheme(Brightness.light, colorScheme: darkScheme),
      throwsArgumentError,
    );
  });
}

double _contrastRatio(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + .05) / (darker + .05);
}
