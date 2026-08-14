import 'package:flutter/widgets.dart';

import 'data/walka_category_presentation_repository.dart';
import 'data/walka_home_banner_repository.dart';
import 'data/walka_home_featured_repository.dart';
import 'data/walka_home_hero_repository.dart';
import 'data/walka_home_layout_repository.dart';
import 'data/walka_information_repository.dart';
import 'data/walka_operational_repository.dart';
import 'data/walka_pdp_layout_repository.dart';
import 'data/walka_related_products_repository.dart';
import 'data/walka_search_presentation_repository.dart';
import 'domain/walka_category_presentation_content.dart';
import 'domain/walka_home_banner_content.dart';
import 'domain/walka_home_featured_content.dart';
import 'domain/walka_home_layout_content.dart';
import 'domain/walka_information_content.dart';
import 'domain/walka_mobile_content.dart';
import 'domain/walka_operational_content.dart';
import 'domain/walka_pdp_layout_content.dart';
import 'domain/walka_related_products_content.dart';
import 'domain/walka_search_presentation_content.dart';

class WalkaContentController extends ChangeNotifier {
  WalkaContentController({
    WalkaHomeHeroRepository? homeRepository,
    WalkaHomeLayoutRepository? homeLayoutRepository,
    WalkaHomeFeaturedRepository? homeFeaturedRepository,
    WalkaHomeBannerRepository? homeBannerRepository,
    WalkaCategoryPresentationRepository? categoryPresentationRepository,
    WalkaSearchPresentationRepository? searchPresentationRepository,
    WalkaInformationRepository? informationRepository,
    WalkaMaintenanceNoticeRepository? maintenanceNoticeRepository,
    WalkaAppConfigRepository? appConfigRepository,
    WalkaPdpLayoutRepository? pdpLayoutRepository,
    WalkaRelatedProductsRepository? relatedProductsRepository,
  })  : _homeRepository = homeRepository,
        _homeLayoutRepository = homeLayoutRepository,
        _homeFeaturedRepository = homeFeaturedRepository,
        _homeBannerRepository = homeBannerRepository,
        _categoryPresentationRepository = categoryPresentationRepository,
        _searchPresentationRepository = searchPresentationRepository,
        _informationRepository = informationRepository,
        _maintenanceNoticeRepository = maintenanceNoticeRepository,
        _appConfigRepository = appConfigRepository,
        _pdpLayoutRepository = pdpLayoutRepository,
        _relatedProductsRepository = relatedProductsRepository,
        _home = WalkaHomeHeroSnapshot.bundled(),
        _homeLayout = WalkaHomeLayoutSnapshot.bundled(),
        _homeFeatured = WalkaHomeFeaturedSnapshot.bundled(),
        _homeBanner = WalkaHomeBannerSnapshot.bundled(),
        _categories = WalkaCategoryPresentationSnapshot.bundled(),
        _search = WalkaSearchPresentationSnapshot.bundled(),
        _information = WalkaInformationSnapshot.bundled(),
        _maintenanceNotice = WalkaMaintenanceNoticeSnapshot.bundled(),
        _appConfig = WalkaAppConfigSnapshot.bundled(),
        _pdpLayout = WalkaPdpLayoutSnapshot.bundled(),
        _relatedProducts = WalkaRelatedProductsSnapshot.bundled(),
        _isLoading = homeRepository != null ||
            homeLayoutRepository != null ||
            homeFeaturedRepository != null ||
            homeBannerRepository != null ||
            categoryPresentationRepository != null ||
            searchPresentationRepository != null ||
            informationRepository != null ||
            maintenanceNoticeRepository != null ||
            appConfigRepository != null ||
            pdpLayoutRepository != null ||
            relatedProductsRepository != null;

  final WalkaHomeHeroRepository? _homeRepository;
  final WalkaHomeLayoutRepository? _homeLayoutRepository;
  final WalkaHomeFeaturedRepository? _homeFeaturedRepository;
  final WalkaHomeBannerRepository? _homeBannerRepository;
  final WalkaCategoryPresentationRepository? _categoryPresentationRepository;
  final WalkaSearchPresentationRepository? _searchPresentationRepository;
  final WalkaInformationRepository? _informationRepository;
  final WalkaMaintenanceNoticeRepository? _maintenanceNoticeRepository;
  final WalkaAppConfigRepository? _appConfigRepository;
  final WalkaPdpLayoutRepository? _pdpLayoutRepository;
  final WalkaRelatedProductsRepository? _relatedProductsRepository;
  WalkaHomeHeroSnapshot _home;
  WalkaHomeLayoutSnapshot _homeLayout;
  WalkaHomeFeaturedSnapshot _homeFeatured;
  WalkaHomeBannerSnapshot _homeBanner;
  WalkaCategoryPresentationSnapshot _categories;
  WalkaSearchPresentationSnapshot _search;
  WalkaInformationSnapshot _information;
  WalkaMaintenanceNoticeSnapshot _maintenanceNotice;
  WalkaAppConfigSnapshot _appConfig;
  WalkaPdpLayoutSnapshot _pdpLayout;
  WalkaRelatedProductsSnapshot _relatedProducts;
  bool _isLoading;

