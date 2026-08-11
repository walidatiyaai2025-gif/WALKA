import 'package:flutter/widgets.dart';

import 'data/walka_home_hero_repository.dart';
import 'data/walka_home_layout_repository.dart';
import 'domain/walka_home_layout_content.dart';
import 'domain/walka_mobile_content.dart';

class WalkaContentController extends ChangeNotifier {
  WalkaContentController({
    WalkaHomeHeroRepository? homeRepository,
    WalkaHomeLayoutRepository? homeLayoutRepository,
  })  : _homeRepository = homeRepository,
        _homeLayoutRepository = homeLayoutRepository,
        _home = WalkaHomeHeroSnapshot.bundled(),
        _homeLayout = WalkaHomeLayoutSnapshot.bundled(),
        _isLoading = homeRepository != null || homeLayoutRepository != null;

  final WalkaHomeHeroRepository? _homeRepository;
  final WalkaHomeLayoutRepository? _homeLayoutRepository;
  WalkaHomeHeroSnapshot _home;
  WalkaHomeLayoutSnapshot _homeLayout;
  bool _isLoading;

  WalkaHomeHeroSnapshot get home => _home;
  WalkaHomeLayoutSnapshot get homeLayout => _homeLayout;
  bool get isLoading => _isLoading;
  bool get canRefresh =>
      _homeRepository != null || _homeLayoutRepository != null;
  bool get isOffline =>
      _home.source != WalkaContentSource.remote ||
      _homeLayout.source != WalkaContentSource.remote;

  Future<void> load() async {
    final WalkaHomeHeroRepository? homeRepository = _homeRepository;
    final WalkaHomeLayoutRepository? layoutRepository = _homeLayoutRepository;
    if (homeRepository == null && layoutRepository == null) {
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
