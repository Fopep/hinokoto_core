import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  Future<void> pumpDialog(WidgetTester tester, AppDialog dialog) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () =>
                    showAppDialog<void>(context: context, builder: (_) => dialog),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('showBackButtonがfalseなら戻るボタンは出ない', (tester) async {
    await pumpDialog(tester, const AppDialog(title: Text('Title')));

    expect(find.byTooltip('Back'), findsNothing);
    expect(find.text('Title'), findsOneWidget);
  });

  testWidgets('showBackButtonがtrueなら戻るボタンが出てonBackが呼ばれる', (tester) async {
    var backTapped = false;
    await pumpDialog(
      tester,
      AppDialog(
        title: const Text('Title'),
        showBackButton: true,
        onBack: () => backTapped = true,
      ),
    );

    expect(find.byTooltip('Back'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    expect(backTapped, isTrue);
  });

  testWidgets('actionsを渡すと区切り線付きのアクションバーが表示される', (tester) async {
    await pumpDialog(
      tester,
      const AppDialog(
        title: Text('Title'),
        actions: [Text('Action1'), Text('Action2')],
      ),
    );

    expect(find.text('Action1'), findsOneWidget);
    expect(find.text('Action2'), findsOneWidget);
  });

  testWidgets('閉じるボタンでダイアログが閉じる', (tester) async {
    await pumpDialog(tester, const AppDialog(title: Text('Title')));

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.text('Title'), findsNothing);
  });
}
