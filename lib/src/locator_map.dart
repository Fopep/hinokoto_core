import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// One geographic level rendered by [HierarchicalLocatorMaps].
@immutable
class LocatorMapLevel {
  const LocatorMapLevel({
    required this.id,
    required this.label,
    required this.semanticsLabel,
    required this.contourPath,
    required this.viewBounds,
    this.marker,
    this.highlightPath,
    this.highlightArea,
    this.surfaceKey,
  });

  final String id;
  final String label;
  final String semanticsLabel;
  final Path? contourPath;
  final Rect viewBounds;
  final Offset? marker;
  final Path? highlightPath;

  /// Unscaled area of [highlightPath], used to suppress imperceptible fills.
  final double? highlightArea;
  final Key? surfaceKey;
}

/// Theme-derived colors for an offline vector locator map.
@immutable
class LocatorMapStyle {
  const LocatorMapStyle({
    required this.canvas,
    required this.land,
    required this.outline,
    required this.highlight,
    required this.highlightOutline,
    required this.marker,
    required this.markerSurface,
    required this.labelBackground,
    required this.labelForeground,
    required this.labelBorder,
    required this.controlForeground,
    required this.border,
    required this.shadow,
  });

  final Color canvas;
  final Color land;
  final Color outline;
  final Color highlight;
  final Color highlightOutline;
  final Color marker;
  final Color markerSurface;
  final Color labelBackground;
  final Color labelForeground;
  final Color labelBorder;
  final Color controlForeground;
  final Color border;
  final Color shadow;

  factory LocatorMapStyle.fromTheme(ThemeData theme) {
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return LocatorMapStyle(
      canvas: scheme.surfaceContainerLowest,
      land: scheme.surfaceContainerHigh,
      outline: scheme.outline,
      highlight: scheme.primaryContainer,
      highlightOutline: scheme.primary,
      marker: scheme.error,
      markerSurface: scheme.surfaceContainerLowest,
      labelBackground: Color.alphaBlend(
        scheme.surface.withValues(alpha: isDark ? .90 : .94),
        scheme.surfaceContainerLowest,
      ),
      labelForeground: scheme.onSurface,
      labelBorder: scheme.outlineVariant,
      controlForeground: scheme.onSurfaceVariant,
      border: scheme.outlineVariant,
      shadow: Colors.black.withValues(alpha: isDark ? .28 : .07),
    );
  }
}

/// Responsive, zoomable gallery for a geographic overview-to-detail sequence.
///
/// On wide layouts all levels share one row. On narrow layouts the first
/// overview occupies the full width and subsequent detail levels are paired
/// below it. Domain code remains responsible for selecting and projecting the
/// paths and for supplying localized labels.
class HierarchicalLocatorMaps extends StatelessWidget {
  const HierarchicalLocatorMaps({
    super.key,
    required this.levels,
    this.style,
    this.mapHeight = 144,
    this.gap = 12,
    this.wideBreakpoint = 600,
  }) : assert(levels.length > 0);

