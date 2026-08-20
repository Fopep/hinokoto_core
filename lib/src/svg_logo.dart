import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgLogo extends StatelessWidget {
  const SvgLogo({
    super.key,
    required this.assetPath,
    this.height = 40,
    this.semanticsLabel,
  });

  final String assetPath;
  final double height;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 16),
    child: SvgPicture.asset(
      assetPath,
      height: height,
      theme: SvgTheme(currentColor: Theme.of(context).colorScheme.onSurface),
      semanticsLabel: semanticsLabel,
    ),
  );
}
