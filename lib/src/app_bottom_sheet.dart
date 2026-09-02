import 'dart:ui';

import 'package:flutter/material.dart';

import 'ad_layout.dart';

const _appBottomSheetBarrierColor = Color(0x7A000000);
const _appBottomSheetBlurSigma = 4.0;

Future<T?> showAppModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useRootNavigator = false,
}) {
  final navigator = Navigator.of(context, rootNavigator: useRootNavigator);
  final localizations = MaterialLocalizations.of(context);

  return navigator.push(
    _BlurredModalBottomSheetRoute<T>(
      builder: builder,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
      isScrollControlled: isScrollControlled,
      barrierLabel: localizations.scrimLabel,
      barrierOnTapHint: localizations.scrimOnTapHint(
        localizations.bottomSheetLabel,
      ),
      modalBarrierColor: _appBottomSheetBarrierColor,
    ),
  );
}

/// A modal picker sheet (search/selection lists) with the shared blurred
/// barrier, a top-rounded, ad-banner-aware surface, and a fractional height.
/// [builder] supplies just the sheet's own content (a header row, search
/// field, and results list) — the surrounding chrome is handled here so
/// every picker across apps gets the same barrier, corner radius, and
/// bottom inset.
Future<T?> showHinokotoPickerSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  double heightFactor = 0.92,
  double cornerRadius = 28,
  Key? surfaceKey,
}) {
  return showAppModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: adBannerReservedHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(cornerRadius),
          ),
          child: Material(
            key: surfaceKey,
            color:
                Theme.of(context).bottomSheetTheme.backgroundColor ??
                Theme.of(context).colorScheme.surface,
            child: FractionallySizedBox(
              heightFactor: heightFactor,
              child: builder(context),
            ),
          ),
        ),
      ),
    ),
  );
}

class _BlurredModalBottomSheetRoute<T> extends ModalBottomSheetRoute<T> {
  _BlurredModalBottomSheetRoute({
    required super.builder,
    required super.capturedThemes,
    required super.isScrollControlled,
    required super.barrierLabel,
    required super.barrierOnTapHint,
    required super.modalBarrierColor,
  });

  @override
  Widget buildModalBarrier() => BackdropFilter(
    filter: ImageFilter.blur(
      sigmaX: _appBottomSheetBlurSigma,
      sigmaY: _appBottomSheetBlurSigma,
    ),
    child: super.buildModalBarrier(),
  );
}
