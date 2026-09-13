import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  for (final brightness in Brightness.values) {
    testWidgets(
      'ranking surface uses neutral accessible chrome in ${brightness.name}',
      (tester) async {
        final scheme = ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        );
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(colorScheme: scheme),
            home: CustomScrollView(
              slivers: const [
                RankingHeaderSurface(
                  toolbarHeight: rankingHeaderBaseHeight,
                  child: Text('Filters'),
                ),
              ],
            ),
          ),
        );

        final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
        final border = appBar.shape! as Border;
        expect(appBar.backgroundColor, scheme.surfaceContainerLow);
        expect(appBar.foregroundColor, scheme.onSurface);
        expect(border.bottom.color, scheme.outlineVariant);
        expect(appBar.elevation, 0);
        expect(appBar.scrolledUnderElevation, 1);
        expect(appBar.forceElevated, isFalse);
        expect(appBar.surfaceTintColor, Colors.transparent);
      },
    );
  }

  testWidgets('ranking controls use compact explicit selected states', (
    tester,
  ) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Column(
              children: [
                RankingChipSelector<int>(
                  options: const [(0, 'First'), (1, 'Second')],
                  selected: selected,
                  onChanged: (value) => setState(() => selected = value),
                ),
                RankingSortButton(
                  tooltip: 'Reverse',
                  icon: Icons.swap_vert,
                  label: const Text('Highest'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(rankingControlHeight, 48);
    final chips = tester
        .widgetList<ChoiceChip>(find.byType(ChoiceChip))
        .toList();
    final scheme = Theme.of(
      tester.element(find.byType(ChoiceChip).first),
    ).colorScheme;
    expect(chips.first.selected, isTrue);
    expect(chips.first.selectedColor, scheme.primary);
    expect(chips.last.backgroundColor, scheme.surfaceContainerHighest);
    final sortButton = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(sortButton.style?.elevation?.resolve({}), 0);

    await tester.tap(find.text('Second'));
    await tester.pump();
    expect(
      tester.widget<ChoiceChip>(find.byType(ChoiceChip).last).selected,
      isTrue,
    );
  });

  testWidgets('long selected Latin chip labels are not clipped', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RankingChipSelector<int>(
            options: const [(0, 'Year-over-year change')],
            selected: 0,
            onChanged: (_) {},
          ),
        ),
      ),
    );

    final label = find.descendant(
      of: find.byType(ChoiceChip),
      matching: find.byType(RichText),
    );
    final paragraph = tester.renderObject<RenderParagraph>(label);
    expect(
      paragraph.size.width,
      greaterThanOrEqualTo(
        paragraph.getMaxIntrinsicWidth(double.infinity) - 0.01,
      ),
    );
  });
}
