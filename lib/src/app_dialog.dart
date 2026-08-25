import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// The shared dialog panel: a header bar (title, optional back button,
/// close button), scrollable content, and an optional actions bar —
/// styled consistently across apps. Pair with [showAppDialog].
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.onBack,
    this.onClose,
    this.showBackButton = false,
    this.maxWidth = 560,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    ),
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 8),
    this.actionsPadding = const EdgeInsets.fromLTRB(8, 8, 8, 8),
    this.insetPadding = EdgeInsets.zero,
    this.scrollController,
  });

  final Widget? title;
  final Widget? content;

  /// Shown in a bar below the content, separated by a divider, when
  /// non-empty.
  final List<Widget>? actions;

  /// Called when the back button is tapped; defaults to popping the
  /// current route (falling back to popping the navigator) when
  /// [showBackButton] is true and this is left unset.
  final VoidCallback? onBack;

  /// Called when the close button is tapped; defaults to popping the
  /// current route.
  final VoidCallback? onClose;

  /// Shows a back button in the header, to its left of the title.
  final bool showBackButton;

  final double maxWidth;
  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry headerPadding;
  final EdgeInsetsGeometry actionsPadding;
  final EdgeInsets insetPadding;

  /// A scrollbar is only shown when a controller is given — long dialogs
  /// where scrolling might otherwise go unnoticed should pass one.
  final ScrollController? scrollController;

  bool get _isCupertino =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final panelColor =
        theme.dialogTheme.backgroundColor ?? scheme.surfaceContainerLow;
    final barBg = Color.alphaBlend(
      scheme.primary.withValues(alpha: .06),
      panelColor,
    );

    return Dialog(
      insetPadding: insetPadding,
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: panelColor,
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: isDark ? .42 : .58),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? .38 : .16),
              blurRadius: 44,
              spreadRadius: -10,
              offset: const Offset(0, 22),
            ),
            BoxShadow(
              color: scheme.primary.withValues(alpha: isDark ? .08 : .05),
              blurRadius: 18,
              spreadRadius: -8,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(maxWidth, MediaQuery.sizeOf(context).width),
            maxHeight: MediaQuery.sizeOf(context).height * .88,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ColoredBox(
                  color: barBg,
                  child: _DialogHeader(
                    padding: headerPadding,
                    title: title,
                    showBack: showBackButton,
                    isCupertino: _isCupertino,
                    onBack:
                        onBack ??
                        () async {
                          final nav = Navigator.of(context);
                          if (await nav.maybePop()) return;
                          if (nav.canPop()) nav.pop();
                        },
                    onClose: onClose ?? () => Navigator.of(context).pop(),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ScrollConfiguration(
                    behavior: const _DialogScrollBehavior(),
                    child: _MaybeScrollbar(
                      controller: scrollController,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: contentPadding,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: content ?? const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  ),
                ),
                ColoredBox(
                  color: barBg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (actions != null && actions!.isNotEmpty) ...[
                        const Divider(height: 1),
                        Padding(
                          padding: actionsPadding,
                          child: _ActionsBar(children: actions!),
                        ),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.viewPaddingOf(context).bottom,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.padding,
    required this.title,
    required this.showBack,
    required this.isCupertino,
    required this.onBack,
    required this.onClose,
  });

  final EdgeInsetsGeometry padding;
  final Widget? title;
  final bool showBack;
  final bool isCupertino;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget roundIconButton({
      required Widget icon,
      required String tooltip,
      required VoidCallback onPressed,
    }) => IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: icon,
      style: IconButton.styleFrom(
        minimumSize: const Size(44, 44),
        maximumSize: const Size(44, 44),
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: .7),
        foregroundColor: scheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: .5)),
        ),
      ),
    );

    return Padding(
      padding: padding,
      child: SizedBox(
        height: 68,
        child: Row(
          children: [
            if (showBack) ...[
              roundIconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack,
                icon: Icon(
                  isCupertino
                      ? Icons.arrow_back_ios_new_rounded
                      : Icons.arrow_back_rounded,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
            ] else
              const SizedBox(width: 8),
            Expanded(
              child: DefaultTextStyle.merge(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -.25,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: title ?? const SizedBox.shrink(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(Icons.close, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionsBar extends StatelessWidget {
  const _ActionsBar({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // A single child (e.g. a whole Column of buttons passed as one action)
    // renders as-is, skipping the shrink-wrapped Row to avoid overflow.
    if (children.length == 1) return children.first;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i != 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Shows a scrollbar only when the caller supplies a [controller] — long
/// dialogs where scrolling might otherwise go unnoticed should pass one.
class _MaybeScrollbar extends StatelessWidget {
  const _MaybeScrollbar({required this.controller, required this.child});

  final ScrollController? controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (c == null) return child;
    return Scrollbar(controller: c, thumbVisibility: true, child: child);
  }
}

class _DialogScrollBehavior extends ScrollBehavior {
  const _DialogScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
    PointerDeviceKind.unknown,
  };

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}

Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) => showDialog<T>(
  context: context,
  barrierDismissible: barrierDismissible,
  barrierColor: const Color(0x99000000),
  builder: (context) {
    final dialog = Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 24, 40, 24),
        child: builder(context),
      ),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: Transform.scale(scale: .965 + (.035 * value), child: child),
          ),
        ),
      ),
      child: dialog,
    );
  },
);
