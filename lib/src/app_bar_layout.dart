import 'dart:math' as math;

import 'package:flutter/material.dart';

const appContentMaxWidth = 760.0;

/// Wraps [child] — almost always a plain [AppBar] — in the downward drop
/// shadow used by all Hinokoto Studio app bars. Use this directly for
/// screens whose app bar doesn't fit [HinokotoAppBar]'s logo+single-action
/// shape (custom leading/back buttons, multiple actions, plain title text,
/// etc); [HinokotoAppBar] itself is built on top of this widget.
///
/// Set [showShadow] to `false` to opt a call site out of the shadow.
class HinokotoAppBarShadow extends StatelessWidget
    implements PreferredSizeWidget {
  const HinokotoAppBarShadow({
    super.key,
    required this.child,
    this.showShadow = true,
  });

  final PreferredSizeWidget child;
  final bool showShadow;

  @override
  Size get preferredSize => child.preferredSize;

  @override
  Widget build(BuildContext context) {
    if (!showShadow) return child;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? .34 : .14),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// The [HinokotoAppBarShadow] treatment for an app bar living inside a
/// [CustomScrollView] (e.g. as a pinned [SliverAppBar] replacement) rather
/// than a [Scaffold.appBar]. [child] is rendered at a fixed pinned extent of
/// its [PreferredSizeWidget.preferredSize] height plus the top safe-area
/// inset, matching how [SliverAppBar] sizes itself by default.
class HinokotoSliverAppBarShadow extends StatelessWidget {
  const HinokotoSliverAppBarShadow({
    super.key,
    required this.child,
    this.showShadow = true,
  });

  final PreferredSizeWidget child;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _ShadowedSliverAppBarDelegate(
        child: child,
        showShadow: showShadow,
        extent: child.preferredSize.height + topPadding,
      ),
    );
  }
}

class _ShadowedSliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _ShadowedSliverAppBarDelegate({
    required this.child,
    required this.showShadow,
    required this.extent,
  });

  final PreferredSizeWidget child;
  final bool showShadow;
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
  ) => HinokotoAppBarShadow(showShadow: showShadow, child: child);

  @override
  bool shouldRebuild(covariant _ShadowedSliverAppBarDelegate oldDelegate) =>
      oldDelegate.child != child ||
      oldDelegate.showShadow != showShadow ||
      oldDelegate.extent != extent;
}

/// A standard top app bar with a logo as its title and a single trailing
/// action (typically [MenuWithPinnedClose]). Centralizing this layout means
/// a change to the logo's position or spacing here reaches every app that
/// uses it, instead of being copied into each app's own screen.
class HinokotoAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HinokotoAppBar({
    super.key,
    required this.logo,
    required this.menu,
    this.centerTitle = true,
  });

  final Widget logo;
  final Widget menu;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => HinokotoAppBarShadow(
    child: AppBar(
      centerTitle: centerTitle,
      title: logo,
      actions: [menu],
      elevation: 0,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
  );
}

/// A pinned sliver header that stays fixed at the top of a [CustomScrollView]
/// (e.g. a detail screen's title bar). It has no border of its own; instead
/// it relies on Material 3's built-in "scrolled under" tint
/// (via [SliverAppBar.surfaceTintColor]) to shade slightly darker once
/// content has scrolled beneath it, hinting at the scroll position without a
/// persistent divider line.
///
/// [key] identifies this wrapper, not the inner [SliverAppBar] — locate the
/// latter in tests with `find.descendant(of: find.byKey(...), matching:
/// find.byType(SliverAppBar))`.
class HinokotoPinnedHeader extends StatelessWidget {
  const HinokotoPinnedHeader({
    super.key,
    required this.child,
    this.toolbarHeight = 64,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Widget child;
  final double toolbarHeight;

  /// Overrides the theme-aware, subtly brand-tinted background.
  final Color? backgroundColor;

  /// Overrides the high-contrast text and icon color.
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final effectiveBackgroundColor =
        backgroundColor ??
        Color.alphaBlend(
          scheme.primary.withValues(
            alpha: theme.brightness == Brightness.dark ? .12 : .10,
          ),
          theme.brightness == Brightness.dark
              ? scheme.surfaceContainerHigh
              : scheme.surface,
        );

    return SliverAppBar(
      pinned: true,
      primary: false,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      toolbarHeight: toolbarHeight,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: foregroundColor ?? scheme.onSurface,
      surfaceTintColor: scheme.surfaceTint,
      title: child,
    );
  }
}

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  static const _buttonSize = 48.0;

  final VoidCallback? onPressed;

  static double leadingWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentLeft = (screenWidth - appContentMaxWidth) / 2;
    return math.max(kToolbarHeight, contentLeft + _buttonSize);
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: SizedBox.square(
      dimension: _buttonSize,
      child: BackButton(onPressed: onPressed),
    ),
  );
}
