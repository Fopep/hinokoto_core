import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hinokoto_core/hinokoto_core.dart';

void main() {
  testWidgets(
    'onOpen fires immediately and onClose fires once the dialog is gone',
    (tester) async {
      var opens = 0;
      var closes = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showAppDialog<void>(
                    context: context,
                    builder: (_) => const AppDialog(title: Text('Title')),
                    onOpen: () => opens++,
                    onClose: () => closes++,
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      // onOpen fires synchronously, before the route animation even starts.
      expect(opens, 1);
      expect(closes, 0);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(closes, 1);
    },
  );

  testWidgets(
    'bottomReservedSpace pads the dialog to clear reserved space beyond the base inset',
    (tester) async {
      final reserved = ValueNotifier<double>(200);
      addTearDown(reserved.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showAppDialog<void>(
                    context: context,
                    builder: (_) => const AppDialog(title: Text('Title')),
                    bottomReservedSpace: () => reserved.value,
                    bottomReservedSpaceListenable: reserved,
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

      final padding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(AppDialog),
              matching: find.byType(Padding),
            )
            .first,
      );
      // Base inset bottom is 24; with 200 of reserved space and no safe-area
      // inset in this test harness, the full remainder should be added.
      expect(padding.padding.resolve(TextDirection.ltr).bottom, 200);

      reserved.value = 0;
      await tester.pumpAndSettle();

      final updatedPadding = tester.widget<Padding>(
        find
            .ancestor(
              of: find.byType(AppDialog),
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(updatedPadding.padding.resolve(TextDirection.ltr).bottom, 24);
    },
  );
}
