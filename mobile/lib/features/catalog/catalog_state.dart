import 'package:flutter/widgets.dart';

import '../commerce/amazon_purchase.dart';
import 'catalog_presentation.dart';
import 'data/walka_bundled_catalog.dart';
import 'data/walka_catalog_repository.dart';
import 'domain/walka_catalog.dart';

class WalkaCatalogController extends ChangeNotifier {
  WalkaCatalogController({
    WalkaCatalogRepository? repository,
    WalkaCatalogSnapshot? initialSnapshot,
  })  : _repository = repository,
        _snapshot = walkaPresentationSnapshot(
          initialSnapshot ??
              (repository == null ? presentationInitialSnapshotFactory?.call() : null) ??
              WalkaBundledCatalog.snapshot(),
        ),
        _isLoading = repository != null;

  /// Test/presentation dependency injection only. Production does not assign
  /// this hook, so repository-backed runtime controllers still start empty and
  /// can load only Remote -> Last-Known-Good cache.
  @visibleForTesting
  static WalkaCatalogSnapshot Function()? presentationInitialSnapshotFactory;

  /// Side-effect-free base constructor for a presentation-only delegating
  /// controller. It intentionally does not touch the global Amazon registry.
  @protected
  WalkaCatalogController.presentationProxy()
      : _repository = null,
        _snapshot = walkaPresentationSnapshot(WalkaBundledCatalog.snapshot()),
        _isLoading = false;

  final WalkaCatalogRepository? _repository;
  WalkaCatalogSnapshot _snapshot;
  bool _isLoading;

  WalkaCatalogSnapshot get snapshot => _snapshot;
  bool get isLoading => _isLoading;
  bool get canRefresh => _repository != null;
  bool get isOffline => _snapshot.source != WalkaCatalogSource.remote;
  bool get isUsingCache => _snapshot.source == WalkaCatalogSource.cache;
  bool get isUnavailable => !_snapshot.isAvailable;

  @Deprecated('Bundled catalog entities were removed; use isUnavailable.')
  bool get isUsingBundledFallback => false;

  Future<void> load() async {
    final WalkaCatalogRepository? repository = _repository;
    if (repository == null) {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    _isLoading = true;
    notifyListeners();
    try {
      final WalkaCatalogSnapshot next = walkaPresentationSnapshot(
        await repository.load(),
      );
      _snapshot = next;
      WalkaAmazonPurchaseRegistry.replaceFromSnapshot(next);
    } on WalkaCatalogUnavailableException {
      // Keep a previously validated LKG snapshot if one is already active.
      // Initial empty state remains unavailable instead of inventing products.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class WalkaCatalogScope extends InheritedNotifier<WalkaCatalogController> {
  const WalkaCatalogScope({
    required WalkaCatalogController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static WalkaCatalogController of(BuildContext context) {
    final WalkaCatalogScope? scope = context
        .dependOnInheritedWidgetOfExactType<WalkaCatalogScope>();
    assert(scope != null, 'WalkaCatalogScope is missing above this widget.');
    return scope!.notifier!;
  }

  static WalkaCatalogController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WalkaCatalogScope>()
        ?.notifier;
  }
}
