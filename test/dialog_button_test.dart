import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  Future<void> pump(WidgetTester tester, DialogButtonType type) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DialogButton('Label', type: type, onPressed: () {}),
        ),
      ),
    );
  }

  testWidgets('normalタイプはprimaryカラーの文字色になる', (tester) async {
    await pump(tester, DialogButtonType.normal);

    final scheme = Theme.of(
      tester.element(find.byType(DialogButton)),
    ).colorScheme;
    final style = tester.widget<TextButton>(find.byType(TextButton)).style!;

    expect(style.foregroundColor?.resolve({}), scheme.primary);
    expect(style.backgroundColor?.resolve({}), isNull);
  });

  testWidgets('inverseタイプはprimary背景・onPrimary文字になる', (tester) async {
    await pump(tester, DialogButtonType.inverse);

    final scheme = Theme.of(
      tester.element(find.byType(DialogButton)),
    ).colorScheme;
    final style = tester.widget<TextButton>(find.byType(TextButton)).style!;

    expect(style.backgroundColor?.resolve({}), scheme.primary);
    expect(style.foregroundColor?.resolve({}), scheme.onPrimary);
  });

  testWidgets('destructiveタイプはerror背景・onError文字になる', (tester) async {
    await pump(tester, DialogButtonType.destructive);

    final scheme = Theme.of(
      tester.element(find.byType(DialogButton)),
    ).colorScheme;
    final style = tester.widget<TextButton>(find.byType(TextButton)).style!;

    expect(style.backgroundColor?.resolve({}), scheme.error);
    expect(style.foregroundColor?.resolve({}), scheme.onError);
  });

  testWidgets('onPressed未指定ならタップでダイアログを閉じる', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) =>
                      const AlertDialog(actions: [DialogButton('Close')]),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });
}
