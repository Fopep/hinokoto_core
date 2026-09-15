import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'detail heading and tabs form a hierarchy in ${brightness.name}',
      (tester) async {
        final scheme = ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: brightness,
        );
        final theme = ThemeData(colorScheme: scheme);
        final style = DetailHeaderStyle.fromTheme(theme);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: DefaultTabController(
              length: 2,
              child: Scaffold(
                body: Column(
                  children: const [
                    DetailHeadingBar(title: 'Shinjuku', subtitle: 'Tokyo'),
                    DetailTabBar(
                      tabs: [
                        Tab(text: 'Data'),
                        Tab(text: 'Nearby'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        final heading = tester.widget<DetailHeadingBar>(
          find.byType(DetailHeadingBar),
        );
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        final tabBar = tester.widget<TabBar>(find.byType(TabBar));
        expect(heading.preferredSize.height, 76);
        expect(appBar.backgroundColor, Colors.transparent);
        expect(appBar.foregroundColor, style.foreground);
        expect(tabBar.labelColor, style.tabSelected);
        expect(tabBar.unselectedLabelColor, style.tabUnselected);
        expect(tabBar.dividerColor, Colors.transparent);
        expect(
          style.backgroundStart,
          Color.alphaBlend(
            scheme.primary.withValues(
              alpha: brightness == Brightness.dark ? .035 : .018,
            ),
            scheme.surfaceContainerLow,
          ),
        );
        expect(
          style.backgroundEnd,
          Color.alphaBlend(
            scheme.primary.withValues(
              alpha: brightness == Brightness.dark ? .07 : .05,
            ),
            scheme.surfaceContainerLow,
          ),
        );
        expect(
          _contrast(style.foreground, style.backgroundStart),
          greaterThan(4.5),
        );
        expect(
          _contrast(style.foreground, style.backgroundEnd),
          greaterThan(4.5),
        );
      },
    );
  }

  testWidgets('detail heading surface accepts composite app content', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DetailHeadingSurface(
            child: Row(
              children: [Icon(Icons.compare_arrows), Text('Composite heading')],
            ),
          ),
        ),
      ),
    );

    final surface = tester.widget<DetailHeadingSurface>(
      find.byType(DetailHeadingSurface),
    );
    expect(surface.preferredSize.height, 76);
    expect(find.byIcon(Icons.compare_arrows), findsOneWidget);
    expect(find.text('Composite heading'), findsOneWidget);
  });

  testWidgets('DetailTabBar with isScrollable passes it through to TabBar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            body: DetailTabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Data'),
                Tab(text: 'Nearby'),
              ],
            ),
          ),
        ),
      ),
    );

    final tabBar = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabBar.isScrollable, isTrue);
    expect(tabBar.tabAlignment, TabAlignment.start);
  });

  testWidgets(
    'DetailTabBar with isScrollable does not overflow with many tabs',
    (tester) async {
      final tabs = List.generate(20, (index) => Tab(text: 'Tab number $index'));
      await tester.pumpWidget(
        MaterialApp(
          home: DefaultTabController(
            length: tabs.length,
            child: Scaffold(
              body: SizedBox(
                width: 300,
                child: DetailTabBar(isScrollable: true, tabs: tabs),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.isScrollable, isTrue);
    },
  );
}

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05);
}
