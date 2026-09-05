import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_bar_layout.dart';

/// A single icon+label row for use as an entry in [MenuWithPinnedClose]'s
/// `itemBuilder`, styled to match the panel's menu items.
class HinokotoAppMenuItem extends PopupMenuItem<String> {
  HinokotoAppMenuItem({
    super.key,
    required String value,
    required IconData icon,
    required String label,
  }) : super(
         value: value,
         child: Builder(
           builder: (context) => ListTile(
             contentPadding: EdgeInsets.zero,
             leading: Icon(icon),
             title: Text(
               label,
               style: Theme.of(context).textTheme.titleMedium?.copyWith(
                 fontSize: 17,
                 fontWeight: FontWeight.w500,
               ),
             ),
           ),
         ),
       );
}

/// A menu button that opens a top-right-anchored popup panel with a
/// branded header (pinned close button) instead of Flutter's default
/// [PopupMenuButton] dropdown.
class MenuWithPinnedClose extends StatefulWidget {
  const MenuWithPinnedClose({
    super.key,
    required this.header,
    required this.itemBuilder,
    required this.onSelected,
    this.iconSize = 24,
    this.menuIcon = Icons.menu_rounded,
    this.closeIcon = Icons.close_rounded,
    this.constraints,
    this.menuWidth = 360,
    this.barrierColor = const Color(0x7A000000),
    this.blurSigma = 4,
    this.bottomReservedSpace = 0,
    this.contentMaxWidth = appContentMaxWidth,
    this.onBeforeOpen,
    this.onClosed,
  });

  /// The branding widget shown at the top of the opened panel, next to its
  /// close button (typically an app logo).
  final Widget header;

  final PopupMenuItemBuilder<String> itemBuilder;
  final ValueChanged<String> onSelected;

  final double iconSize;

  /// Shown on the trigger button while the panel is closed.
  final IconData menuIcon;

  /// Shown on the trigger button while the panel is open, and on the
  /// panel's own close button.
  final IconData closeIcon;

  final BoxConstraints? constraints;
  final double menuWidth;
  final Color barrierColor;
  final double blurSigma;
  final double bottomReservedSpace;

  /// The same content-width cap used elsewhere to center content on wide
  /// screens; used here to keep the button aligned with that content.
  final double contentMaxWidth;

  /// Called just before the panel opens, after the trigger is tapped but
  /// before the overlay is inserted. Useful for callers whose webview is an
  /// iframe (web) and needs an `Offstage` change to reach the DOM first.
  final Future<void> Function()? onBeforeOpen;

  /// Called after the panel has closed, whether by selection or dismissal.
  final VoidCallback? onClosed;

  @override
  State<MenuWithPinnedClose> createState() => _MenuWithPinnedCloseState();
}

class _MenuWithPinnedCloseState extends State<MenuWithPinnedClose> {
  static const _compactRightPadding = 5.0;
  static const _appBarActionsEndPadding = 4.0;

  final GlobalKey _buttonKey = GlobalKey();
  bool _isOpen = false;

  Future<void> _openMenu() async {
    if (_isOpen) return;

    final buttonContext = _buttonKey.currentContext;
    if (buttonContext == null) return;

    final buttonBox = buttonContext.findRenderObject();
    if (buttonBox is! RenderBox || !buttonBox.hasSize) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    final overlay = navigator.overlay;
    if (overlay == null) return;

    final overlayBox = overlay.context.findRenderObject();
    if (overlayBox is! RenderBox || !overlayBox.hasSize) return;

    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;

    final buttonPosition = buttonBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );

    const screenMargin = 10.0;
    const panelGap = 4.0;

    final availableWidth = math.max(0.0, screenSize.width - screenMargin * 2);
    final menuWidth = math.min(widget.menuWidth, availableWidth);
    final buttonRight = buttonPosition.dx + buttonBox.size.width;
    final panelRight = (screenSize.width - buttonRight)
        .clamp(
          screenMargin,
          math.max(screenMargin, screenSize.width - menuWidth - screenMargin),
        )
        .toDouble();

    final requestedMaxHeight = widget.constraints?.maxHeight ?? double.infinity;

    final panelTop = (buttonPosition.dy - panelGap).clamp(
      mediaQuery.padding.top + screenMargin,
      screenSize.height - screenMargin,
    );

    // Extra headroom so the panel's boxShadow (offset + blur) doesn't get
    // clipped against the bottom of the screen.
    const shadowBottomSpace = 24.0;

    final availableHeight =
        screenSize.height -
        panelTop -
        mediaQuery.padding.bottom -
        widget.bottomReservedSpace -
        screenMargin -
        shadowBottomSpace;

    final safeAvailableHeight = availableHeight.clamp(0.0, double.infinity);
    final minimumHeight = safeAvailableHeight < 160.0
        ? safeAvailableHeight
        : 160.0;
    final menuMaxHeight = requestedMaxHeight.clamp(
      minimumHeight,
      safeAvailableHeight,
    );

