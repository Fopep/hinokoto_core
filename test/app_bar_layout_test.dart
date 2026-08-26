import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  testWidgets('HinokotoAppBarはロゴをタイトルに、menuをactionsに配置する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: HinokotoAppBar(
            logo: const Text('Logo'),
            menu: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          ),
        ),
      ),
    );

    expect(find.text('Logo'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.centerTitle, isTrue);
  });

  testWidgets('HinokotoAppBarは下部コントロールバーと対になる下向きの影を持つ', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: HinokotoAppBar(
            logo: const Text('Logo'),
            menu: IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.byType(AppBar),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final shadow = decoration.boxShadow!.single;

    expect(shadow.offset, const Offset(0, 3));
    expect(shadow.blurRadius, 12);

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.elevation, 0);
    expect(appBar.scrolledUnderElevation, 0);
  });

  testWidgets('広い画面では戻るボタンをコンテンツ最大幅の左端に配置する', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: _TestPage()));

    final buttonLeft = tester.getTopLeft(find.byTooltip('Back')).dx;
    expect(buttonLeft, (1400 - appContentMaxWidth) / 2);
  });
}

class _TestPage extends StatelessWidget {
  const _TestPage();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leadingWidth: AppBackButton.leadingWidth(context),
      leading: const AppBackButton(),
    ),
  );
}
