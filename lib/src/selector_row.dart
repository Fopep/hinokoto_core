import 'package:flutter/material.dart';

import 'app_bottom_sheet.dart';

/// One choice offered by a [SelectorRow].
class SelectorOption<T> {
  const SelectorOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// A named group of [SelectorOption]s, rendered under a heading in a
/// [SelectorRow]'s bottom sheet when [SelectorRow.sections] is used instead
/// of a flat [SelectorRow.options] list.
class SelectorSection<T> {
  const SelectorSection({this.title, required this.options});

  final String? title;
  final List<SelectorOption<T>> options;
}

/// A settings row: a label on the left, and on the right a compact pill
/// button that opens a modal bottom sheet listing the available choices as a
/// single-choice list (a checkmark marks the current [value]). Choices come
/// from either a flat [options] list or, for grouped pickers, [sections]
/// (exactly one of the two must be provided).
class SelectorRow<T> extends StatelessWidget {
  const SelectorRow({
    super.key,
    required this.label,
    this.labelAccessory,
    required this.value,
    this.options,
    this.sections,
    required this.onChanged,
    this.selectorKey,
  }) : assert(
         (options == null) != (sections == null),
         'Provide exactly one of options or sections.',
       );

  final String label;

  /// Optional widget placed right after the label text, e.g. a help icon
  /// that opens an app-specific description dialog.
  final Widget? labelAccessory;
  final T value;
  final List<SelectorOption<T>>? options;
  final List<SelectorSection<T>>? sections;
  final ValueChanged<T> onChanged;

  /// Key applied to the pill button itself (not the outer row), so tests can
  /// target the tappable control directly regardless of label width.
  final Key? selectorKey;

  Iterable<SelectorOption<T>> get _allOptions =>
      options ?? sections!.expand((section) => section.options);

  String _labelFor(T value) =>
      _allOptions.firstWhere((option) => option.value == value).label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.start,
                ),
              ),
              ?labelAccessory,
            ],
          ),
        ),
        const SizedBox(width: 12),
        Align(
          alignment: Alignment.centerRight,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 120),
            child: OutlinedButton(
              key: selectorKey,
              onPressed: () async {
                final result = await showAppModalBottomSheet<T>(
                  context: context,
                  builder: (context) => Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        if (options != null)
                          for (final option in options!)
                            _SelectorListTile(
                              option: option,
                              selected: option.value == value,
                            )
                        else
                          for (final section in sections!) ...[
                            if (section.title != null)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Text(
                                  section.title!,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            for (final option in section.options)
                              _SelectorListTile(
                                option: option,
                                selected: option.value == value,
                              ),
                          ],
                      ],
                    ),
                  ),
                );
                if (result != null && context.mounted) onChanged(result);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: scheme.onSurface,
                backgroundColor: scheme.surfaceContainerLowest,
                side: BorderSide(color: scheme.outline),
                minimumSize: const Size(120, 48),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(_labelFor(value))),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_drop_down, color: scheme.primary),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectorListTile<T> extends StatelessWidget {
  const _SelectorListTile({required this.option, required this.selected});

  final SelectorOption<T> option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(option.label),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: () => Navigator.of(context).pop(option.value),
    );
  }
}
