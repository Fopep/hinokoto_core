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

/// The deliberate Hinokoto brand scheme.
///
/// Unlike a generated dark scheme, its primary is a confident mid-blue rather
/// than a pale pastel. Light mode uses a deeper blue so white labels retain
/// WCAG AA contrast. Neutral surfaces carry only a restrained cool tint,
/// leaving the four-color Hinokoto logo and data colors room to stand out.
ColorScheme buildHinokotoColorScheme(Brightness brightness) {
  final base = ColorScheme.fromSeed(
    seedColor: AppPalette.blue,
    brightness: brightness,
  );

  return switch (brightness) {
    Brightness.light => base.copyWith(
      primary: const Color(0xFF086FA8),
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD3EDFF),
      onPrimaryContainer: const Color(0xFF004B73),
      secondary: const Color(0xFF6D4FA3),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFEBDDFF),
      onSecondaryContainer: const Color(0xFF4F347F),
      tertiary: const Color(0xFF956000),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFDEA6),
      onTertiaryContainer: const Color(0xFF5D3A00),
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF93000A),
      surface: const Color(0xFFF5F8FB),
      onSurface: const Color(0xFF182025),
      surfaceDim: const Color(0xFFD7DEE3),
      surfaceBright: const Color(0xFFF9FBFD),
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: Colors.white,
      surfaceContainer: const Color(0xFFF0F4F7),
      surfaceContainerHigh: const Color(0xFFE8EEF2),
      surfaceContainerHighest: const Color(0xFFDFE7EC),
      onSurfaceVariant: const Color(0xFF44515A),
      outline: const Color(0xFF6F7D86),
      outlineVariant: const Color(0xFFC3CDD3),
      inverseSurface: const Color(0xFF2D353A),
      onInverseSurface: const Color(0xFFEEF2F5),
      inversePrimary: const Color(0xFF76C7F6),
      surfaceTint: const Color(0xFF086FA8),
    ),
    Brightness.dark => base.copyWith(
      primary: AppPalette.blue,
      onPrimary: const Color(0xFF00243A),
      primaryContainer: const Color(0xFF174C6B),
      onPrimaryContainer: const Color(0xFFC4E8FF),
      secondary: const Color(0xFFB99AE5),
      onSecondary: const Color(0xFF251239),
      secondaryContainer: const Color(0xFF49325F),
      onSecondaryContainer: const Color(0xFFECD9FF),
      tertiary: const Color(0xFFE8AF45),
      onTertiary: const Color(0xFF382800),
      tertiaryContainer: const Color(0xFF5E450F),
      onTertiaryContainer: const Color(0xFFFFE0A3),
      error: const Color(0xFFF07A82),
      onError: const Color(0xFF33090D),
      errorContainer: const Color(0xFF65242A),
      onErrorContainer: const Color(0xFFFFDADD),
      surface: const Color(0xFF0F1519),
      onSurface: const Color(0xFFE7EDF1),
      surfaceDim: const Color(0xFF0B1014),
      surfaceBright: const Color(0xFF303A41),
      surfaceContainerLowest: const Color(0xFF12191E),
      surfaceContainerLow: const Color(0xFF182126),
      surfaceContainer: const Color(0xFF1D272D),
      surfaceContainerHigh: const Color(0xFF222D34),
      surfaceContainerHighest: const Color(0xFF2A363E),
      onSurfaceVariant: const Color(0xFFBAC5CC),
      outline: const Color(0xFF8A979F),
      outlineVariant: const Color(0xFF3D4951),
      inverseSurface: const Color(0xFFE7EDF1),
      onInverseSurface: const Color(0xFF263036),
      inversePrimary: const Color(0xFF086FA8),
      surfaceTint: AppPalette.blue,
    ),
  };
}

/// Builds a Material 3 [ThemeData] from a coherent tonal palette.
///
/// With the default [seedColor], this uses [buildHinokotoColorScheme]. Another
/// seed gets Material's generated tonal palette. Individual role overrides
/// remain available, and [colorScheme] lets an app supply a complete scheme
/// without forking the shared component themes.
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
      (seedColor == AppPalette.blue
          ? buildHinokotoColorScheme(brightness)
          : ColorScheme.fromSeed(seedColor: seedColor, brightness: brightness));

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
    // A switch is a binary status, so its on state should be unmistakable.
    // Keep the brand-blue track and white thumb in both brightness modes;
    // generated primary-container colors were too pale in light mode.
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return null;
        return states.contains(WidgetState.selected) ? Colors.white : null;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return null;
        return states.contains(WidgetState.selected) ? scheme.primary : null;
      }),
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
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        disabledBackgroundColor: scheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: scheme.onSurface.withValues(alpha: 0.38),
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
