import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  const options = [
    SelectorOption(value: 'a', label: 'Option A'),
    SelectorOption(value: 'b', label: 'Option B'),
  ];

  Future<void> pump(WidgetTester tester, ValueChanged<String> onChanged) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SelectorRow<String>(
            label: 'Label',
            value: 'a',
            options: options,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  testWidgets('現在値のラベルとチェックマークが表示される', (tester) async {
    await pump(tester, (_) {});

    expect(find.text('Option A'), findsOneWidget);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();

    // The sheet lists both options; the current value ('a') is checked.
    final tileFinder = find.widgetWithText(ListTile, 'Option A');
    final tile = tester.widget<ListTile>(tileFinder);
    expect(tile.trailing, isA<Icon>());

    final otherTile = tester.widget<ListTile>(
      find.widgetWithText(ListTile, 'Option B'),
    );
    expect(otherTile.trailing, isNull);
  });

  testWidgets('選択肢をタップするとonChangedが呼ばれてシートが閉じる', (tester) async {
    String? selected;
    await pump(tester, (value) => selected = value);

    await tester.tap(find.text('Option A'));
    await tester.pumpAndSettle();
    expect(find.text('Option B'), findsOneWidget);

    await tester.tap(find.text('Option B'));
    await tester.pumpAndSettle();

    expect(selected, 'b');
    expect(find.text('Option B'), findsNothing); // sheet closed
  });

  for (final brightness in Brightness.values) {
    testWidgets('色と形がテーマに追従する（${brightness.name}）', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(brightness),
          home: Scaffold(
            body: SelectorRow<String>(
              label: 'Label',
              value: 'a',
              options: options,
              onChanged: (_) {},
            ),
          ),
        ),
      );

      final context = tester.element(find.byType(SelectorRow<String>));
      final scheme = Theme.of(context).colorScheme;
      final button = tester.widget<OutlinedButton>(find.byType(OutlinedButton));

      expect(button.style?.foregroundColor?.resolve({}), scheme.onSurface);
      expect(
        button.style?.backgroundColor?.resolve({}),
        scheme.surfaceContainerLowest,
      );
      expect(button.style?.side?.resolve({})?.color, scheme.outline);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.arrow_drop_down)).color,
        scheme.primary,
      );
    });
  }
}
