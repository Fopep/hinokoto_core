import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'ad_layout.dart';
import 'app_dialog.dart';

/// Shows the app's "about" dialog: logo, title, version, and a
/// "developed by" line, inside the shared [AppDialog] shell. Every caller
/// supplies its own already-localized strings and logo asset path, since
/// this package has no access to an app's own localizations.
Future<void> showHinokotoAboutDialog({
  required BuildContext context,
  required String title,
  required String appTitle,
  required String logoAssetPath,
  required String Function(String version) versionLabelBuilder,
  required String developedBy,
  double logoSize = 100,
  double maxWidth = 520,
}) async {
  final packageInfo = await PackageInfo.fromPlatform();
  if (!context.mounted) return;
  await showAppDialog<void>(
    context: context,
    bottomReservedSpace: () => (kIsWeb ? adBannerReservedHeight : 0) + 24,
    builder: (context) => AppDialog(
      title: Text(title),
      maxWidth: maxWidth,
      content: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                logoAssetPath,
                width: logoSize,
                height: logoSize,
                semanticsLabel: appTitle,
              ),
              const SizedBox(height: 20),
              Text(
                appTitle,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                versionLabelBuilder(packageInfo.version),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(developedBy, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ),
  );
}
