import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_empty_state.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_filters.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_header.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_sort_row.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_favorites_trust.dart';
import 'package:walka/features/storefront/presentation/widgets/favorites/walka_saved_drawer_card.dart';

void main() {
  Widget host(Widget child, {double width = 320, double textScale = 1.3}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 800),
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );
  }

  testWidgets('header preserves count and edit callback',
      (WidgetTester tester) async {
    var edits = 0;
    await tester.pumpWidget(
      host(
        Column(
          children: <Widget>[
            const WalkaFavoritesTopBar(),
            WalkaFavoritesHeader(
              count: 2,
              editMode: false,
              onEdit: () => edits += 1,
            ),
          ],
        ),
      ),
    );
    expect(find.text('2 items saved'), findsOneWidget);
    await tester.tap(find.text('EDIT'));
    expect(edits, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filters preserve Drawer selection and disabled Lunch contract',
      (WidgetTester tester) async {
    var all = 0;
    var drawer = 0;
    await tester.pumpWidget(
      host(
        WalkaFavoritesFilters(
          count: 2,
          drawerSelected: false,
          onAll: () => all += 1,
          onDrawer: () => drawer += 1,
        ),
        width: 280,
      ),
    );

    final Finder drawerFilter = find.text('Drawer Organizers');
    await tester.ensureVisible(drawerFilter);
    await tester.pumpAndSettle();
    await tester.tap(drawerFilter);
    expect(drawer, 1);

    final Finder allFilter = find.text('All Favorites');
    await tester.ensureVisible(allFilter);
    await tester.pumpAndSettle();
    await tester.tap(allFilter);
    expect(all, 1);

    final Finder lunchLabel = find.text('Lunch Boxes');
    await tester.ensureVisible(lunchLabel);
    await tester.pumpAndSettle();
    final InkWell lunch = tester.widget<InkWell>(
      find.ancestor(
        of: lunchLabel,
        matching: find.byType(InkWell),
      ).first,
    );
    expect(lunch.onTap, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saved card preserves open remove and edit visuals',
      (WidgetTester tester) async {
    var opens = 0;
    var removes = 0;
    await tester.pumpWidget(
      host(
        WalkaSavedDrawerCard(
          gray: true,
          editMode: true,
          onOpen: () => opens += 1,
          onRemove: () => removes += 1,
        ),
        width: 300,
      ),
    );
    expect(find.text('Gray'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    await tester.tap(find.text('VIEW PRODUCT'));
    expect(opens, 1);
    await tester.tap(find.byKey(const ValueKey<String>('reference-remove-gray')));
    expect(removes, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty state and trust content remain truthful',
      (WidgetTester tester) async {
    var explores = 0;
    await tester.pumpWidget(
      host(
        Column(
          children: <Widget>[
            WalkaFavoritesEmptyState(onExplore: () => explores += 1),
            const SizedBox(height: 16),
            const WalkaFavoritesSortRow(),
            const SizedBox(height: 16),
            const WalkaFavoritesTrust(),
          ],
        ),
        width: 320,
      ),
    );
    expect(find.textContaining('Drawer Organizer variants'), findsOneWidget);
    expect(find.text('Official Amazon'), findsOneWidget);
    expect(find.text('Saved locally'), findsOneWidget);
    await tester.tap(find.text('CONTINUE SHOPPING'));
    expect(explores, 1);
    expect(tester.takeException(), isNull);
  });
}
