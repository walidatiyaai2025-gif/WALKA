import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_empty_state.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_filters.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_header.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_sort_row.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_title.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_trust.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_saved_drawer_card.dart';

Widget app(Widget child, {double textScale = 1}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(width: 320, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('FAV-002 preserves header title count and edit contract',
      (WidgetTester tester) async {
    var edits = 0;
    await tester.pumpWidget(
      app(
        Column(
          children: <Widget>[
            const WalkaFavoritesHeader(),
            WalkaFavoritesTitle(
              count: 2,
              editMode: false,
              onEdit: () => edits += 1,
            ),
          ],
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('reference-favorites-topbar')),
      findsOneWidget,
    );
    expect(find.text('My Favorites'), findsOneWidget);
    expect(find.text('2 items saved'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('reference-favorites-edit')));
    expect(edits, 1);
  });

  testWidgets('FAV-003 preserves All/Drawer filter and disabled Lunch option',
      (WidgetTester tester) async {
    var drawerSelected = false;
    await tester.pumpWidget(
      app(
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return WalkaFavoritesFilters(
              count: 2,
              drawerSelected: drawerSelected,
              onAll: () => setState(() => drawerSelected = false),
              onDrawer: () => setState(() => drawerSelected = true),
            );
          },
        ),
      ),
    );

    expect(find.text('All Favorites'), findsOneWidget);
    expect(find.text('Drawer Organizers'), findsOneWidget);
    expect(find.text('Lunch Boxes'), findsOneWidget);
    final Finder drawerFilter = find.text('Drawer Organizers');
    await tester.ensureVisible(drawerFilter);
    await tester.pumpAndSettle();
    await tester.tap(drawerFilter);
    await tester.pump();
    expect(drawerSelected, isTrue);
  });

  testWidgets('FAV-004 preserves saved-variants sort presentation',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(const WalkaFavoritesSortRow()));
    expect(
      find.byKey(const ValueKey<String>('reference-favorites-sort')),
      findsOneWidget,
    );
    expect(find.text('Sort by:'), findsOneWidget);
    expect(find.text('Saved variants'), findsOneWidget);
    expect(find.byIcon(Icons.view_module_outlined), findsOneWidget);
  });

  testWidgets('FAV-005 saved card keeps open/remove behavior and edit icon',
      (WidgetTester tester) async {
    var opens = 0;
    var removes = 0;
    await tester.pumpWidget(
      app(
        WalkaSavedDrawerCard(
          gray: true,
          editMode: true,
          onOpen: () => opens += 1,
          onRemove: () => removes += 1,
        ),
      ),
    );

    expect(find.text('Gray'), findsOneWidget);
    expect(find.text('8 compartments · expands to 22.4 in'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('reference-remove-gray')));
    expect(removes, 1);
    await tester.tap(find.text('VIEW PRODUCT'));
    expect(opens, 1);
  });

  testWidgets('FAV-006 shared empty state preserves Continue Shopping action',
      (WidgetTester tester) async {
    var explores = 0;
    await tester.pumpWidget(
      app(WalkaFavoritesEmptyState(onExplore: () => explores += 1)),
    );

    expect(
      find.byKey(const ValueKey<String>('reference-favorites-empty')),
      findsOneWidget,
    );
    expect(find.text('Save your favorites'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('reference-favorites-explore')),
    );
    expect(explores, 1);
  });

  testWidgets('FAV-007 shared trust strip preserves truthful labels',
      (WidgetTester tester) async {
    await tester.pumpWidget(app(const WalkaFavoritesTrust()));
    expect(find.text('Saved locally'), findsOneWidget);
    expect(find.text('Verified details'), findsOneWidget);
    expect(find.text('Official Amazon'), findsOneWidget);
    expect(find.text('WALKA quality'), findsOneWidget);
  });

  testWidgets('FAV-008 extracted units remain safe at 320px and 1.3x text',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      app(
        Column(
          children: <Widget>[
            WalkaFavoritesTitle(count: 1, editMode: false, onEdit: () {}),
            const SizedBox(height: 12),
            WalkaFavoritesFilters(
              count: 1,
              drawerSelected: false,
              onAll: () {},
              onDrawer: () {},
            ),
            const SizedBox(height: 12),
            WalkaSavedDrawerCard(
              gray: false,
              editMode: false,
              onOpen: () {},
              onRemove: () {},
            ),
          ],
        ),
        textScale: 1.3,
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
