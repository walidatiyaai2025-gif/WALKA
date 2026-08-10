import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/feedback/walka_empty_state.dart';

void main() {
  Widget app(Widget child, {double width = 360, double textScale = 1}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 640),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );
  }

  testWidgets('renders default visual and no action by default',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        const WalkaEmptyState(
          title: 'Nothing saved yet',
          body: 'Saved items will appear here.',
        ),
      ),
    );

    expect(find.text('Nothing saved yet'), findsOneWidget);
    expect(find.text('Saved items will appear here.'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('walka-empty-state-default-visual')),
      findsOneWidget,
    );
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('supports caller visual and optional action callback',
      (WidgetTester tester) async {
    var taps = 0;

    await tester.pumpWidget(
      app(
        WalkaEmptyState(
          title: 'No results',
          body: 'Try a different search.',
          visual: const Icon(Icons.search_off_rounded, key: ValueKey('custom')),
          actionLabel: 'CLEAR SEARCH',
          onAction: () => taps += 1,
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('custom')), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('walka-empty-state-default-visual')),
      findsNothing,
    );
    expect(find.text('CLEAR SEARCH'), findsOneWidget);

    await tester.tap(find.text('CLEAR SEARCH'));
    await tester.pump();
    expect(taps, 1);
  });

  testWidgets('marks the title as an accessibility heading',
      (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        app(
          const WalkaEmptyState(
            title: 'Empty heading',
            body: 'Supporting copy.',
          ),
        ),
      );

      final SemanticsNode node = tester.getSemantics(find.text('Empty heading'));
      expect(node.flagsCollection.isHeader, isTrue);
    } finally {
      handle.dispose();
    }
  });

  testWidgets('stays overflow-free at compact width and 1.3x text scale',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        SingleChildScrollView(
          child: WalkaEmptyState(
            title: 'Your collection is ready when you are',
            body:
                'Long supporting content wraps safely without inventing product or account information.',
            actionLabel: 'EXPLORE COLLECTION',
            onAction: () {},
          ),
        ),
        width: 280,
        textScale: 1.3,
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('EXPLORE COLLECTION'), findsOneWidget);
  });
}
