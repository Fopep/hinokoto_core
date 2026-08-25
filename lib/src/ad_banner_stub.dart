import 'package:flutter/widgets.dart';

import 'ad_layout.dart';

class AdBannerSlot extends StatelessWidget {
  const AdBannerSlot({
    super.key,
    this.androidBannerId,
    this.iosBannerId,
    this.hideAdWidget = false,
  });

  /// Unused on this platform; kept so callers can pass the same arguments
  /// regardless of which platform selects this implementation.
  final String? androidBannerId;
  final String? iosBannerId;
  final bool hideAdWidget;

  @override
  Widget build(BuildContext context) =>
      const SizedBox(width: double.infinity, height: adBannerReservedHeight);
}
