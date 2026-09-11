import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Theme-derived visual tokens for persistent top and bottom app chrome.
///
/// Consumers can pass a constructed instance to any chrome widget when their
/// brand needs different values; the defaults remain fully driven by the
/// active [ColorScheme].
@immutable
class AppChromeStyle {
  const AppChromeStyle({
    required this.background,
    required this.foreground,
    required this.mutedForeground,
    required this.accent,
    required this.indicator,
    required this.divider,
    required this.shadow,
  });

  final Color background;
  final Color foreground;
  final Color mutedForeground;
  final Color accent;
  final Color indicator;
  final Color divider;
  final Color shadow;

  factory AppChromeStyle.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    return AppChromeStyle(
      background: scheme.surfaceContainerLow,
      foreground: scheme.onSurface,
      mutedForeground: scheme.onSurfaceVariant,
      accent: scheme.primary,
      indicator: scheme.primaryContainer,
      divider: scheme.outlineVariant,
      shadow: Colors.black.withValues(
        alpha: theme.brightness == Brightness.dark ? .28 : .07,
      ),
    );
  }
}

/// Adds a neutral surface, hairline, and restrained downward shadow to an
/// app bar while suppressing the child's own tint and elevation.
class AppChromeBar extends StatelessWidget implements PreferredSizeWidget {
  const AppChromeBar({super.key, required this.child, this.style});

  final PreferredSizeWidget child;
  final AppChromeStyle? style;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? AppChromeStyle.fromTheme(Theme.of(context));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveStyle.background,
        border: Border(bottom: BorderSide(color: effectiveStyle.divider)),
        boxShadow: [
          BoxShadow(
            color: effectiveStyle.shadow,
            blurRadius: 8,
            spreadRadius: -1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          appBarTheme: Theme.of(context).appBarTheme.copyWith(
            backgroundColor: Colors.transparent,
            foregroundColor: effectiveStyle.foreground,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
          ),
        ),
        child: child,
      ),
    );
  }
}

/// Sliver equivalent of [AppChromeBar] for a fixed app bar in a custom scroll
/// view.
class AppChromeSliverBar extends StatelessWidget {
  const AppChromeSliverBar({super.key, required this.child, this.style});

  final PreferredSizeWidget child;
  final AppChromeStyle? style;

  @override
  Widget build(BuildContext context) {
    final extent =
        child.preferredSize.height + MediaQuery.paddingOf(context).top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _AppChromeSliverDelegate(
        child: child,
        style: style,
        extent: extent,
      ),
    );
  }
}

class _AppChromeSliverDelegate extends SliverPersistentHeaderDelegate {
  const _AppChromeSliverDelegate({
    required this.child,
    required this.style,
    required this.extent,
  });

  final PreferredSizeWidget child;
  final AppChromeStyle? style;
  final double extent;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => AppChromeBar(style: style, child: child);

  @override
  bool shouldRebuild(covariant _AppChromeSliverDelegate oldDelegate) =>
      oldDelegate.child != child ||
      oldDelegate.style != style ||
      oldDelegate.extent != extent;
}

/// Frames any persistent bottom operation bar with the same surface and
/// hairline as the top chrome and a restrained upward shadow.
class AppBottomBarFrame extends StatelessWidget {
  const AppBottomBarFrame({super.key, required this.child, this.style});

  final Widget child;
  final AppChromeStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? AppChromeStyle.fromTheme(Theme.of(context));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveStyle.background,
        border: Border(top: BorderSide(color: effectiveStyle.divider)),
        boxShadow: [
          BoxShadow(
            color: effectiveStyle.shadow,
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: IconTheme(
        data: IconThemeData(color: effectiveStyle.mutedForeground),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: effectiveStyle.foreground),
          child: child,
        ),
      ),
    );
  }
}

/// Adds explicit accessible selected and unselected navigation states to
/// [AppBottomBarFrame]. Use the base frame directly for non-navigation action
/// bars such as media controls.
class AppBottomNavigationFrame extends StatelessWidget {
  const AppBottomNavigationFrame({super.key, required this.child, this.style});

  final Widget child;
  final AppChromeStyle? style;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? AppChromeStyle.fromTheme(Theme.of(context));
    return AppBottomBarFrame(
      style: effectiveStyle,
      child: NavigationBarTheme(
        data: Theme.of(context).navigationBarTheme.copyWith(
          backgroundColor: Colors.transparent,
          elevation: 0,
          indicatorColor: effectiveStyle.indicator,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected
                  ? effectiveStyle.accent
                  : effectiveStyle.mutedForeground,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return Theme.of(context).textTheme.labelMedium?.copyWith(
              color: selected
                  ? effectiveStyle.accent
                  : effectiveStyle.mutedForeground,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            );
          }),
        ),
        child: child,
      ),
    );
  }
}

/// Visual priority for an [AppBottomActionButton].
enum AppBottomActionEmphasis {
  /// A supporting action such as reset or settings.
  standard,

  /// A supporting action whose mode is currently active.
  selected,

  /// The bar's single dominant action such as play, pause, or stop.
  primary,
}

/// A consistent circular action for persistent bottom operation bars.
///
/// The default geometry guarantees at least a 48dp target. Standard actions
/// use a quiet neutral surface, selected actions use the primary container,
/// and the single primary action uses the strongest semantic color and a
/// small amount of elevation. [style] is applied last for exceptional brand
/// needs without requiring consumers to copy the base state handling.
class AppBottomActionButton extends StatelessWidget {
  const AppBottomActionButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.emphasis = AppBottomActionEmphasis.standard,
    this.size,
    this.iconSize,
    this.semanticLabel,
    this.buttonKey,
    this.style,
  });

  final Widget icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final AppBottomActionEmphasis emphasis;
  final double? size;
  final double? iconSize;
  final String? semanticLabel;

  /// Applied to the inner [IconButton].
  final Key? buttonKey;

  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isPrimary = emphasis == AppBottomActionEmphasis.primary;
    final isSelected = emphasis == AppBottomActionEmphasis.selected;
    final effectiveSize = math
        .max(size ?? (isPrimary ? 64 : 48), 48)
        .toDouble();
    final effectiveIconSize = iconSize ?? (isPrimary ? 32 : 22);
    final background = isPrimary
        ? scheme.primary
        : isSelected
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest;
    final foreground = isPrimary
        ? scheme.onPrimary
        : isSelected
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;
    final borderColor = isPrimary
        ? scheme.primary
        : isSelected
        ? scheme.primary.withValues(alpha: .55)
        : scheme.outlineVariant;
    final baseStyle = IconButton.styleFrom(
      backgroundColor: background,
      foregroundColor: foreground,
      disabledBackgroundColor: scheme.surfaceContainerHigh,
      disabledForegroundColor: scheme.onSurface.withValues(alpha: .38),
      fixedSize: Size.square(effectiveSize),
      minimumSize: const Size.square(48),
      padding: EdgeInsets.zero,
      tapTargetSize: MaterialTapTargetSize.padded,
      elevation: isPrimary ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: isDark ? .30 : .16),
      shape: CircleBorder(side: BorderSide(color: borderColor)),
    ).merge(style);

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: semanticLabel ?? tooltip,
      onTap: onPressed,
      child: ExcludeSemantics(
        child: IconButton(
          key: buttonKey,
          iconSize: effectiveIconSize,
          style: baseStyle,
          tooltip: tooltip,
          onPressed: onPressed,
          icon: icon,
        ),
      ),
    );
  }
}
