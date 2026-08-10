import 'package:flutter/material.dart';

import '../../design_system/walka_shell.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import 'catalog_status_v130.dart';

/// DESIGN-006 wrapper that keeps the validated catalog content interactive
/// while presenting one shared loading/offline surface above legacy premium
/// pages.
///
/// The wrapped DESIGN-001/003 pages receive a delegating controller that masks
/// their legacy status banners only; snapshot, purchase routing and catalog
/// notifications continue to come from the real application controller.
class WalkaCatalogStateSurfaceV130 extends StatefulWidget {
  const WalkaCatalogStateSurfaceV130({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<WalkaCatalogStateSurfaceV130> createState() =>
      _WalkaCatalogStateSurfaceV130State();
}

class _WalkaCatalogStateSurfaceV130State
    extends State<WalkaCatalogStateSurfaceV130> {
  WalkaCatalogController? _source;
  _CatalogPresentationController? _presentation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final WalkaCatalogController source = WalkaCatalogScope.of(context);
    if (identical(source, _source)) return;

    _presentation?.dispose();
    _source = source;
    _presentation = _CatalogPresentationController(source);
  }

  @override
  void dispose() {
    _presentation?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogController source = _source!;
    final _CatalogPresentationController presentation = _presentation!;
    final bool showStatus = source.isLoading || source.isOffline;

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          if (showStatus)
            Padding(
              padding: EdgeInsets.fromLTRB(
                WalkaShellMetrics.horizontalGutter(context),
                8,
                WalkaShellMetrics.horizontalGutter(context),
                4,
              ),
              child: WalkaCatalogStatusBanner(controller: source),
            ),
          Expanded(
            child: WalkaCatalogScope(
              controller: presentation,
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogPresentationController extends WalkaCatalogController {
  _CatalogPresentationController(this.source)
      : super.presentationProxy() {
    source.addListener(notifyListeners);
  }

  final WalkaCatalogController source;

  @override
  WalkaCatalogSnapshot get snapshot => source.snapshot;

  // Legacy V121/V122 banners are masked because V130 renders one shared
  // surface outside the page. These values affect presentation only.
  @override
  bool get isLoading => false;

  @override
  bool get isOffline => false;

  @override
  bool get canRefresh => source.canRefresh;

  @override
  bool get isUsingCache => source.isUsingCache;

  @override
  bool get isUsingBundledFallback => source.isUsingBundledFallback;

  @override
  Future<void> load() => source.load();

  @override
  void dispose() {
    source.removeListener(notifyListeners);
    super.dispose();
  }
}
