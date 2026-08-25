// Regenerates the AdSense block in a consuming app's `web/index.html` from
// its `app_settings.yaml`. Run from the consuming app's repository root:
//
//   dart run hinokoto_core:apply_web_ads [--check]
//
// `--check` reports whether `web/index.html` is up to date without writing
// anything (exit 1 if it would change, exit 0 if not) — useful as a CI guard
// against hand-edited drift.
import 'dart:io';

import 'package:hinokoto_core/web_ads_codegen.dart';
import 'package:yaml/yaml.dart';

void main(List<String> arguments) {
  final check = arguments.contains('--check');

  final settingsFile = File('app_settings.yaml');
  if (!settingsFile.existsSync()) {
    _fail('app_settings.yaml not found. Run this from the app repository root.');
  }
  final settings = loadYaml(settingsFile.readAsStringSync());
  if (settings is! YamlMap) {
    _fail('app_settings.yaml: expected a top-level mapping.');
  }

  final web = settings['web'];
  if (web is! YamlMap) {
    _fail('app_settings.yaml is missing the "web" section.');
  }

  final client = _require(web, 'adsense_client');
  final slot = _require(web, 'adsense_slot');
  final enabled = web['adsense_enabled'];
  if (enabled is! bool) {
    _fail('app_settings.yaml: web.adsense_enabled must be true or false, not a quoted string.');
  }

  final config = AdsenseConfig(client: client, slot: slot, enabled: enabled);
  try {
    validateAdsenseConfig(config);
  } on FormatException catch (error) {
    _fail('app_settings.yaml: ${error.message}');
  }

  const path = 'web/index.html';
  final indexFile = File(path);
  if (!indexFile.existsSync()) {
    _fail('$path not found.');
  }
  final current = indexFile.readAsStringSync();

  final String updated;
  try {
    updated = applyAdsenseBlock(indexHtml: current, config: config);
  } on FormatException catch (error) {
    _fail(error.message);
  }

  if (check) {
    if (updated == current) {
      stdout.writeln('$path is up to date.');
    } else {
      stderr.writeln(
        '$path is out of date with app_settings.yaml. Run `dart run hinokoto_core:apply_web_ads` to fix.',
      );
      exitCode = 1;
    }
    return;
  }

  indexFile.writeAsStringSync(updated);
  stdout.writeln('Applied app_settings.yaml AdSense config to $path.');
}

String _require(YamlMap map, String key) {
  final value = map[key];
  if (value == null || value.toString().trim().isEmpty) {
    _fail('app_settings.yaml is missing a value for "web.$key".');
  }
  return value.toString();
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
