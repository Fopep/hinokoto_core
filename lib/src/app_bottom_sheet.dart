import 'dart:ui';

import 'package:flutter/material.dart';

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
