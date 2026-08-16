import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/commerce/amazon_purchase.dart';
import 'package:walka/features/favorites/favorites_state.dart';

String _joinExistingSources(List<String> paths) => paths
    .map(File.new)
    .where((File file) => file.existsSync())
    .map((File file) => file.readAsStringSync())
    .join('\n');

void main() {
  test('QA-011 navigation smoke wiring covers dynamic catalog routes', () {
    final String shell = File('lib/features/storefront/storefront_v102.dart').readAsStringSync();
    final String account = _joinExistingSources(<String>[
      'lib/features/storefront/account_about_reference_v131.dart',
      'lib/features/storefront/presentation/widgets/account/walka_account_groups.dart',
    ]);

    for (final String destination in <String>[
      'WalkaHomePremiumV130',
      'WalkaSearchPremiumV130',
      'WalkaCategoriesPremiumV130',
      'WalkaDynamicFavoritesV140',
      'WalkaAccountReferenceV131',
    ]) {
      expect(shell, contains(destination), reason: 'Missing shell route $destination');
    }
    expect(account, contains("title: 'Our Story'"));
    expect(account, contains('WalkaAboutReferenceV131'));
    expect(shell, isNot(contains('WalkaFavoritesReferenceV131')));
  });

  test('QA-012 legacy visual PDP facts remain truthful while runtime catalog is dynamic', () {
    final String master = File('../docs/PRODUCT_MASTER.md').readAsStringSync();
    final String pdp = _joinExistingSources(<String>[
      'lib/features/products/product_experience_v111.dart',
      'lib/features/products/product_experience_v112.dart',
      'lib/features/products/presentation/walka_pdp_model.dart',
      'lib/features/products/presentation/widgets/walka_pdp_details.dart',
    ]);
    expect(master, contains('- Capacity: 1200 ml'));
    expect(master, contains('- Compartments: 8'));
    expect(pdp.toLowerCase(), isNot(contains('leakproof')));
    expect(pdp.toLowerCase(), isNot(contains('in-app checkout')));
  });

  test('QA-013 Favorites controller persists arbitrary variant IDs and reloads state', () async {
    final _MemoryFavoritesStore store = _MemoryFavoritesStore();
    final WalkaFavoritesController first = WalkaFavoritesController(store);
    await first.load();
    expect(await first.toggle('desk-kit:emerald'), isTrue);
    expect(await first.toggle('travel-mug:sand'), isTrue);
    first.dispose();

    final WalkaFavoritesController reloaded = WalkaFavoritesController(store);
    await reloaded.load();
    expect(reloaded.isFavorite('desk-kit:emerald'), isTrue);
    expect(reloaded.isFavorite('travel-mug:sand'), isTrue);
    expect(await reloaded.remove('desk-kit:emerald'), isTrue);
    expect(store.ids, <String>{'travel-mug:sand'});
    reloaded.dispose();
  });

  test('QA-014 Amazon boundary uses validated Dashboard URLs and external launcher only', () {
    final Map<String, Uri> uris = <String, Uri>{
      for (final String id in <String>[
        'drawer-organizer:white',
        'drawer-organizer:gray',
        'lunch-box:blue',
        'lunch-box:pink',
        'lunch-box:green',
      ])
        id: WalkaAmazonPurchaseRegistry.requireUriForVariant(id),
    };
    for (final MapEntry<String, Uri> entry in uris.entries) {
      expect(entry.value.scheme, 'https', reason: entry.key);
      expect(entry.value.host, 'www.amazon.com', reason: entry.key);
      expect(entry.value.path, startsWith('/dp/'), reason: entry.key);
    }
    final String purchaseSource = File('lib/features/commerce/amazon_purchase.dart').readAsStringSync();
    expect(purchaseSource, contains('LaunchMode.externalApplication'));
    expect(purchaseSource, contains('No validated Dashboard purchase URL'));
    expect(RegExp(r'B0[A-Z0-9]{8}').hasMatch(purchaseSource), isFalse,
        reason: 'Production commerce source must not embed ASIN literals.');
  });
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  Set<String> ids = <String>{};
  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);
  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async => ids = Set<String>.from(favoriteIds);
}
