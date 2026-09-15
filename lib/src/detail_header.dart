import 'package:flutter/material.dart';

import 'app_bar_layout.dart';

/// Visual tokens for a detail page's heading and tab switcher.
@immutable
class DetailHeaderStyle {
  const DetailHeaderStyle({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.foreground,
    required this.accent,
    required this.divider,
    required this.shadow,
    required this.tabBackground,
    required this.tabSelected,
    required this.tabUnselected,
  });

  final Color backgroundStart;
  final Color backgroundEnd;
  final Color foreground;
  final Color accent;
  final Color divider;
  final Color shadow;
  final Color tabBackground;
  final Color tabSelected;
  final Color tabUnselected;

  factory DetailHeaderStyle.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final base = scheme.surfaceContainerLow;
    return DetailHeaderStyle(
      backgroundStart: Color.alphaBlend(
        scheme.primary.withValues(alpha: isDark ? .035 : .018),
        base,
      ),
      backgroundEnd: Color.alphaBlend(
        scheme.primary.withValues(alpha: isDark ? .07 : .05),
        base,
      ),
      foreground: scheme.onSurface,
      accent: scheme.primary,
      divider: scheme.outlineVariant,
      shadow: Colors.black.withValues(alpha: isDark ? .28 : .07),
      tabBackground: scheme.surfaceContainer,
      tabSelected: scheme.primary,
      tabUnselected: scheme.onSurfaceVariant,
    );
  }
}

/// Fixed-height, non-collapsing surface for any detail-page heading content.
class DetailHeadingSurface extends StatelessWidget
    implements PreferredSizeWidget {
  const DetailHeadingSurface({
    super.key,
    required this.child,
    this.height = 76,
    this.maxWidth = appContentMaxWidth,
    this.style,
  });

  final Widget child;
  final double height;
  final double maxWidth;
  final DetailHeaderStyle? style;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ?? DetailHeaderStyle.fromTheme(Theme.of(context));
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            effectiveStyle.backgroundStart,
            effectiveStyle.backgroundEnd,
          ],
        ),
        border: Border(bottom: BorderSide(color: effectiveStyle.divider)),
      ),
      child: AppBar(
        primary: false,
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: height,
        backgroundColor: Colors.transparent,
        foregroundColor: effectiveStyle.foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: SizedBox(
          height: height,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(width: double.infinity, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Convenience title and optional subtitle for [DetailHeadingSurface].
class DetailHeadingBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailHeadingBar({
    super.key,
    required this.title,
    this.subtitle,
    this.height = 76,
    this.maxWidth = appContentMaxWidth,
    this.style,
  });

  final String title;
  final String? subtitle;
  final double height;
  final double maxWidth;
  final DetailHeaderStyle? style;

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ?? DetailHeaderStyle.fromTheme(Theme.of(context));
    final subtitleText = subtitle;
    return DetailHeadingSurface(
      height: height,
      maxWidth: maxWidth,
      style: effectiveStyle,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitleText != null && subtitleText.isNotEmpty)
            Text(
              subtitleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: effectiveStyle.accent,
                fontWeight: FontWeight.w700,
                letterSpacing: .2,
              ),
            ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: effectiveStyle.foreground,
              fontWeight: FontWeight.w800,
              letterSpacing: -.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// A detail-page tab switcher visually paired with [DetailHeadingSurface].
class DetailTabBar extends StatelessWidget {
  const DetailTabBar({
    super.key,
    required this.tabs,
    this.controller,
    this.maxWidth = appContentMaxWidth,
    this.style,
    this.isScrollable = false,
    this.tabAlignment,
  });

  final List<Widget> tabs;
  final TabController? controller;
  final double maxWidth;
  final DetailHeaderStyle? style;
  final bool isScrollable;
  final TabAlignment? tabAlignment;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ?? DetailHeaderStyle.fromTheme(Theme.of(context));
    return DecoratedBox(
      decoration: BoxDecoration(
        color: effectiveStyle.tabBackground,
        border: Border(bottom: BorderSide(color: effectiveStyle.divider)),
        boxShadow: [
          BoxShadow(
            color: effectiveStyle.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: TabBar(
            controller: controller,
            labelColor: effectiveStyle.tabSelected,
            unselectedLabelColor: effectiveStyle.tabUnselected,
            indicatorColor: effectiveStyle.tabSelected,
            dividerColor: Colors.transparent,
            isScrollable: isScrollable,
            tabAlignment:
                tabAlignment ?? (isScrollable ? TabAlignment.start : null),
            tabs: tabs,
          ),
        ),
      ),
    );
  }
}
