import 'package:flutter/widgets.dart';

import '../commerce/amazon_purchase.dart';
import 'catalog_presentation.dart';
import 'data/walka_bundled_catalog.dart';
import 'data/walka_catalog_repository.dart';
import 'domain/walka_catalog.dart';

class WalkaCatalogController extends ChangeNotifier {
  WalkaCatalogController({WalkaCatalogRepository? repository})
      : _repository = repository,
        _snapshot = walkaPresentationSnapshot(WalkaBundledCatalog.snapshot()),
        _isLoading = repository != null {
    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(_snapshot);
  }

  final WalkaCatalogRepository? _repository;
  WalkaCatalogSnapshot _snapshot;
  bool _isLoading;

  WalkaCatalogSnapshot get snapshot => _snapshot;
  bool get isLoading => _isLoading;
  bool get isOffline => _snapshot.source != WalkaCatalogSource.remote;
  bool get isUsingCache => _snapshot.source == WalkaCatalogSource.cache;
  bool get isUsingBundledFallback =>
      _snapshot.source == WalkaCatalogSource.bundled;

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
    final WalkaCatalogSnapshot next = walkaPresentationSnapshot(
      await repository.load(),
    );
    _snapshot = next;
    WalkaAmazonPurchaseRegistry.replaceFromSnapshot(next);
    _isLoading = false;
    notifyListeners();
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
