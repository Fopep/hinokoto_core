import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  Future<void> pump(
    WidgetTester tester, {
    required double width,
    required List<Widget> children,
    bool reverse = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: HorizontalScrollRow(reverse: reverse, children: children),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<Widget> wideChildren({int count = 10, double width = 80}) => [
    for (var i = 0; i < count; i++)
      SizedBox(width: width, height: 20, child: Text('$i')),
  ];

  testWidgets('収まる場合はスクロール不要でフェードも出ない', (tester) async {
    await pump(
      tester,
      width: 400,
      children: const [
        SizedBox(width: 50, height: 20),
        SizedBox(width: 50, height: 20),
      ],
    );

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    expect(position.maxScrollExtent, 0);
    expect(find.byType(ShaderMask), findsNothing);
  });

  testWidgets('溢れる場合はスクロール可能になりフェードが表示される', (tester) async {
    await pump(tester, width: 120, children: wideChildren());

    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    expect(position.maxScrollExtent, greaterThan(0));
    expect(find.byType(ShaderMask), findsOneWidget);
  });

  testWidgets('reverse:trueならSingleChildScrollViewにreverseが伝わる', (
    tester,
  ) async {
    await pump(tester, width: 120, reverse: true, children: wideChildren());

    final scrollable = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scrollable.reverse, isTrue);
    expect(scrollable.scrollDirection, Axis.horizontal);
  });

  testWidgets('spacingとmainAxisAlignmentがRowへ伝わる', (tester) async {
    await pump(
      tester,
      width: 400,
      children: const [
        SizedBox(width: 50, height: 20),
        SizedBox(width: 50, height: 20),
      ],
    );

    final row = tester.widget<Row>(find.byType(Row));
    expect(row.mainAxisAlignment, MainAxisAlignment.center);
    // spacing is rendered as a SizedBox between children (2 children -> 1 gap).
    expect(
      tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(Row),
              matching: find.byType(SizedBox),
            ),
          )
          .where((box) => box.width == 8)
          .length,
      1,
    );
  });
}
