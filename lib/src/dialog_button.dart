import 'package:flutter/material.dart';

enum DialogButtonType {
  /// Text only (default).
  normal,

  /// Filled with the primary color, for the main affirmative action.
  inverse,

  /// Filled with the error color, for destructive actions.
  destructive,

  /// Outlined with the primary color as its label color.
  outlined,
}

/// A themed text button for dialog actions (confirm/cancel/delete/etc.),
/// styled consistently across [DialogButtonType]s.
class DialogButton extends StatelessWidget {
  const DialogButton(
    this.label, {
    super.key,
    this.onPressed,
    this.type = DialogButtonType.normal,
  });

  final String label;
  final VoidCallback? onPressed;
  final DialogButtonType type;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final ButtonStyle style = switch (type) {
      DialogButtonType.inverse => buildDialogButtonStyle(
        foreground: scheme.onPrimary,
        background: scheme.primary,
      ),
      DialogButtonType.destructive => buildDialogButtonStyle(
        foreground: scheme.onError,
        background: scheme.error,
      ),
      DialogButtonType.outlined => buildDialogButtonStyle(
        foreground: scheme.primary,
        side: BorderSide(color: scheme.outline),
      ),
      DialogButtonType.normal => buildDialogButtonStyle(
        foreground: scheme.primary,
      ),
    };

    return TextButton(
      style: style,
      // No onPressed just dismisses the dialog, matching legacy behavior.
      onPressed: onPressed ?? () => Navigator.of(context).pop(),
      child: Text(label),
    );
  }
}

/// The shared style behind [DialogButton] (a light hover/pressed/focused
/// tint over the given colors), exposed for callers that need the same
/// look on a button [DialogButton] doesn't cover.
ButtonStyle buildDialogButtonStyle({
  required Color foreground,
  Color? background,
  BorderSide? side,
}) {
  return TextButton.styleFrom(
    foregroundColor: foreground,
    backgroundColor: background,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    side: side,
    minimumSize: const Size(48, 52),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      final hovered = states.contains(WidgetState.hovered);
      final focused = states.contains(WidgetState.focused);
      final pressed = states.contains(WidgetState.pressed);
      if (hovered || focused || pressed) {
        // Filled buttons read against their foreground text a bit stronger;
        // text/outlined buttons stay subtler.
        final alpha = background != null ? 0.12 : 0.08;
        return foreground.withValues(alpha: alpha);
      }
      return null;
    }),
  );
}