    await widget.onBeforeOpen?.call();
    if (!mounted) return;

    setState(() => _isOpen = true);

    try {
      final selected = await showGeneralDialog<String>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        barrierColor: Colors.transparent,
        transitionDuration: const Duration(milliseconds: 240),
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(
                    dialogContext,
                    rootNavigator: true,
                  ).maybePop(),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: widget.blurSigma,
                          sigmaY: widget.blurSigma,
                        ),
                        child: const SizedBox.expand(),
                      ),
                      ColoredBox(color: widget.barrierColor),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: panelTop,
                right: panelRight,
                width: menuWidth,
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: _MenuPanel(
                    header: widget.header,
                    closeIcon: widget.closeIcon,
                    maxHeight: menuMaxHeight,
                    entries: widget.itemBuilder(dialogContext),
                  ),
                ),
              ),
            ],
          );
        },
        transitionBuilder:
            (dialogContext, animation, secondaryAnimation, child) {
              final curve = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );

              return FadeTransition(
                opacity: curve,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.92, end: 1).animate(curve),
                  alignment: Alignment.topRight,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.04, -0.025),
                      end: Offset.zero,
                    ).animate(curve),
                    child: child,
                  ),
                ),
              );
            },
      );

      if (selected != null && mounted) {
        widget.onSelected(selected);
      }
    } finally {
      if (mounted) setState(() => _isOpen = false);
      widget.onClosed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final rightPadding = math.max(
      _compactRightPadding,
      (screenWidth - widget.contentMaxWidth) / 2 - _appBarActionsEndPadding,
    );

    return Padding(
      padding: EdgeInsets.only(right: rightPadding),
      child: Semantics(
        button: true,
        label: MaterialLocalizations.of(context).showMenuTooltip,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isOpen
                ? colorScheme.primaryContainer.withValues(alpha: 0.72)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            key: _buttonKey,
            tooltip: MaterialLocalizations.of(context).showMenuTooltip,
            iconSize: widget.iconSize,
            padding: const EdgeInsets.all(8),
            onPressed: _openMenu,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: Icon(
                _isOpen ? widget.closeIcon : widget.menuIcon,
                key: ValueKey(_isOpen),
                size: widget.iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuPanel extends StatelessWidget {
  const _MenuPanel({
    required this.header,
    required this.closeIcon,
    required this.maxHeight,
    required this.entries,
  });

  final Widget header;
  final IconData closeIcon;
  final double maxHeight;
  final List<PopupMenuEntry<String>> entries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    const radius = BorderRadius.all(Radius.circular(24));
    final backgroundColor = theme.popupMenuTheme.color ?? colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: Container(
        key: const Key('app-menu-panel'),
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.98),
          borderRadius: radius,
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.13),
              blurRadius: 32,
              spreadRadius: -8,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MenuPanelHeader(
                  header: header,
                  closeIcon: closeIcon,
                  onClose: () =>
                      Navigator.of(context, rootNavigator: true).maybePop(),
                ),
                Flexible(
                  child: Semantics(
                    role: SemanticsRole.menu,
                    scopesRoute: true,
                    namesRoute: true,
                    explicitChildNodes: true,
                    label: MaterialLocalizations.of(context).showMenuTooltip,
                    // `shrinkWrap: true` so the panel hugs a short entry
                    // list's actual height instead of a plain
                    // `SingleChildScrollView` (which always fills the
                    // height `Flexible` allocates to it, leaving a blank
                    // gap below the last entry) — it still clamps to and
                    // scrolls within that allocation once entries overflow
                    // it.
                    child: ListView(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                      children: [
                        Theme(
                          data: theme.copyWith(
                            popupMenuTheme: theme.popupMenuTheme.copyWith(
                              textStyle: theme.textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            dividerTheme: DividerThemeData(
                              color: colorScheme.outline.withValues(alpha: 0.5),
                              thickness: 1,
                            ),
                            splashColor: colorScheme.primary.withValues(
                              alpha: 0.10,
                            ),
                            highlightColor: colorScheme.primary.withValues(
                              alpha: 0.06,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: entries,
                          ),
                        ),
                      ],
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

class _MenuPanelHeader extends StatelessWidget {
  const _MenuPanelHeader({
    required this.header,
    required this.closeIcon,
    required this.onClose,
  });

  final Widget header;
  final IconData closeIcon;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final panelColor =
        theme.dialogTheme.backgroundColor ?? colorScheme.surfaceContainerLow;
    final barBg = Color.alphaBlend(
      colorScheme.primary.withValues(alpha: 0.06),
      panelColor,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.55),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: header),
          _CloseButton(icon: closeIcon, onPressed: onClose),
        ],
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 23, color: colorScheme.onSurface),
    );
  }
}
