import 'package:flutter/widgets.dart';

import 'data/walka_home_hero_repository.dart';
import 'domain/walka_mobile_content.dart';

class WalkaContentController extends ChangeNotifier {
  WalkaContentController({WalkaHomeHeroRepository? homeRepository})
      : _homeRepository = homeRepository,
        _home = WalkaHomeHeroSnapshot.bundled(),
        _isLoading = homeRepository != null;

  final WalkaHomeHeroRepository? _homeRepository;
  WalkaHomeHeroSnapshot _home;
  bool _isLoading;

  WalkaHomeHeroSnapshot get home => _home;
  bool get isLoading => _isLoading;
  bool get canRefresh => _homeRepository != null;
  bool get isOffline => _home.source != WalkaContentSource.remote;

  Future<void> load() async {
    final WalkaHomeHeroRepository? repository = _homeRepository;
    if (repository == null) {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    notifyListeners();
    _home = await repository.load();
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
