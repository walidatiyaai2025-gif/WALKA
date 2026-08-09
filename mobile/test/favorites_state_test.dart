import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/favorites/favorites_state.dart';

void main() {
  group('WalkaFavoritesController', () {
    test('starts empty after loading an empty store', () async {
      final _MemoryFavoritesStore store = _MemoryFavoritesStore(<String>{});
      final WalkaFavoritesController controller = WalkaFavoritesController(store);

      await controller.load();

      expect(controller.isLoaded, isTrue);
      expect(controller.savedDrawerVariants, isEmpty);
    });

    test('loads white and gray in deterministic display order', () async {
      final _MemoryFavoritesStore store = _MemoryFavoritesStore(<String>{
        WalkaFavoritesController.drawerGrayId,
        WalkaFavoritesController.drawerWhiteId,
      });
      final WalkaFavoritesController controller = WalkaFavoritesController(store);

      await controller.load();

      expect(controller.savedDrawerVariants, <bool>[false, true]);
      expect(controller.isDrawerFavorite(gray: false), isTrue);
      expect(controller.isDrawerFavorite(gray: true), isTrue);
    });

    test('toggles variants independently and writes state', () async {
      final _MemoryFavoritesStore store = _MemoryFavoritesStore(<String>{});
      final WalkaFavoritesController controller = WalkaFavoritesController(store);
      await controller.load();

      expect(await controller.toggleDrawer(gray: false), isTrue);
      expect(controller.savedDrawerVariants, <bool>[false]);

      expect(await controller.toggleDrawer(gray: true), isTrue);
      expect(controller.savedDrawerVariants, <bool>[false, true]);
      expect(
        store.ids,
        <String>{
          WalkaFavoritesController.drawerWhiteId,
          WalkaFavoritesController.drawerGrayId,
        },
      );
    });

    test('remove is visible to a newly loaded controller', () async {
      final _MemoryFavoritesStore store = _MemoryFavoritesStore(<String>{
        WalkaFavoritesController.drawerWhiteId,
        WalkaFavoritesController.drawerGrayId,
      });
      final WalkaFavoritesController first = WalkaFavoritesController(store);
      await first.load();
      expect(await first.removeDrawer(gray: true), isTrue);

      final WalkaFavoritesController second = WalkaFavoritesController(store);
      await second.load();
      expect(second.savedDrawerVariants, <bool>[false]);
    });

    test('restores state when a store write cannot complete', () async {
      final _MemoryFavoritesStore store = _MemoryFavoritesStore(<String>{
        WalkaFavoritesController.drawerWhiteId,
      })..rejectWrites = true;
      final WalkaFavoritesController controller = WalkaFavoritesController(store);
      await controller.load();

      expect(await controller.toggleDrawer(gray: true), isFalse);
      expect(controller.savedDrawerVariants, <bool>[false]);
    });
  });
}

class _MemoryFavoritesStore implements WalkaFavoritesStore {
  _MemoryFavoritesStore(Set<String> initialIds)
      : ids = Set<String>.from(initialIds);

  Set<String> ids;
  bool rejectWrites = false;

  @override
  Future<Set<String>> readFavoriteIds() async => Set<String>.from(ids);

  @override
  Future<void> writeFavoriteIds(Set<String> favoriteIds) async {
    if (rejectWrites) {
      return Future<void>.error(StateError('write rejected'));
    }
    ids = Set<String>.from(favoriteIds);
  }
}
