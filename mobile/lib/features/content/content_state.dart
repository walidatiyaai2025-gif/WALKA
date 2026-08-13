import 'package:flutter/widgets.dart';

import 'data/walka_home_banner_repository.dart';
import 'data/walka_home_featured_repository.dart';
import 'data/walka_home_hero_repository.dart';
import 'data/walka_home_layout_repository.dart';
import 'domain/walka_home_banner_content.dart';
import 'domain/walka_home_featured_content.dart';
import 'domain/walka_home_layout_content.dart';
import 'domain/walka_mobile_content.dart';

class WalkaContentController extends ChangeNotifier {
  WalkaContentController({
    WalkaHomeHeroRepository? homeRepository,
    WalkaHomeLayoutRepository? homeLayoutRepository,
    WalkaHomeFeaturedRepository? homeFeaturedRepository,
    WalkaHomeBannerRepository? homeBannerRepository,
  })  : _homeRepository = homeRepository,
        _homeLayoutRepository = homeLayoutRepository,
        _homeFeaturedRepository = homeFeaturedRepository,
        _homeBannerRepository = homeBannerRepository,
        _home = WalkaHomeHeroSnapshot.bundled(),
        _homeLayout = WalkaHomeLayoutSnapshot.bundled(),
        _homeFeatured = WalkaHomeFeaturedSnapshot.bundled(),
        _homeBanner = WalkaHomeBannerSnapshot.bundled(),
        _isLoading = homeRepository != null ||
            homeLayoutRepository != null ||
            homeFeaturedRepository != null ||
            homeBannerRepository != null;

  final WalkaHomeHeroRepository? _homeRepository;
  final WalkaHomeLayoutRepository? _homeLayoutRepository;
  final WalkaHomeFeaturedRepository? _homeFeaturedRepository;
  final WalkaHomeBannerRepository? _homeBannerRepository;
  WalkaHomeHeroSnapshot _home;
  WalkaHomeLayoutSnapshot _homeLayout;
  WalkaHomeFeaturedSnapshot _homeFeatured;
  WalkaHomeBannerSnapshot _homeBanner;
  bool _isLoading;

  WalkaHomeHeroSnapshot get home => _home;
  WalkaHomeLayoutSnapshot get homeLayout => _homeLayout;
  WalkaHomeFeaturedSnapshot get homeFeatured => _homeFeatured;
  WalkaHomeBannerSnapshot get homeBanner => _homeBanner;
  bool get isLoading => _isLoading;
  bool get canRefresh =>
      _homeRepository != null ||
      _homeLayoutRepository != null ||
      _homeFeaturedRepository != null ||
      _homeBannerRepository != null;
  bool get isOffline =>
      _home.source != WalkaContentSource.remote ||
      _homeLayout.source != WalkaContentSource.remote ||
      _homeFeatured.source != WalkaContentSource.remote ||
      _homeBanner.source != WalkaContentSource.remote;

  Future<void> load() async {
    final WalkaHomeHeroRepository? homeRepository = _homeRepository;
    final WalkaHomeLayoutRepository? layoutRepository = _homeLayoutRepository;
    final WalkaHomeFeaturedRepository? featuredRepository =
        _homeFeaturedRepository;
    final WalkaHomeBannerRepository? bannerRepository = _homeBannerRepository;
    if (homeRepository == null &&
        layoutRepository == null &&
        featuredRepository == null &&
        bannerRepository == null) {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    notifyListeners();

    if (homeRepository != null) {
      _home = await homeRepository.load();
    }
    if (layoutRepository != null) {
      _homeLayout = await layoutRepository.load();
    }
    if (featuredRepository != null) {
      _homeFeatured = await featuredRepository.load();
    }
    if (bannerRepository != null) {
      _homeBanner = await bannerRepository.load();
    }

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
    return context
        .dependOnInheritedWidgetOfExactType<WalkaContentScope>()
        ?.notifier;
  }
}
