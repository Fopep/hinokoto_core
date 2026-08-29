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

  testWidgets('HinokotoAppBarShadowは任意のAppBarに下向きの影を付ける', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: HinokotoAppBarShadow(
            child: AppBar(title: const Text('Plain')),
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
  });

  testWidgets('HinokotoAppBarShadowはshowShadow:falseで影を付けない', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: HinokotoAppBarShadow(
            showShadow: false,
            child: AppBar(title: const Text('Plain')),
          ),
        ),
      ),
    );

    expect(
      find
          .ancestor(
            of: find.byType(AppBar),
            matching: find.byType(DecoratedBox),
          )
          .evaluate(),
      isEmpty,
    );
  });

  testWidgets('HinokotoSliverAppBarShadowはpinnedなsliverとして影付きAppBarを表示する', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              HinokotoSliverAppBarShadow(
                child: AppBar(title: const Text('Sliver Title')),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 2000)),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Sliver Title'), findsOneWidget);

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
  });

  for (final brightness in Brightness.values) {
    testWidgets('HinokotoPinnedHeaderは${brightness.name}用の背景色と前景色を持つ', (
      tester,
    ) async {
      final theme = buildAppTheme(brightness);
      final scheme = theme.colorScheme;
      final expectedBackground = Color.alphaBlend(
        scheme.primary.withValues(
          alpha: brightness == Brightness.dark ? .12 : .10,
        ),
        brightness == Brightness.dark
            ? scheme.surfaceContainerHigh
            : scheme.surface,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          darkTheme: theme,
          themeMode: brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                HinokotoPinnedHeader(
                  key: const Key('pinned-heading'),
                  toolbarHeight: 72,
                  child: const Text('Heading'),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 2000)),
              ],
            ),
          ),
        ),
      );

      final sliverAppBar = tester.widget<SliverAppBar>(
        find.descendant(
          of: find.byKey(const Key('pinned-heading')),
          matching: find.byType(SliverAppBar),
        ),
      );
      expect(sliverAppBar.pinned, isTrue);
      expect(sliverAppBar.toolbarHeight, 72);
      expect(sliverAppBar.backgroundColor, expectedBackground);
      expect(sliverAppBar.foregroundColor, scheme.onSurface);
      expect(sliverAppBar.surfaceTintColor, scheme.surfaceTint);
      expect(find.text('Heading'), findsOneWidget);
    });
  }

  testWidgets('HinokotoPinnedHeaderは背景色と前景色を上書きできる', (tester) async {
    const background = Color(0xFF123456);
    const foreground = Color(0xFFFEDCBA);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              HinokotoPinnedHeader(
                backgroundColor: background,
                foregroundColor: foreground,
                child: const Text('Heading'),
              ),
            ],
          ),
        ),
      ),
    );

    final sliverAppBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(sliverAppBar.backgroundColor, background);
    expect(sliverAppBar.foregroundColor, foreground);
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
