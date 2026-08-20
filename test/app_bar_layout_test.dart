import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
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
