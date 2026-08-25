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

  /// Passed straight through to [ThemeData.textTheme], and used as the
  /// button label style below — apps with their own type scale should pass
  /// it here rather than `.copyWith`-ing the returned [ThemeData], since a
  /// later `.copyWith` wouldn't reach the button styles already built here.
  TextTheme? textTheme,
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
  // Always derived from dark mode's tonal palette, regardless of the
  // theme's actual brightness — dark mode's primary-container pair reads
  // well against both a light and a dark background, whereas light mode's
  // own (much paler) primary-container looks washed out. Used for switches
  // only, so they look identical in both themes.
  final switchColors = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  ).copyWith(primary: primaryColor ?? seedColor);

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
    // Material 3's default switch fills the whole "on" track with
    // colorScheme.primary and a near-opposite thumb color, which reads as
    // quite intense against this palette's saturated seed colors. The
    // softer primary-container pair keeps switches on-brand without the
    // harsh contrast; returning null for other states defers to Flutter's
    // built-in Material 3 defaults. The "on" thumb is plain white against
    // that track; the "off" thumb keeps Flutter's default.
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected) ? Colors.white : null,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? switchColors.primaryContainer
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
        shadowColor: scheme.primary.withValues(alpha: 0.45),
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
      backgroundColor: isDark ? const Color(0xFF181D22) : Colors.white,
      modalBackgroundColor: isDark ? const Color(0xFF181D22) : Colors.white,
      surfaceTintColor: Colors.transparent,
      showDragHandle: true,
      dragHandleColor: scheme.outlineVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}
