import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.title,
    this.content,
    this.maxWidth = 560,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    ),
  });

  final Widget? title;
  final Widget? content;
  final double maxWidth;
  final EdgeInsetsGeometry contentPadding;

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
    final barColor = Color.alphaBlend(
      scheme.primary.withValues(alpha: .06),
      panelColor,
    );

    return Dialog(
      insetPadding: EdgeInsets.zero,
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
                  color: barColor,
                  child: _DialogHeader(title: title, isCupertino: _isCupertino),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ScrollConfiguration(
                    behavior: const _DialogScrollBehavior(),
                    child: SingleChildScrollView(
                      padding: contentPadding,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: content ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
                ColoredBox(
                  color: barColor,
                  child: SizedBox(
                    width: double.infinity,
                    height: MediaQuery.viewPaddingOf(context).bottom,
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
  const _DialogHeader({required this.title, required this.isCupertino});

  final Widget? title;
  final bool isCupertino;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: SizedBox(
      height: 68,
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Icon(
              isCupertino ? Icons.close_rounded : Icons.close,
              size: 28,
            ),
          ),
        ],
      ),
    ),
  );
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
