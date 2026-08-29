import 'package:flutter/material.dart';

abstract final class AppPalette {
  static const slate = Color(0xFF64748B);
  static const blue = Color(0xFF3399DD);
  static const green = Color(0xFF66AA44);
  static const orange = Color(0xFFEE9900);
  static const purple = Color(0xFF9966CC);
  static const red = Color(0xFFFF7777);

  static const colors = [slate, blue, green, orange, purple];
}

/// Builds a Material 3 [ThemeData] from a coherent tonal palette.
///
/// [seedColor] identifies the brand, while Material derives brightness-aware
/// role colors (including matching `on*` foregrounds) from it. Individual
/// role overrides remain available, and [colorScheme] lets an app supply a
/// complete scheme without forking the shared component themes.
ThemeData buildAppTheme(
  Brightness brightness, {
  Color seedColor = AppPalette.blue,
  Color? primaryColor,
  Color? onPrimaryColor,
  Color? secondaryColor,
  Color? onSecondaryColor,
  Color? tertiaryColor,
  Color? onTertiaryColor,
  Color? errorColor,
  Color? onErrorColor,
  ColorScheme? colorScheme,

  /// Passed straight through to [ThemeData.textTheme], and used as the
  /// button label style below — apps with their own type scale should pass
  /// it here rather than `.copyWith`-ing the returned [ThemeData], since a
  /// later `.copyWith` wouldn't reach the button styles already built here.
  TextTheme? textTheme,
}) {
  if (colorScheme != null && colorScheme.brightness != brightness) {
    throw ArgumentError.value(
      colorScheme.brightness,
      'colorScheme.brightness',
      'must match brightness ($brightness)',
    );
  }
  final isDark = brightness == Brightness.dark;
  var scheme =
      colorScheme ??
      ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness);

  // A role override without its foreground used to leave an unrelated
  // generated `on*` color behind. Pick the higher-contrast neutral instead,
  // while retaining the supplied scheme's pair when no override is made.
  scheme = scheme.copyWith(
    primary: primaryColor,
    onPrimary:
        onPrimaryColor ??
        (primaryColor == null ? null : _contrastingForeground(primaryColor)),
    secondary: secondaryColor,
    onSecondary:
        onSecondaryColor ??
        (secondaryColor == null
            ? null
            : _contrastingForeground(secondaryColor)),
    tertiary: tertiaryColor,
    onTertiary:
        onTertiaryColor ??
        (tertiaryColor == null ? null : _contrastingForeground(tertiaryColor)),
    error: errorColor,
    onError:
        onErrorColor ??
        (errorColor == null ? null : _contrastingForeground(errorColor)),
  );

  final surface = scheme.surface;
  // Material's container roles carry a subtle seed tint and change tone with
  // brightness, keeping the whole hierarchy harmonious without hand-tuned
  // light/dark hex pairs.
  final surfaceCard = scheme.surfaceContainerLow;
  final inputBorderColor = scheme.outline;
  final disabledInputBorderColor = scheme.outlineVariant.withValues(alpha: .62);

  // Button label text pulls from the app's own type scale when given one;
  // when null, ButtonStyleButton falls back to Theme.of(context)'s default
  // labelLarge at build time, so apps without a custom textTheme see no
  // change from leaving this null.
  final buttonLabelStyle = textTheme?.labelLarge?.copyWith(
    fontWeight: FontWeight.w700,
  );

  return ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: surface,
    useMaterial3: true,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: surfaceCard,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerLowest,
      hoverColor: scheme.primary.withValues(alpha: isDark ? .08 : .04),
      border: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: inputBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: scheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: scheme.error, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        borderSide: BorderSide(color: disabledInputBorderColor),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceCard,
      indicatorColor: scheme.primaryContainer,
    ),
    dividerColor: scheme.outlineVariant,
    // Use a matching container/on-container pair: it is softer than a solid
    // primary track and remains legible in both brightness modes.
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimaryContainer
            : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.primaryContainer
            : null,
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        mouseCursor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
        elevation: 2,
        shadowColor: scheme.primary.withValues(alpha: 0.28),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: buttonLabelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: buttonLabelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.78)),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: buttonLabelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: buttonLabelStyle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceCard,
      modalBackgroundColor: surfaceCard,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: scheme.outlineVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}

Color _contrastingForeground(Color background) {
  final luminance = background.computeLuminance();
  final blackContrast = (luminance + .05) / .05;
  final whiteContrast = 1.05 / (luminance + .05);
  return blackContrast >= whiteContrast ? Colors.black : Colors.white;
}
