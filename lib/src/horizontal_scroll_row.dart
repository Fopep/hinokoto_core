import 'package:flutter/material.dart';

/// A single-line row of [children] that stays aligned within the available
/// width when it fits, and becomes horizontally scrollable instead of
/// wrapping onto a second line when it doesn't. Overflowing content fades
/// out at the scrolled-away edge instead of being hard-clipped or hidden
/// without any affordance.
class HorizontalScrollRow extends StatefulWidget {
  const HorizontalScrollRow({
    super.key,
    required this.children,
    this.spacing = 8,
    this.reverse = false,
    this.mainAxisAlignment = MainAxisAlignment.center,
  });

  final List<Widget> children;
  final double spacing;

  /// Which edge the content hugs (and stays anchored to) when it overflows.
  final bool reverse;

  final MainAxisAlignment mainAxisAlignment;

  @override
  State<HorizontalScrollRow> createState() => _HorizontalScrollRowState();
}

class _HorizontalScrollRowState extends State<HorizontalScrollRow> {
  // Matches the edge margin of Hinokoto Studio's other horizontally-swipeable
  // bars, and gives button drop shadows room to render instead of being cut
  // off by the scroll viewport's clip rect at the start/end of the
  // scrollable content.
  static const _edgePadding = EdgeInsets.symmetric(horizontal: 16, vertical: 6);

  // Width of the fade applied at an edge once there's more content to
  // scroll to in that direction, so an off-screen child tapers away
  // instead of looking like it's abruptly cut off/hidden.
  static const _fadeWidth = 20.0;

  bool _showLeadingFade = false;
  bool _showTrailingFade = false;

  void _updateFades(ScrollMetrics metrics) {
    final showLeading = metrics.pixels > metrics.minScrollExtent + 1;
    final showTrailing = metrics.pixels < metrics.maxScrollExtent - 1;
    if (showLeading != _showLeadingFade || showTrailing != _showTrailingFade) {
      setState(() {
        _showLeadingFade = showLeading;
        _showTrailingFade = showTrailing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scrollView = ScrollConfiguration(
          // Web/desktop draw a persistent scrollbar over scrollable regions
          // by default; on a row this short, its track overlaps the last
          // button and makes the edge look clipped. This toolbar-style row
          // is swiped by drag, so the scrollbar isn't needed anyway.
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: NotificationListener<ScrollMetricsNotification>(
            onNotification: (notification) {
              _updateFades(notification.metrics);
              return false;
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                _updateFades(notification.metrics);
                return false;
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: widget.reverse,
                padding: _edgePadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth - _edgePadding.horizontal,
                  ),
                  child: Row(
                    mainAxisAlignment: widget.mainAxisAlignment,
                    children: [
                      for (final (index, child) in widget.children.indexed) ...[
                        if (index > 0) SizedBox(width: widget.spacing),
                        child,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        if (!_showLeadingFade && !_showTrailingFade) {
          return scrollView;
        }

        final width = constraints.maxWidth;
        final leadingStop = _showLeadingFade ? _fadeWidth / width : 0.0;
        final trailingStop = _showTrailingFade ? 1 - _fadeWidth / width : 1.0;
        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => LinearGradient(
            colors: const [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0, leadingStop, trailingStop, 1],
          ).createShader(bounds),
          child: scrollView,
        );
      },
    );
  }
}
