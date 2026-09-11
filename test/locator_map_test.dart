import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

Path _box(double inset) =>
    Path()..addRect(Rect.fromLTRB(inset, inset, 100 - inset, 100 - inset));

List<LocatorMapLevel> _levels() => [
  LocatorMapLevel(
    id: 'country',
    label: 'Country',
    semanticsLabel: 'Country map',
    contourPath: _box(0),
    viewBounds: const Rect.fromLTWH(0, 0, 100, 100),
    marker: const Offset(50, 50),
    highlightPath: _box(20),
  ),
  LocatorMapLevel(
    id: 'region',
    label: 'Region',
    semanticsLabel: 'Region map',
    contourPath: _box(20),
    viewBounds: const Rect.fromLTWH(20, 20, 60, 60),
    marker: const Offset(50, 50),
    highlightPath: _box(35),
  ),
  LocatorMapLevel(
    id: 'locality',
    label: 'Locality',
    semanticsLabel: 'Locality map',
    contourPath: _box(35),
    viewBounds: const Rect.fromLTWH(35, 35, 30, 30),
    highlightPath: _box(49.95),
    highlightArea: .01,
  ),
];

void main() {
  testWidgets('narrow layout gives the overview a full row', (tester) async {
    tester.view.physicalSize = const Size(390, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HierarchicalLocatorMaps(levels: _levels())),
      ),
    );

    final country = tester.getRect(
      find.byKey(const ValueKey('locator-map-country')),
    );
    final region = tester.getRect(
      find.byKey(const ValueKey('locator-map-region')),
    );
    final locality = tester.getRect(
      find.byKey(const ValueKey('locator-map-locality')),
    );
    expect(country.width, closeTo(390, .1));
    expect(region.top, greaterThan(country.bottom));
    expect(region.top, closeTo(locality.top, .1));
    expect(region.width, closeTo(locality.width, .1));
  });

  testWidgets('maps expose labels, zoom affordances, and image semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HierarchicalLocatorMaps(levels: _levels())),
      ),
    );

    expect(find.text('Country'), findsOneWidget);
    expect(find.byIcon(Icons.zoom_in_rounded), findsNWidgets(3));
    expect(find.byType(InteractiveViewer), findsNWidgets(3));
    expect(find.bySemanticsLabel('Country map'), findsOneWidget);
    semantics.dispose();
  });

  for (final brightness in Brightness.values) {
    testWidgets('map style follows ${brightness.name} color scheme', (
      tester,
    ) async {
      final scheme = ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: brightness,
      );
      final theme = ThemeData(colorScheme: scheme);
      final style = LocatorMapStyle.fromTheme(theme);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: HierarchicalLocatorMaps(levels: _levels())),
        ),
      );

      final surface = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('locator-map-country')),
      );
      final decoration = surface.decoration as BoxDecoration;
      expect(decoration.color, style.canvas);
      expect(decoration.borderRadius, BorderRadius.circular(14));
      expect(decoration.boxShadow!.single.blurRadius, lessThanOrEqualTo(8));
    });
  }

  testWidgets('marker is optional and tiny highlights can be suppressed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: HierarchicalLocatorMaps(levels: _levels())),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('locator-map-locality')), findsOneWidget);
  });

  testWidgets('supports intrinsic-height comparison layouts', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: HierarchicalLocatorMaps(levels: _levels())),
                const VerticalDivider(),
                Expanded(child: HierarchicalLocatorMaps(levels: _levels())),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(InteractiveViewer), findsNWidgets(6));
  });
}
