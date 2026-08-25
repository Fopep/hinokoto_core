import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  testWidgets('ボタンを開くとヘッダーと項目を含むパネルが表示される', (tester) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              MenuWithPinnedClose(
                header: const Text('App Logo'),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'a', child: Text('Item A')),
                ],
                onSelected: (value) => selected = value,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();

    expect(find.text('App Logo'), findsOneWidget);
    expect(find.text('Item A'), findsOneWidget);

    await tester.tap(find.text('Item A'));
    await tester.pumpAndSettle();

    expect(selected, 'a');
  });

  testWidgets('閉じるボタンで選択せずにパネルを閉じられる', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              MenuWithPinnedClose(
                header: const Text('App Logo'),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'a', child: Text('Item A')),
                ],
                onSelected: (_) {},
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('app-menu-panel')),
        matching: find.byIcon(Icons.close_rounded),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Item A'), findsNothing);
  });
}
