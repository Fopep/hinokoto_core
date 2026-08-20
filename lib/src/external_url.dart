import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] externally, or shows a snackbar with [failureMessage] if the
/// platform can't launch it.
Future<void> openUrlWithFallbackSnackbar(
  BuildContext context,
  String url, {
  required String failureMessage,
}) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }
  messenger?.showSnackBar(SnackBar(content: Text(failureMessage)));
}
