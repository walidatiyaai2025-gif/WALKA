import 'dart:async';

import 'package:flutter/material.dart';

import 'core/api/walka_api_client.dart';
import 'design_system/walka_theme.dart';
import 'features/catalog/catalog_state.dart';
import 'features/catalog/data/walka_catalog_cache.dart';
import 'features/catalog/data/walka_catalog_repository.dart';
import 'features/content/content_state.dart';
import 'features/content/data/walka_home_banner_cache.dart';
import 'features/content/data/walka_home_banner_repository.dart';
import 'features/content/data/walka_home_featured_cache.dart';
import 'features/content/data/walka_home_featured_repository.dart';
import 'features/content/data/walka_home_hero_cache.dart';
import 'features/content/data/walka_home_hero_repository.dart';
import 'features/content/data/walka_home_layout_cache.dart';
import 'features/content/data/walka_home_layout_repository.dart';
import 'features/favorites/favorites_state.dart';
import 'features/storefront/storefront_v102.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final WalkaFavoritesController favoritesController = WalkaFavoritesController(
    SharedPreferencesWalkaFavoritesStore(),
  );
  await favoritesController.load();

  const WalkaApiSettings apiSettings = WalkaApiSettings(
    baseUrl: WalkaApiSettings.environmentBaseUrl,
  );
  final WalkaApiClient? apiClient = apiSettings.isConfigured
      ? WalkaApiClient(settings: apiSettings)
      : null;
  final WalkaCatalogController catalogController = WalkaCatalogController(
    repository: WalkaCatalogRepository(
      cache: SharedPreferencesWalkaCatalogCache(),
      remote: apiClient,
    ),
  );
  final WalkaContentController contentController = WalkaContentController(
    homeRepository: WalkaHomeHeroRepository(
      cache: SharedPreferencesWalkaHomeHeroCache(),
      remoteLoader: apiClient?.fetchHomeHero,
    ),
    homeLayoutRepository: WalkaHomeLayoutRepository(
      cache: SharedPreferencesWalkaHomeLayoutCache(),
      remoteLoader: apiClient?.fetchHomeLayout,
    ),
    homeFeaturedRepository: WalkaHomeFeaturedRepository(
      cache: SharedPreferencesWalkaHomeFeaturedCache(),
      remoteLoader: apiClient?.fetchHomeFeatured,
    ),
    homeBannerRepository: WalkaHomeBannerRepository(
      cache: SharedPreferencesWalkaHomeBannerCache(),
      remoteLoader: apiClient?.fetchHomeBanner,
    ),
  );

  runApp(
    WalkaApp(
      favoritesController: favoritesController,
      catalogController: catalogController,
      contentController: contentController,
    ),
  );
  unawaited(catalogController.load());
  unawaited(contentController.load());
}

class WalkaApp extends StatelessWidget {
  const WalkaApp({
    required this.favoritesController,
    this.catalogController,
    this.contentController,
    super.key,
  });

  final WalkaFavoritesController favoritesController;
  final WalkaCatalogController? catalogController;
  final WalkaContentController? contentController;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController resolvedCatalog =
        catalogController ?? WalkaCatalogController();
    final WalkaContentController resolvedContent =
        contentController ?? WalkaContentController();

    return WalkaContentScope(
      controller: resolvedContent,
      child: WalkaCatalogScope(
        controller: resolvedCatalog,
        child: WalkaFavoritesScope(
          controller: favoritesController,
          child: MaterialApp(
            title: 'WALKA',
            debugShowCheckedModeBanner: false,
            theme: buildWalkaTheme(),
            home: const WalkaStorefrontSplashV102(),
          ),
        ),
      ),
    );
  }
}