  final List<LocatorMapLevel> levels;
  final LocatorMapStyle? style;
  final double mapHeight;
  final double gap;
  final double wideBreakpoint;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle =
        style ?? LocatorMapStyle.fromTheme(Theme.of(context));
    final maps = [
      for (final level in levels)
        _InteractiveLocatorMap(
          level: level,
          style: effectiveStyle,
          height: mapHeight,
        ),
    ];
    return _IntrinsicHeightSafe(
      heightForWidth: (width) {
        if (width >= wideBreakpoint) return mapHeight;
        final rowCount = 1 + ((maps.length - 1) / 2).ceil();
        return rowCount * mapHeight + (rowCount - 1) * gap;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= wideBreakpoint) {
            return Row(
              children: [
                for (var index = 0; index < maps.length; index++) ...[
                  if (index > 0) SizedBox(width: gap),
                  Expanded(child: maps[index]),
                ],
              ],
            );
          }
          return Column(
            children: [
              maps.first,
              for (var index = 1; index < maps.length; index += 2) ...[
                SizedBox(height: gap),
                Row(
                  children: [
                    Expanded(child: maps[index]),
                    if (index + 1 < maps.length) ...[
                      SizedBox(width: gap),
                      Expanded(child: maps[index + 1]),
                    ],
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Gives intrinsic-height parents a deterministic answer without asking the
/// descendant [LayoutBuilder] to perform speculative layout.
class _IntrinsicHeightSafe extends SingleChildRenderObjectWidget {
  const _IntrinsicHeightSafe({
    required this.heightForWidth,
    required Widget super.child,
  });

  final double Function(double width) heightForWidth;

  @override
  _RenderIntrinsicHeightSafe createRenderObject(BuildContext context) =>
      _RenderIntrinsicHeightSafe(heightForWidth);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderIntrinsicHeightSafe renderObject,
  ) {
    renderObject.heightForWidth = heightForWidth;
  }
}

class _RenderIntrinsicHeightSafe extends RenderProxyBox {
  _RenderIntrinsicHeightSafe(this._heightForWidth);

  double Function(double width) _heightForWidth;

  set heightForWidth(double Function(double width) value) {
    if (identical(_heightForWidth, value)) return;
    _heightForWidth = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) => 0;

  @override
  double computeMinIntrinsicHeight(double width) => _heightForWidth(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _heightForWidth(width);

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(
    Size(constraints.maxWidth, _heightForWidth(constraints.maxWidth)),
  );

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) => null;
}

class _InteractiveLocatorMap extends StatefulWidget {
  const _InteractiveLocatorMap({
    required this.level,
    required this.style,
    required this.height,
  });

  final LocatorMapLevel level;
  final LocatorMapStyle style;
  final double height;

  @override
  State<_InteractiveLocatorMap> createState() => _InteractiveLocatorMapState();
}

class _InteractiveLocatorMapState extends State<_InteractiveLocatorMap> {
  static const _zoomScale = 3.0;

  final _transformationController = TransformationController();
  Offset? _pendingDoubleTapPosition;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    final position = _pendingDoubleTapPosition;
    if (position == null) return;
    final isZoomedIn = _transformationController.value.getMaxScaleOnAxis() > 1;
    _transformationController.value = isZoomedIn
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -position.dx * (_zoomScale - 1),
              -position.dy * (_zoomScale - 1),
              0,
              1,
            )
            ..scaleByDouble(_zoomScale, _zoomScale, _zoomScale, 1));
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.level;
    final style = widget.style;
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Semantics(
        label: level.semanticsLabel,
        image: true,
        excludeSemantics: true,
        child: DecoratedBox(
          key: level.surfaceKey ?? ValueKey('locator-map-${level.id}'),
          decoration: BoxDecoration(
            color: style.canvas,
            border: Border.all(color: style.border),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: style.shadow,
                blurRadius: 8,
                spreadRadius: -2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              children: [
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final mapSize = constraints.biggest;
                      return GestureDetector(
                        onDoubleTapDown: (details) =>
                            _pendingDoubleTapPosition = details.localPosition,
                        onDoubleTap: _handleDoubleTap,
                        child: InteractiveViewer(
                          transformationController: _transformationController,
                          minScale: 1,
                          maxScale: 4,
                          child: SizedBox(
                            width: mapSize.width,
                            height: mapSize.height,
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: _LocatorMapPainter(
                                  level: level,
                                  style: style,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 36,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: style.labelBackground,
                        border: Border.all(color: style.labelBorder),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        child: Text(
                          level.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: style.labelForeground,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.zoom_in_rounded,
                      size: 18,
                      color: style.controlForeground,
                    ),
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

class _LocatorMapPainter extends CustomPainter {
  const _LocatorMapPainter({required this.level, required this.style});

  static const _padding = 10.0;
  static const _markerRadius = 4.5;

  final LocatorMapLevel level;
  final LocatorMapStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final viewBounds = level.viewBounds;
    if (!viewBounds.isFinite || viewBounds.isEmpty) return;
    final availableWidth = math.max(0.0, size.width - _padding * 2);
    final availableHeight = math.max(0.0, size.height - _padding * 2);
    if (availableWidth == 0 || availableHeight == 0) return;
    final scale = math.min(
      availableWidth / viewBounds.width,
      availableHeight / viewBounds.height,
    );
    final offset =
        Offset(_padding, _padding) +
        Offset(
          (availableWidth - viewBounds.width * scale) / 2,
          (availableHeight - viewBounds.height * scale) / 2,
        ) -
        viewBounds.topLeft * scale;

    final path = level.contourPath;
    if (path != null) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.scale(scale);
      canvas.drawPath(path, Paint()..color = style.land);
      canvas.drawPath(
        path,
        Paint()
          ..color = style.outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1 / scale,
      );
      final highlight = level.highlightPath;
      final highlightArea = level.highlightArea;
      final isHighlightVisible =
          highlightArea == null || highlightArea * scale * scale >= 15;
      if (highlight != null && isHighlightVisible) {
        canvas.drawPath(highlight, Paint()..color = style.highlight);
        canvas.drawPath(
          highlight,
          Paint()
            ..color = style.highlightOutline
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5 / scale,
        );
      }
      canvas.restore();
    }

    final marker = level.marker;
    if (marker == null) return;
    final markerCenter = offset + marker * scale;
    canvas.drawCircle(
      markerCenter,
      _markerRadius + 4,
      Paint()..color = style.marker.withValues(alpha: .18),
    );
    canvas.drawCircle(
      markerCenter,
      _markerRadius,
      Paint()..color = style.markerSurface,
    );
    canvas.drawCircle(
      markerCenter,
      _markerRadius,
      Paint()
        ..color = style.marker
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawCircle(markerCenter, 2, Paint()..color = style.marker);
  }

  @override
  bool shouldRepaint(covariant _LocatorMapPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.style != style;
}
