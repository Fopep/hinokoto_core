import 'dart:math' as math;

import 'package:flutter/material.dart';

const appContentMaxWidth = 760.0;

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
