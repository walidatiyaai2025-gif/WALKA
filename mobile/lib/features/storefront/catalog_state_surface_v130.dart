import 'package:flutter/material.dart';

import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../catalog/domain/walka_catalog.dart';
import 'catalog_status_v130.dart';

/// Shared production catalog boundary. Legacy premium compositions are rendered
/// only when a validated remote or last-known-good Dashboard catalog exists.
class WalkaCatalogStateSurfaceV130 extends StatefulWidget {
  const WalkaCatalogStateSurfaceV130({required this.child, super.key});

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
    final bool unavailable = source.isUnavailable && !source.isLoading;
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
            child: unavailable
                ? Center(
                    key: const ValueKey<String>('walka-catalog-unavailable'),
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.inventory_2_outlined, size: 42, color: WalkaColors.navy),
                          const SizedBox(height: 14),
                          const Text(
                            'Catalog unavailable',
                            style: TextStyle(color: WalkaColors.navy, fontSize: 18, fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'Connect to load the Dashboard catalog. No built-in products or colors are substituted.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: WalkaColors.muted, height: 1.45),
                          ),
                          if (source.canRefresh) ...<Widget>[
                            const SizedBox(height: 16),
                            FilledButton(onPressed: source.load, child: const Text('Retry')),
                          ],
                        ],
                      ),
                    ),
                  )
                : WalkaCatalogScope(
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
  _CatalogPresentationController(this.source) : super.presentationProxy() {
    source.addListener(notifyListeners);
  }

  final WalkaCatalogController source;

  @override
  WalkaCatalogSnapshot get snapshot => source.snapshot;

  @override
  bool get isLoading => false;

  @override
  bool get isOffline => false;

  @override
  bool get canRefresh => source.canRefresh;

  @override
  bool get isUsingCache => source.isUsingCache;

  @override
  bool get isUnavailable => source.isUnavailable;

  @override
  bool get isUsingBundledFallback => false;

  @override
  Future<void> load() => source.load();

  @override
  void dispose() {
    source.removeListener(notifyListeners);
    super.dispose();
  }
}
