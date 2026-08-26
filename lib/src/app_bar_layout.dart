import 'dart:math' as math;

import 'package:flutter/material.dart';

const appContentMaxWidth = 760.0;

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
  Widget build(BuildContext context) {
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
