import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets('chrome is coherent and accessible in ${brightness.name}', (
      tester,
    ) async {
      final scheme = ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: brightness,
      );
      final theme = ThemeData(colorScheme: scheme);
      final style = AppChromeStyle.fromTheme(theme);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            appBar: AppChromeBar(child: AppBar(title: const Text('Title'))),
            bottomNavigationBar: AppBottomNavigationFrame(
              child: NavigationBar(
                destinations: const [
                  NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                  NavigationDestination(
                    icon: Icon(Icons.settings),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final decorations = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .map((widget) => widget.decoration)
          .whereType<BoxDecoration>();
      final top = decorations.firstWhere(
        (decoration) =>
            decoration.border is Border &&
            (decoration.border! as Border).bottom.style != BorderStyle.none,
      );
      final bottom = decorations.firstWhere(
        (decoration) =>
            decoration.border is Border &&
            (decoration.border! as Border).top.style != BorderStyle.none,
      );
      final navigationTheme = tester
          .widget<NavigationBarTheme>(find.byType(NavigationBarTheme).first)
          .data;

      expect(top.color, style.background);
      expect(bottom.color, style.background);
      expect(top.boxShadow!.single.offset.dy, greaterThan(0));
      expect(bottom.boxShadow!.single.offset.dy, lessThan(0));
      expect(navigationTheme.indicatorColor, style.indicator);
      expect(
        navigationTheme.iconTheme!.resolve({WidgetState.selected})!.color,
        style.accent,
      );
      expect(_contrast(style.foreground, style.background), greaterThan(4.5));
      expect(
        _contrast(style.mutedForeground, style.background),
        greaterThan(4.5),
      );
    });
  }

  testWidgets('sliver chrome remains pinned at the app-bar extent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              AppChromeSliverBar(
                child: AppBar(title: const Text('Sliver title')),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 1000)),
            ],
          ),
        ),
      ),
    );

    final header = tester.widget<SliverPersistentHeader>(
      find.byType(SliverPersistentHeader),
    );
    expect(header.pinned, isTrue);
    expect(find.text('Sliver title'), findsOneWidget);
  });

  testWidgets('generic bottom frame supports non-navigation action bars', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomBarFrame(
            child: Row(
              children: [
                IconButton(
                  key: const Key('play-action'),
                  onPressed: null,
                  icon: const Icon(Icons.play_arrow),
                ),
                const Text('Playback controls'),
              ],
            ),
          ),
        ),
      ),
    );

    final frame = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.byKey(const Key('play-action')),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = frame.decoration as BoxDecoration;
    final border = decoration.border! as Border;
    expect(border.top.style, BorderStyle.solid);
    expect(decoration.boxShadow!.single.offset.dy, lessThan(0));
    expect(find.text('Playback controls'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBottomBarFrame),
        matching: find.byType(NavigationBarTheme),
      ),
      findsNothing,
    );
  });

  for (final brightness in Brightness.values) {
    testWidgets(
      'bottom actions expose a restrained hierarchy in ${brightness.name}',
      (tester) async {
        final theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: brightness,
          ),
        );
        Widget buildButton(AppBottomActionEmphasis emphasis) =>
            AppBottomActionButton(
              buttonKey: ValueKey(emphasis),
              icon: const Icon(Icons.play_arrow),
              tooltip: emphasis.name,
              emphasis: emphasis,
              onPressed: () {},
            );

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Row(
                children: [
                  buildButton(AppBottomActionEmphasis.standard),
                  buildButton(AppBottomActionEmphasis.selected),
                  buildButton(AppBottomActionEmphasis.primary),
                ],
              ),
            ),
          ),
        );

        final scheme = theme.colorScheme;
        ButtonStyle styleOf(AppBottomActionEmphasis emphasis) =>
            tester.widget<IconButton>(find.byKey(ValueKey(emphasis))).style!;
        expect(
          styleOf(
            AppBottomActionEmphasis.standard,
          ).backgroundColor!.resolve({}),
          scheme.surfaceContainerHighest,
        );
        expect(
          styleOf(
            AppBottomActionEmphasis.selected,
          ).backgroundColor!.resolve({}),
          scheme.primaryContainer,
        );
        expect(
          styleOf(AppBottomActionEmphasis.primary).backgroundColor!.resolve({}),
          scheme.primary,
        );
        expect(
          styleOf(AppBottomActionEmphasis.standard).fixedSize!.resolve({}),
          const Size.square(48),
        );
        expect(
          styleOf(AppBottomActionEmphasis.primary).fixedSize!.resolve({}),
          const Size.square(64),
        );
        expect(
          styleOf(AppBottomActionEmphasis.primary).elevation!.resolve({}),
          2,
        );
      },
    );
  }

  testWidgets(
    'bottom action semantics trigger once and expose disabled state',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                AppBottomActionButton(
                  icon: const Icon(Icons.play_arrow),
                  tooltip: 'Play',
                  onPressed: () => calls++,
                ),
                const AppBottomActionButton(
                  icon: Icon(Icons.refresh),
                  tooltip: 'Unavailable',
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      );

      final play = tester.getSemantics(find.bySemanticsLabel('Play'));
      expect(play.flagsCollection.isButton, isTrue);
      expect(play.flagsCollection.isEnabled.toBoolOrNull(), isTrue);
      play.owner!.performAction(play.id, SemanticsAction.tap);
      await tester.pump();
      expect(calls, 1);
      final unavailable = tester.getSemantics(
        find.bySemanticsLabel('Unavailable'),
      );
      expect(unavailable.flagsCollection.isEnabled.toBoolOrNull(), isFalse);
      semantics.dispose();
    },
  );
}

double _contrast(Color foreground, Color background) {
  final a = foreground.computeLuminance();
  final b = background.computeLuminance();
  return ((a > b ? a : b) + .05) / ((a > b ? b : a) + .05);
}
