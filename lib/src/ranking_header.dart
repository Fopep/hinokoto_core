import 'package:flutter/material.dart';

/// Fixed height shared by ranking-header controls. This is the minimum
/// comfortable touch target while keeping a filter-dense header compact.
const rankingControlHeight = 48.0;

/// Exact height of the two always-visible selector rows, including padding.
const rankingHeaderBaseHeight = 108.0;

/// Extra height occupied by a conditional dropdown row.
const rankingHeaderSecondaryRowHeight = 60.0;

/// Horizontal gap between two controls placed side by side in a ranking
/// header row (e.g. a filter dropdown next to [RankingSortButton]).
const rankingControlGap = 8.0;

/// Vertical gap above a conditionally-shown second row of controls in a
/// ranking header (e.g. a prefecture/operator/year dropdown that only
/// appears for some filter selections).
const rankingSecondaryRowGap = 12.0;

/// Width reserved for a filter dropdown's leading icon in
/// [rankingFilterDropdownDecoration].
const rankingDropdownIconSlotWidth = 48.0;

/// A neutral, pinned surface for ranking filters.
///
/// Ranking controls are dense navigation, not page identity, so the default
/// uses a neutral container rather than a large primary-colored block. A
/// hairline and low, constant elevation keep scrolling content visually below
/// the controls. Optional colors let branded apps override the surface without
/// copying this layout.
class RankingHeaderSurface extends StatelessWidget {
  const RankingHeaderSurface({
    super.key,
    required this.child,
    required this.toolbarHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.dividerColor,
    this.shadowColor,
  });

  final Widget child;
  final double toolbarHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? dividerColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return SliverAppBar(
      pinned: true,
      primary: false,
      automaticallyImplyLeading: false,
      centerTitle: false,
      titleSpacing: 0,
      toolbarHeight: toolbarHeight,
      backgroundColor: backgroundColor ?? scheme.surfaceContainerLow,
      foregroundColor: foregroundColor ?? scheme.onSurface,
      shape: Border(
        bottom: BorderSide(color: dividerColor ?? scheme.outlineVariant),
      ),
      elevation: 2,
      scrolledUnderElevation: 2,
      forceElevated: true,
      shadowColor:
          shadowColor ?? Colors.black.withValues(alpha: isDark ? .32 : .10),
      surfaceTintColor: Colors.transparent,
      title: child,
    );
  }
}

/// The dense, fixed-height decoration used by ranking-header filter
/// dropdowns (`DropdownButtonFormField`), so every such field across apps
/// renders at the same [rankingControlHeight].
InputDecoration rankingFilterDropdownDecoration({
  required IconData icon,
  String? labelText,
  String? hintText,
}) => InputDecoration(
  isDense: true,
  contentPadding: EdgeInsets.zero,
  labelText: labelText,
  hintText: hintText,
  prefixIcon: Icon(icon),
  prefixIconConstraints: const BoxConstraints.tightFor(
    width: rankingDropdownIconSlotWidth,
    height: rankingControlHeight,
  ),
);

/// The sort/reverse-order toggle shown next to a ranking filter.
class RankingSortButton extends StatelessWidget {
  const RankingSortButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.buttonKey,
  });

  final String tooltip;
  final IconData icon;
  final Widget label;
  final VoidCallback onPressed;

  /// Applied to the inner [FilledButton.tonalIcon] (not this widget's own
  /// [key]) so callers can address the button itself, e.g. in widget tests.
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        height: rankingControlHeight,
        child: FilledButton.tonalIcon(
          key: buttonKey,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.surfaceContainerHighest,
            foregroundColor: scheme.primary,
            disabledBackgroundColor: scheme.surfaceContainerHigh,
            disabledForegroundColor: scheme.onSurfaceVariant,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: scheme.outlineVariant),
            ),
          ),
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: label,
        ),
      ),
    );
  }
}

/// A horizontally scrollable, single-select row of chips for a small set of
/// filter options — used for ranking-screen scope/metric/category pickers.
/// Chips size to their own label (measured, with a [minItemWidth] floor)
/// rather than being forced into equal-width segments, so options of very
/// different lengths don't get mid-word ellipsis on narrow phones; the row
/// scrolls instead of cramming or wrapping.
class RankingChipSelector<T> extends StatelessWidget {
  const RankingChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.minItemWidth = 64,
    this.height = rankingControlHeight,
    this.padding = EdgeInsets.zero,
  });

  final List<(T value, String label)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Minimum chip width, in case a label measures narrower than a
  /// comfortable touch target.
  final double minItemWidth;

  /// Total height of the scrolling row. Callers that nest this inside their
  /// own taller bar (to get a few dp of vertical breathing room around the
  /// chips) should pass a smaller value here than that outer bar's height.
  final double height;

  /// Padding applied around the scrolling list itself. Leave as
  /// [EdgeInsets.zero] when the caller already insets the whole row (e.g.
  /// via an outer `Padding`/`ConstrainedBox`); pass a horizontal inset when
  /// this selector is a direct child of a full-width bar.
  final EdgeInsetsGeometry padding;

  double _itemWidth(BuildContext context, String label) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      maxLines: 1,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    return textPainter.width + 32 < minItemWidth
        ? minItemWidth
        : textPainter.width + 32;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accentColor = scheme.primary;
    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label) = options[index];
          final isSelected = value == selected;
          return SizedBox(
            width: _itemWidth(context, label),
            child: ChoiceChip(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              backgroundColor: scheme.surfaceContainerHighest,
              showCheckmark: false,
              // Web font loading can leave the chip's intrinsic text width
              // stale, so rebuild the label once fonts finish loading.
              label: ListenableBuilder(
                listenable: PaintingBinding.instance.systemFonts,
                builder: (context, _) => Text(
                  label,
                  key: UniqueKey(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? scheme.onPrimary
                        : scheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
              selected: isSelected,
              selectedColor: accentColor,
              side: BorderSide(
                color: isSelected ? accentColor : scheme.outlineVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (_) => onChanged(value),
            ),
          );
        },
      ),
    );
  }
}
