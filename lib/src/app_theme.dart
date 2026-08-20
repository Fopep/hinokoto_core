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

/// Builds a Material 3 [ThemeData]. The color arguments default to
/// [AppPalette]'s values, but every app using this shared theme need not
/// share the same brand colors — pass your own to change them without
/// forking this function.
ThemeData buildAppTheme(
  Brightness brightness, {
  Color seedColor = AppPalette.blue,
  Color? primaryColor,
  Color onPrimaryColor = const Color(0xFF00243A),
  Color secondaryColor = AppPalette.purple,
  Color tertiaryColor = AppPalette.orange,
  Color errorColor = AppPalette.red,
}) {
  final isDark = brightness == Brightness.dark;
  final surface = isDark ? const Color(0xFF101418) : const Color(0xFFF7F9FB);
  final inputBorderColor = isDark
      ? const Color(0xFF52616D)
      : const Color(0xFFB8C4CE);
  final disabledInputBorderColor = isDark
      ? const Color(0xFF303941)
      : const Color(0xFFDDE4EA);
  final scheme =
      ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: brightness,
        surface: surface,
      ).copyWith(
        primary: primaryColor ?? seedColor,
        onPrimary: onPrimaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        error: errorColor,
      );

  return ThemeData(
    colorScheme: scheme,
    brightness: brightness,
    scaffoldBackgroundColor: surface,
    useMaterial3: true,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: surface,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: isDark ? const Color(0xFF181D22) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(18)),
        side: BorderSide(
          color: isDark ? const Color(0xFF303941) : const Color(0xFFDDE4EA),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF20272D) : Colors.white,
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
      backgroundColor: isDark ? const Color(0xFF181D22) : Colors.white,
      indicatorColor: seedColor.withValues(alpha: isDark ? .28 : .20),
    ),
    dividerColor: isDark ? const Color(0xFF354049) : const Color(0xFFDDE4EA),
  );
}
