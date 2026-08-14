import 'dart:async';

import 'package:flutter/material.dart';

import 'core/api/walka_api_client.dart';
import 'design_system/walka_theme.dart';
import 'features/catalog/catalog_state.dart';
import 'features/catalog/data/walka_catalog_cache.dart';
import 'features/catalog/data/walka_catalog_repository.dart';
import 'features/content/content_state.dart';
import 'features/content/data/walka_category_presentation_cache.dart';
import 'features/content/data/walka_category_presentation_repository.dart';
import 'features/content/data/walka_home_banner_cache.dart';
import 'features/content/data/walka_home_banner_repository.dart';
import 'features/content/data/walka_home_featured_cache.dart';
import 'features/content/data/walka_home_featured_repository.dart';
import 'features/content/data/walka_home_hero_cache.dart';
import 'features/content/data/walka_home_hero_repository.dart';
import 'features/content/data/walka_home_layout_cache.dart';
import 'features/content/data/walka_home_layout_repository.dart';
import 'features/content/data/walka_information_cache.dart';
import 'features/content/data/walka_information_repository.dart';
import 'features/content/data/walka_operational_cache.dart';
import 'features/content/data/walka_operational_repository.dart';
import 'features/content/data/walka_pdp_layout_cache.dart';
import 'features/content/data/walka_pdp_layout_repository.dart';
import 'features/content/data/walka_related_products_cache.dart';
import 'features/content/data/walka_related_products_repository.dart';
import 'features/content/data/walka_search_presentation_cache.dart';
import 'features/content/data/walka_search_presentation_repository.dart';
import 'features/favorites/favorites_state.dart';
import 'features/media/data/walka_remote_media_cache.dart';
import 'features/media/data/walka_remote_media_repository.dart';
import 'features/media/data/walka_verified_remote_media_loader.dart';
import 'features/media/walka_remote_media_state.dart';
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
    categoryPresentationRepository: WalkaCategoryPresentationRepository(
      cache: SharedPreferencesWalkaCategoryPresentationCache(),
      remoteLoader: apiClient?.fetchCategoriesPresentation,
    ),
    searchPresentationRepository: WalkaSearchPresentationRepository(
      cache: SharedPreferencesWalkaSearchPresentationCache(),
      remoteLoader: apiClient?.fetchSearchPresentation,
    ),
    informationRepository: WalkaInformationRepository(
      cache: SharedPreferencesWalkaInformationCache(),
      remoteLoader: apiClient?.fetchInformation,
    ),
    maintenanceNoticeRepository: WalkaMaintenanceNoticeRepository(
      cache: SharedPreferencesWalkaMaintenanceNoticeCache(),
      remoteLoader: apiClient?.fetchMaintenanceNotice,
    ),
    appConfigRepository: WalkaAppConfigRepository(
      cache: SharedPreferencesWalkaAppConfigCache(),
      remoteLoader: apiClient?.fetchAppConfig,
    ),
    pdpLayoutRepository: WalkaPdpLayoutRepository(
      cache: SharedPreferencesWalkaPdpLayoutCache(),
      remoteLoader: apiClient?.fetchPdpLayout,
    ),
    relatedProductsRepository: WalkaRelatedProductsRepository(
      cache: SharedPreferencesWalkaRelatedProductsCache(),
      remoteLoader: apiClient?.fetchRelatedProducts,
    ),
  );
  final WalkaRemoteMediaController remoteMediaController =
      WalkaRemoteMediaController(
    repository: WalkaRemoteMediaRepository(
      cache: SharedPreferencesWalkaRemoteMediaCache(),
      productLoader: apiClient?.fetchProductMedia,
      surfaceLoader: apiClient?.fetchSurfaceMedia,
    ),
    binaryLoader: WalkaVerifiedRemoteMediaLoader(
      settings: apiSettings,
      cache: FlutterCacheManagerWalkaRemoteBinaryCache(),
    ),
  );

  runApp(
    WalkaApp(
      favoritesController: favoritesController,
      catalogController: catalogController,
      contentController: contentController,
      remoteMediaController: remoteMediaController,
    ),
  );
  unawaited(catalogController.load());
  unawaited(contentController.load());
  unawaited(remoteMediaController.load());
}

class WalkaApp extends StatelessWidget {
  const WalkaApp({
    required this.favoritesController,
    this.catalogController,
    this.contentController,
    this.remoteMediaController,
    super.key,
  });

  final WalkaFavoritesController favoritesController;
  final WalkaCatalogController? catalogController;
  final WalkaContentController? contentController;
  final WalkaRemoteMediaController? remoteMediaController;

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController resolvedCatalog =
        catalogController ?? WalkaCatalogController();
    final WalkaContentController resolvedContent =
        contentController ?? WalkaContentController();

    Widget app = WalkaCatalogScope(
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
    );
    final WalkaRemoteMediaController? resolvedRemote = remoteMediaController;
    if (resolvedRemote != null) {
      app = WalkaRemoteMediaScope(controller: resolvedRemote, child: app);
    }

    return WalkaContentScope(
      controller: resolvedContent,
      child: app,
    );
  }
}