  WalkaHomeHeroSnapshot get home => _home;
  WalkaHomeLayoutSnapshot get homeLayout => _homeLayout;
  WalkaHomeFeaturedSnapshot get homeFeatured => _homeFeatured;
  WalkaHomeBannerSnapshot get homeBanner => _homeBanner;
  WalkaCategoryPresentationSnapshot get categories => _categories;
  WalkaSearchPresentationSnapshot get search => _search;
  WalkaInformationSnapshot get information => _information;
  WalkaMaintenanceNoticeSnapshot get maintenanceNotice => _maintenanceNotice;
  WalkaAppConfigSnapshot get appConfig => _appConfig;
  WalkaPdpLayoutSnapshot get pdpLayout => _pdpLayout;
  WalkaRelatedProductsSnapshot get relatedProducts => _relatedProducts;
  bool get isLoading => _isLoading;
  bool get canRefresh =>
      _homeRepository != null ||
      _homeLayoutRepository != null ||
      _homeFeaturedRepository != null ||
      _homeBannerRepository != null ||
      _categoryPresentationRepository != null ||
      _searchPresentationRepository != null ||
      _informationRepository != null ||
      _maintenanceNoticeRepository != null ||
      _appConfigRepository != null ||
      _pdpLayoutRepository != null ||
      _relatedProductsRepository != null;
  bool get isOffline =>
      _home.source != WalkaContentSource.remote ||
      _homeLayout.source != WalkaContentSource.remote ||
      _homeFeatured.source != WalkaContentSource.remote ||
      _homeBanner.source != WalkaContentSource.remote ||
      _categories.source != WalkaContentSource.remote ||
      _search.source != WalkaContentSource.remote ||
      _information.source != WalkaContentSource.remote ||
      _maintenanceNotice.source != WalkaContentSource.remote ||
      _appConfig.source != WalkaContentSource.remote ||
      _pdpLayout.source != WalkaContentSource.remote ||
      _relatedProducts.source != WalkaContentSource.remote;

  Future<void> load() async {
    final WalkaHomeHeroRepository? homeRepository = _homeRepository;
    final WalkaHomeLayoutRepository? layoutRepository = _homeLayoutRepository;
    final WalkaHomeFeaturedRepository? featuredRepository = _homeFeaturedRepository;
    final WalkaHomeBannerRepository? bannerRepository = _homeBannerRepository;
    final WalkaCategoryPresentationRepository? categoryRepository = _categoryPresentationRepository;
    final WalkaSearchPresentationRepository? searchRepository = _searchPresentationRepository;
    final WalkaInformationRepository? informationRepository = _informationRepository;
    final WalkaMaintenanceNoticeRepository? maintenanceRepository = _maintenanceNoticeRepository;
    final WalkaAppConfigRepository? appConfigRepository = _appConfigRepository;
    final WalkaPdpLayoutRepository? pdpRepository = _pdpLayoutRepository;
    final WalkaRelatedProductsRepository? relatedRepository = _relatedProductsRepository;
    if (homeRepository == null &&
        layoutRepository == null &&
        featuredRepository == null &&
        bannerRepository == null &&
        categoryRepository == null &&
        searchRepository == null &&
        informationRepository == null &&
        maintenanceRepository == null &&
        appConfigRepository == null &&
        pdpRepository == null &&
        relatedRepository == null) {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    if (homeRepository != null) _home = await homeRepository.load();
    if (layoutRepository != null) _homeLayout = await layoutRepository.load();
    if (featuredRepository != null) _homeFeatured = await featuredRepository.load();
    if (bannerRepository != null) _homeBanner = await bannerRepository.load();
    if (categoryRepository != null) _categories = await categoryRepository.load();
    if (searchRepository != null) _search = await searchRepository.load();
    if (informationRepository != null) _information = await informationRepository.load();
    if (maintenanceRepository != null) _maintenanceNotice = await maintenanceRepository.load();
    if (appConfigRepository != null) _appConfig = await appConfigRepository.load();
    if (pdpRepository != null) _pdpLayout = await pdpRepository.load();
    if (relatedRepository != null) _relatedProducts = await relatedRepository.load();

    _isLoading = false;
    notifyListeners();
  }
}

class WalkaContentScope extends InheritedNotifier<WalkaContentController> {
  const WalkaContentScope({
    required WalkaContentController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static WalkaContentController of(BuildContext context) {
    final WalkaContentScope? scope =
        context.dependOnInheritedWidgetOfExactType<WalkaContentScope>();
    assert(scope != null, 'WalkaContentScope is missing above this widget.');
    return scope!.notifier!;
  }

  static WalkaContentController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WalkaContentScope>()?.notifier;
  }
}
