import 'package:flutter/material.dart';

/// A small rounded pill showing a formatted year label (e.g. "2023年度") next
/// to a stat card's title. Callers supply the already-localized [label]
/// (e.g. `context.l10n.yearLabel(year)`) since this package has no access to
/// an app's own localizations.
class YearPill extends StatelessWidget {
  const YearPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(label, style: Theme.of(context).textTheme.labelSmall),
  );
}

/// A small labeled metric — an icon+label/value pair when [icon] is given,
/// or a plain label/value row otherwise. Used inside a stat card's tile
/// grid to show supporting figures (rank, deviation, trend, ...).
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    this.icon,
    required this.label,
    required this.value,
  });

  final IconData? icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: icon != null
        ? const EdgeInsets.all(11)
        : const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 19, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
        ],
        if (icon != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelSmall),
                Text(value, style: Theme.of(context).textTheme.labelLarge),
              ],
            ),
          )
        else ...[
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ],
    ),
  );
}
