import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/search/search_v7.dart';

void main() {
  test('search matches Lunch keywords and colors deterministically', () {
    final List<WalkaSearchProduct> bento = filterWalkaSearchProducts(
      query: 'bento',
    );
    expect(bento.length, 3);
    expect(
      bento.every(
        (product) => product.collection == WalkaSearchCollection.lunch,
      ),
      isTrue,
    );

    final List<WalkaSearchProduct> green = filterWalkaSearchProducts(
      query: 'green',
    );
    expect(green.single.id, WalkaSearchProductId.lunchGreen);
  });

  test('search collection and color filters can narrow to one variant', () {
    final List<WalkaSearchProduct> results = filterWalkaSearchProducts(
      query: '',
      collection: WalkaSearchCollection.drawer,
      colors: const <String>{'Gray'},
    );

    expect(results.length, 1);
    expect(results.single.id, WalkaSearchProductId.drawerGray);
  });

  test('search sorting supports stable alphabetical presentation', () {
    final List<WalkaSearchProduct> results = filterWalkaSearchProducts(
      query: '',
      sort: WalkaSearchSort.nameAsc,
    );

    expect(results.length, walkaSearchProducts.length);
    expect(
      results.first.title.compareTo(results.last.title) <= 0,
      isTrue,
    );
  });

  testWidgets('search screen renders discovery and live result states',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: buildWalkaTheme(),
        home: const Scaffold(body: WalkaSearchV7()),
      ),
    );
    await tester.pump();

    expect(find.text('SUGGESTED SEARCHES'), findsOneWidget);
    expect(find.text('All WALKA essentials'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'green');
    await tester.pump();

    expect(find.text('1 match'), findsOneWidget);
    expect(find.textContaining('1200 ml · Green'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
