import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class WalkaFavoritesStore {
  Future<Set<String>> readFavoriteIds();

  Future<void> writeFavoriteIds(Set<String> ids);
}

class SharedPreferencesWalkaFavoritesStore implements WalkaFavoritesStore {
  static const String storageKey = 'walka.favorite_ids.v1';

  @override
  Future<Set<String>> readFavoriteIds() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(storageKey) ?? const <String>[]).toSet();
  }

  @override
  Future<void> writeFavoriteIds(Set<String> ids) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> values = ids.toList()..sort();
    final bool saved = await preferences.setStringList(storageKey, values);
    if (!saved) {
      throw StateError('Unable to persist WALKA favorites.');
    }
  }
}

class WalkaFavoritesController extends ChangeNotifier {
  WalkaFavoritesController(this._store);

  static const String drawerWhiteId = 'drawer-organizer:white';
  static const String drawerGrayId = 'drawer-organizer:gray';

  final WalkaFavoritesStore _store;
  Set<String> _favoriteIds = <String>{};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  List<bool> get savedDrawerVariants => <bool>[
        if (_favoriteIds.contains(drawerWhiteId)) false,
        if (_favoriteIds.contains(drawerGrayId)) true,
      ];

  bool isDrawerFavorite({required bool gray}) {
    return _favoriteIds.contains(_drawerId(gray: gray));
  }

  Future<void> load() async {
    try {
      _favoriteIds = await _store.readFavoriteIds();
    } catch (_) {
      _favoriteIds = <String>{};
    }
    _isLoaded = true;
    notifyListeners();
  }

  Future<bool> toggleDrawer({required bool gray}) async {
    final String id = _drawerId(gray: gray);
    final Set<String> before = Set<String>.from(_favoriteIds);

    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }

    return _persistOrRollback(before);
  }

  Future<bool> removeDrawer({required bool gray}) async {
    final String id = _drawerId(gray: gray);
    if (!_favoriteIds.contains(id)) {
      return true;
    }

    final Set<String> before = Set<String>.from(_favoriteIds);
    _favoriteIds.remove(id);
    return _persistOrRollback(before);
  }

  String _drawerId({required bool gray}) {
    return gray ? drawerGrayId : drawerWhiteId;
  }

  Future<bool> _persistOrRollback(Set<String> before) async {
    notifyListeners();
    try {
      await _store.writeFavoriteIds(Set<String>.from(_favoriteIds));
      return true;
    } catch (_) {
      _favoriteIds = before;
      notifyListeners();
      return false;
    }
  }
}

class WalkaFavoritesScope extends InheritedNotifier<WalkaFavoritesController> {
  const WalkaFavoritesScope({
    required WalkaFavoritesController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static WalkaFavoritesController of(BuildContext context) {
    final WalkaFavoritesScope? scope = context
        .dependOnInheritedWidgetOfExactType<WalkaFavoritesScope>();
    assert(scope != null, 'WalkaFavoritesScope is missing above this widget.');
    return scope!.notifier!;
  }
}
