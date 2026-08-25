import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  Future<void> pumpOpener(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showAppModalBottomSheet<String>(
                  context: context,
                  builder: (_) => const Text('Sheet content'),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('開くとbuilderの内容とぼかしのバリアが表示される', (tester) async {
    await pumpOpener(tester);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsOneWidget);
    expect(find.byType(BackdropFilter), findsWidgets);
  });

  testWidgets('バリアをタップすると閉じる', (tester) async {
    await pumpOpener(tester);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet content'), findsOneWidget);

    // Tap outside the sheet content to dismiss via the modal barrier.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('Sheet content'), findsNothing);
  });

  testWidgets('選んだ値がFutureとして返る', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showAppModalBottomSheet<String>(
                    context: context,
                    builder: (context) => ElevatedButton(
                      onPressed: () => Navigator.of(context).pop('picked'),
                      child: const Text('pick'),
                    ),
                  );
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();

    expect(result, 'picked');
  });
}
