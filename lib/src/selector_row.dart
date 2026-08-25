import 'package:flutter/material.dart';

import 'app_bottom_sheet.dart';

/// One choice offered by a [SelectorRow].
class SelectorOption<T> {
  const SelectorOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// A settings row: a label on the left, and on the right a compact pill
/// button that opens a modal bottom sheet listing [options] as a
/// single-choice list (a checkmark marks the current [value]).
class SelectorRow<T> extends StatelessWidget {
  const SelectorRow({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<SelectorOption<T>> options;
  final ValueChanged<T> onChanged;

  String _labelFor(T value) =>
      options.firstWhere((option) => option.value == value).label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.5);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            softWrap: true,
            maxLines: 3,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 120),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  final result = await showAppModalBottomSheet<T>(
                    context: context,
                    builder: (context) => Padding(
                      padding: const EdgeInsets.only(bottom: 100),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final option in options)
                            ListTile(
                              title: Text(option.label),
                              trailing: option.value == value
                                  ? Icon(
                                      Icons.check,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : null,
                              onTap: () =>
                                  Navigator.of(context).pop(option.value),
                            ),
                        ],
                      ),
                    ),
                  );
                  if (result != null) onChanged(result);
                },
                child: Container(
                  height: 48,
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    color: selectColor,
                    border: Border.all(color: Colors.blueGrey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_labelFor(value)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
