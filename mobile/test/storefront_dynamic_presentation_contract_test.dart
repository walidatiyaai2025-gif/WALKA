import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production media contract contains no compiled product or category identities', () {
    final String media = File(
      'lib/features/media/domain/walka_remote_media.dart',
    ).readAsStringSync();
    final String repository = File(
      'lib/features/media/data/walka_remote_media_repository.dart',
    ).readAsStringSync();

    for (final String forbidden in <String>[
      'walkaSupportedProductVariants',
      'drawer-organizer:white',
      'drawer-organizer:gray',
      'lunch-box:blue',
      'lunch-box:pink',
      'lunch-box:green',
      'category:drawer-organization',
      'category:lunch',
    ]) {
      expect(media, isNot(contains(forbidden)), reason: forbidden);
      expect(repository, isNot(contains(forbidden)), reason: forbidden);
    }
    expect(repository, isNot(contains('_bundledProducts')));
    expect(media, contains('WalkaRemoteMediaSource { remote, cache, unavailable }'));
  });

  test('generic storefront resolves dashboard content and verified media', () {
    final String storefront = File(
      'lib/features/storefront/dynamic_catalog_v140.dart',
    ).readAsStringSync();

    expect(storefront, contains('WalkaContentScope.maybeOf'));
    expect(storefront, contains('content.storefrontCopy'));
    expect(storefront, contains('content.search'));
    expect(storefront, contains('content.categories'));
    expect(storefront, contains('content.homeFeatured'));
    expect(storefront, contains('content.homeBanner'));
    expect(storefront, contains('WalkaResolvedProductRemoteMedia'));
    expect(storefront, contains("slotKey: 'category:\${category.id}'"));

    for (final String forbidden in <String>[
      'DASHBOARD CATALOG',
      'Products managed in one place',
      'Browse all products',
      'Created, ordered and published from the WALKA Dashboard.',
      'No Dashboard products match this search.',
      "const Text('Colors'",
      "const Text('Features'",
      "const Text('Details'",
      'Icons.inventory_2_outlined',
    ]) {
      expect(storefront, isNot(contains(forbidden)), reason: forbidden);
    }
  });

  test('storefront copy has remote API and LKG cache wiring', () {
    final String api = File('lib/core/api/walka_api_client.dart').readAsStringSync();
    final String state = File('lib/features/content/content_state.dart').readAsStringSync();
    final String main = File('lib/main.dart').readAsStringSync();

    expect(api, contains('/api/v1/content/storefront'));
    expect(state, contains('WalkaStorefrontCopyRepository'));
    expect(state, contains('WalkaStorefrontCopySnapshot'));
    expect(main, contains('SharedPreferencesWalkaStorefrontCopyCache'));
    expect(main, contains('apiClient?.fetchStorefrontCopy'));
  });
}
