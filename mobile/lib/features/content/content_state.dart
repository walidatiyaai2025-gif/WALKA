import 'package:flutter/widgets.dart';

import 'data/walka_category_presentation_repository.dart';
import 'data/walka_home_banner_repository.dart';
import 'data/walka_home_featured_repository.dart';
import 'data/walka_home_hero_repository.dart';
import 'data/walka_home_layout_repository.dart';
import 'data/walka_pdp_layout_repository.dart';
import 'data/walka_search_presentation_repository.dart';
import 'data/walka_storefront_copy_repository.dart';
import 'domain/walka_category_presentation_content.dart';
import 'domain/walka_home_banner_content.dart';
import 'domain/walka_home_featured_content.dart';
import 'domain/walka_home_layout_content.dart';
import 'domain/walka_mobile_content.dart';
import 'domain/walka_pdp_layout_content.dart';
import 'domain/walka_search_presentation_content.dart';
import 'domain/walka_storefront_copy_content.dart';

class WalkaContentController extends ChangeNotifier {
  WalkaContentController({
    WalkaHomeHeroRepository? homeRepository,
    WalkaHomeLayoutRepository? homeLayoutRepository,
    WalkaHomeFeaturedRepository? homeFeaturedRepository,
    WalkaHomeBannerRepository? homeBannerRepository,
    WalkaCategoryPresentationRepository? categoryPresentationRepository,
    WalkaSearchPresentationRepository? searchPresentationRepository,
    WalkaStorefrontCopyRepository? storefrontCopyRepository,
    WalkaPdpLayoutRepository? pdpLayoutRepository,
  })  : _homeRepository = homeRepository,
        _homeLayoutRepository = homeLayoutRepository,
        _homeFeaturedRepository = homeFeaturedRepository,
        _homeBannerRepository = homeBannerRepository,
        _categoryPresentationRepository = categoryPresentationRepository,
        _searchPresentationRepository = searchPresentationRepository,
        _storefrontCopyRepository = storefrontCopyRepository,
        _pdpLayoutRepository = pdpLayoutRepository,
        _home = WalkaHomeHeroSnapshot.bundled(),
        _homeLayout = WalkaHomeLayoutSnapshot.bundled(),
        _homeFeatured = WalkaHomeFeaturedSnapshot.bundled(),
        _homeBanner = WalkaHomeBannerSnapshot.bundled(),
        _categories = WalkaCategoryPresentationSnapshot.bundled(),
        _search = WalkaSearchPresentationSnapshot.bundled(),
        _storefrontCopy = WalkaStorefrontCopySnapshot.bundled(),
        _pdpLayout = WalkaPdpLayoutSnapshot.bundled(),
        _isLoading = homeRepository != null ||
            homeLayoutRepository != null ||
            homeFeaturedRepository != null ||
            homeBannerRepository != null ||
            categoryPresentationRepository != null ||
            searchPresentationRepository != null ||
            storefrontCopyRepository != null ||
            pdpLayoutRepository != null;

  final WalkaHomeHeroRepository? _homeRepository;
  final WalkaHomeLayoutRepository? _homeLayoutRepository;
  final WalkaHomeFeaturedRepository? _homeFeaturedRepository;
  final WalkaHomeBannerRepository? _homeBannerRepository;
  final WalkaCategoryPresentationRepository? _categoryPresentationRepository;
  final WalkaSearchPresentationRepository? _searchPresentationRepository;
  final WalkaStorefrontCopyRepository? _storefrontCopyRepository;
  final WalkaPdpLayoutRepository? _pdpLayoutRepository;
  WalkaHomeHeroSnapshot _home;
  WalkaHomeLayoutSnapshot _homeLayout;
  WalkaHomeFeaturedSnapshot _homeFeatured;
  WalkaHomeBannerSnapshot _homeBanner;
  WalkaCategoryPresentationSnapshot _categories;
  WalkaSearchPresentationSnapshot _search;
  WalkaStorefrontCopySnapshot _storefrontCopy;
  WalkaPdpLayoutSnapshot _pdpLayout;
  bool _isLoading;

  WalkaHomeHeroSnapshot get home => _home;
  WalkaHomeLayoutSnapshot get homeLayout => _homeLayout;
  WalkaHomeFeaturedSnapshot get homeFeatured => _homeFeatured;
  WalkaHomeBannerSnapshot get homeBanner => _homeBanner;
  WalkaCategoryPresentationSnapshot get categories => _categories;
  WalkaSearchPresentationSnapshot get search => _search;
  WalkaStorefrontCopySnapshot get storefrontCopy => _storefrontCopy;
  WalkaPdpLayoutSnapshot get pdpLayout => _pdpLayout;
  bool get isLoading => _isLoading;
  bool get canRefresh =>
      _homeRepository != null ||
      _homeLayoutRepository != null ||
      _homeFeaturedRepository != null ||
      _homeBannerRepository != null ||
      _categoryPresentationRepository != null ||
      _searchPresentationRepository != null ||
      _storefrontCopyRepository != null ||
      _pdpLayoutRepository != null;
  bool get isOffline =>
      _home.source != WalkaContentSource.remote ||
      _homeLayout.source != WalkaContentSource.remote ||
      _homeFeatured.source != WalkaContentSource.remote ||
      _homeBanner.source != WalkaContentSource.remote ||
      _categories.source != WalkaContentSource.remote ||
      _search.source != WalkaContentSource.remote ||
      _storefrontCopy.source != WalkaContentSource.remote ||
      _pdpLayout.source != WalkaContentSource.remote;

  Future<void> load() async {
    final WalkaHomeHeroRepository? homeRepository = _homeRepository;
    final WalkaHomeLayoutRepository? layoutRepository = _homeLayoutRepository;
    final WalkaHomeFeaturedRepository? featuredRepository = _homeFeaturedRepository;
    final WalkaHomeBannerRepository? bannerRepository = _homeBannerRepository;
    final WalkaCategoryPresentationRepository? categoryRepository = _categoryPresentationRepository;
    final WalkaSearchPresentationRepository? searchRepository = _searchPresentationRepository;
    final WalkaStorefrontCopyRepository? storefrontRepository = _storefrontCopyRepository;
    final WalkaPdpLayoutRepository? pdpRepository = _pdpLayoutRepository;
    if (homeRepository == null &&
        layoutRepository == null &&
        featuredRepository == null &&
        bannerRepository == null &&
        categoryRepository == null &&
        searchRepository == null &&
        storefrontRepository == null &&
        pdpRepository == null) {
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
    if (storefrontRepository != null) _storefrontCopy = await storefrontRepository.load();
    if (pdpRepository != null) _pdpLayout = await pdpRepository.load();
    _isLoading = false;
    notifyListeners();
  }
}

class WalkaContentScope extends InheritedNotifier<WalkaContentController> {
  const WalkaContentScope({required WalkaContentController controller, required super.child, super.key}) : super(notifier: controller);
  static WalkaContentController of(BuildContext context) {
    final WalkaContentScope? scope = context.dependOnInheritedWidgetOfExactType<WalkaContentScope>();
    assert(scope != null, 'WalkaContentScope is missing above this widget.');
    return scope!.notifier!;
  }
  static WalkaContentController? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<WalkaContentScope>()?.notifier;
}
