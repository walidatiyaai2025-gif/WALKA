import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/commerce/amazon_purchase.dart';
import 'package:walka/features/favorites/favorites_state.dart';

void main() {
  test('QA-011 navigation smoke wiring covers primary and secondary routes', () {
    final String shell = File('lib/features/storefront/storefront_v102.dart')
        .readAsStringSync();
    final String account =
        File('lib/features/storefront/account_about_reference_v131.dart')
            .readAsStringSync();
    final String favorites =
        File('lib/features/storefront/favorites_reference_v131.dart')
            .readAsStringSync();

    for (final String destination in <String>[
      'WalkaHomePremiumV130',
      'WalkaSearchPremiumV130',
      'WalkaCategoriesPremiumV130',
      'WalkaFavoritesReferenceV131',
      'WalkaAccountReferenceV131',
    ]) {
      expect(shell, contains(destination), reason: 'Missing shell route $destination');
    }
    expect(account, contains("title: 'Our Story'"));
    expect(account, contains('WalkaAboutReferenceV131'));
    expect(favorites, contains('WalkaDrawerProductDetailV100'));
  });

  test('QA-012 production PDP preserves Product Master truth and exclusions', () {
    final String master = File('../docs/PRODUCT_MASTER.md').readAsStringSync();
    final String pdp =
        File('lib/features/products/product_experience_v111.dart').readAsStringSync();

    for (final String approved in <String>[
      '1200 ml',
      '4 compartments',
      'SUS304',
      'Best for dry & semi-wet foods',
      'Not intended for liquids',
      'Carry upright',
      '8 compartments',
      '22.4 in',
      'Non-slip',
    ]) {
      expect(master, contains(approved), reason: 'Master missing $approved');
      expect(pdp, contains(approved), reason: 'PDP missing $approved');
    }

    expect(pdp.toLowerCase(), isNot(contains('leakproof')));
    expect(pdp.toLowerCase(), isNot(contains('dishwasher safe · lid')));
  });

  test('QA-013 Favorites controller persists White/Gray and reloads state',
      () async {
    final _MemoryFavoritesStore store = _MemoryFavoritesStore();
    final WalkaFavoritesController first = WalkaFavoritesController(store);
    await first.load();

    expect(await first.toggleDrawer(gray: false), isTrue);
    expect(await first.toggleDrawer(gray: true), isTrue);
    expect(first.savedDrawerVariants, <bool>[false, true]);
    first.dispose();

    final WalkaFavoritesController reloaded = WalkaFavoritesController(store);
    await reloaded.load();
    expect(reloaded.isDrawerFavorite(gray: false), isTrue);
    expect(reloaded.isDrawerFavorite(gray: true), isTrue);
    expect(await reloaded.removeDrawer(gray: false), isTrue);
    expect(store.ids, <String>{WalkaFavoritesController.drawerGrayId});
    reloaded.dispose();
  });

  test('QA-014 Amazon boundary uses official external listing URLs only', () {
    final Map<String, Uri> uris = <String, Uri>{
      'drawer-white': amazonDrawerOrganizerUri(gray: false),
      'drawer-gray': amazonDrawerOrganizerUri(gray: true),
      'lunch-blue': amazonLunchBoxUri(WalkaAmazonLunchVariant.blue),
      'lunch-pink': amazonLunchBoxUri(WalkaAmazonLunchVariant.pink),
      'lunch-green': amazonLunchBoxUri(WalkaAmazonLunchVariant.green),
    };

    final Set<String> paths = <String>{};
    for (final MapEntry<String, Uri> entry in uris.entries) {
      expect(entry.value.scheme, 'https', reason: entry.key);
      expect(entry.value.host, 'www.amazon.com', reason: entry.key);
      expect(entry.value.path, startsWith('/dp/'), reason: entry.key);
      paths.add(entry.value.path);
    }
    expect(paths.length, 5);

    final String purchaseSource =
        File('lib/features/commerce/amazon_purchase.dart').readAsStringSync();
    expect(purchaseSource, contains('LaunchMode.externalApplication'));
    expect(purchaseSource.toLowerCase(), isNot(contains('checkout')));
    expect(purchaseSource.toLowerCase(), isNot(contains('payment')));
  });
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  Set<String> ids = <String>{};

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    ids = Set<String>.from(favoriteIds);
  }
}
