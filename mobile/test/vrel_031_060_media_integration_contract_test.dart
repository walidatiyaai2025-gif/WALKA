import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/components/media/walka_product_media.dart';
import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';

void main() {
  const Set<String> releasedVariants = <String>{
    'drawer-organizer:white',
    'drawer-organizer:gray',
    'lunch-box:blue',
    'lunch-box:pink',
    'lunch-box:green',
  };

  test('VREL-031..040 production resolver inventory and fallback stay deterministic', () {
    expect(WalkaProductMediaResolver.productionAssets.keys.toSet(), releasedVariants);
    expect(WalkaProductMediaResolver.productionAssets.length, 5);
    expect(WalkaProductMediaResolver.defaultCacheWidth, 1200);

    expect(
      WalkaProductMediaResolver.productionAssets['drawer-organizer:white']!.assetPath,
      'assets/products/drawer/white.png',
    );
    expect(
      WalkaProductMediaResolver.productionAssets['drawer-organizer:gray']!.assetPath,
      'assets/products/drawer/gray.png',
    );
    expect(
      WalkaProductMediaResolver.productionAssets['lunch-box:blue']!.assetPath,
      'assets/products/lunch/blue.png',
    );
    expect(
      WalkaProductMediaResolver.productionAssets['lunch-box:pink']!.assetPath,
      'assets/products/lunch/pink.png',
    );
    expect(
      WalkaProductMediaResolver.productionAssets['lunch-box:green']!.assetPath,
      'assets/products/lunch/green.png',
    );

    const WalkaPaintedProductMedia fallback = WalkaPaintedProductMedia(
      kind: WalkaProductVisualKind.drawerOrganizer,
      primaryColor: Colors.white,
      semanticLabel: 'Drawer fallback',
    );
    const WalkaProductMediaResolver resolver = WalkaProductMediaResolver.production();
    expect(
      resolver.resolve(variantId: 'drawer-organizer:white', fallback: fallback),
      isA<WalkaAssetProductMedia>(),
    );
    expect(
      identical(
        resolver.resolve(variantId: 'not-released', fallback: fallback),
        fallback,
      ),
      isTrue,
    );
  });

  test('VREL-041..050 Home and Discovery owner-visible media use stable variant IDs', () {
    final String hero = _read(
      'lib/features/storefront/presentation/widgets/home/walka_home_hero.dart',
    );
    final String collections = _read(
      'lib/features/storefront/presentation/widgets/home/walka_home_collection_section.dart',
    );
    final String smallChanges = _read(
      'lib/features/storefront/presentation/widgets/home/walka_home_small_changes.dart',
    );
    final String categoryCard = _read(
      'lib/features/storefront/presentation/widgets/discovery/walka_category_card.dart',
    );
    final String productRow = _read(
      'lib/features/storefront/presentation/widgets/discovery/walka_discovery_product_row.dart',
    );
    final String searchResults = _read(
      'lib/features/storefront/presentation/widgets/discovery/walka_search_results.dart',
    );

    expect(hero, contains('WalkaResolvedProductMedia'));
    expect(hero, contains("variantId: 'lunch-box:green'"));
    expect(hero, contains("variantId: 'drawer-organizer:white'"));
    expect(collections, contains("variantId: 'lunch-box:blue'"));
    expect(collections, contains("variantId: 'drawer-organizer:white'"));
    expect(smallChanges, contains('WalkaResolvedProductMedia'));
    expect(smallChanges, contains("variantId: 'drawer-organizer:white'"));
    expect(categoryCard, contains('WalkaResolvedProductMedia'));
    expect(productRow, contains('variantId: item.variantId'));
    expect(searchResults, contains('WalkaDiscoveryProductRow'));

    // The audited owner-visible Home surfaces no longer branch around the
    // resolver with screen-specific direct product painters.
    expect(hero, isNot(contains('child: WalkaProductVisual(')));
    expect(smallChanges, isNot(contains('child: WalkaProductVisual(')));
  });

  test('VREL-051..060 PDP Favorites About and Account keep truthful media boundaries', () {
    final String viewport = _read(
      'lib/features/products/presentation/widgets/walka_pdp_gallery_viewport.dart',
    );
    final String fullscreen = _read(
      'lib/features/products/presentation/widgets/walka_pdp_fullscreen_gallery.dart',
    );
    final String favorite = _read(
      'lib/features/storefront/presentation/widgets/favorites/walka_saved_drawer_card.dart',
    );
    final String about = _read(
      'lib/features/storefront/presentation/widgets/about/walka_about_product_story.dart',
    );
    final String account = _read(
      'lib/features/storefront/account_about_reference_v131.dart',
    );

    expect(viewport, contains('index == 0'));
    expect(viewport, contains('WalkaResolvedProductMedia'));
    expect(viewport, contains('approved secondary product photography pending'));
    expect(fullscreen, contains('index == 0'));
    expect(fullscreen, contains('WalkaResolvedProductMedia'));
    expect(fullscreen, contains('approved secondary product photography pending'));

    expect(favorite, contains("'drawer-organizer:gray'"));
    expect(favorite, contains("'drawer-organizer:white'"));
    expect(favorite, contains('WalkaResolvedProductMedia'));
    expect(about, contains("variantId: 'drawer-organizer:white'"));
    expect(about, contains("variantId: 'lunch-box:blue'"));

    // Account has no product-media role and should not decode product assets.
    expect(account, isNot(contains('WalkaResolvedProductMedia')));
    expect(account, isNot(contains('WalkaProductMediaResolver')));
  });

  test('cross-screen semantics describe product identity and illustrative fallback truth', () {
    final List<String> sources = <String>[
      _read('lib/features/storefront/presentation/widgets/home/walka_home_hero.dart'),
      _read('lib/features/storefront/presentation/widgets/home/walka_home_collection_card.dart'),
      _read('lib/features/storefront/presentation/widgets/discovery/walka_discovery_product_row.dart'),
      _read('lib/features/storefront/presentation/widgets/favorites/walka_saved_drawer_card.dart'),
      _read('lib/features/products/presentation/widgets/walka_pdp_gallery_viewport.dart'),
    ];
    expect(sources.every((String source) => source.contains('semanticLabel')), isTrue);
    expect(sources.last, contains('illustrative fallback view'));
  });
}

String _read(String path) => File(path).readAsStringSync();
