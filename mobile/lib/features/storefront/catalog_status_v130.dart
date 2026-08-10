import 'package:flutter/material.dart';

import '../../design_system/walka_motion.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';

enum WalkaCatalogFeedbackKind { loading, cache, bundled }

/// One catalog resilience surface shared by Home, Search and Categories.
///
/// Refresh never blocks the product UI: the current validated snapshot remains
/// browsable while this banner communicates where the visible data came from.
class WalkaCatalogStatusBanner extends StatelessWidget {
  const WalkaCatalogStatusBanner({
    required this.controller,
    super.key,
  });

  final WalkaCatalogController controller;

  static WalkaCatalogFeedbackKind kindFor(WalkaCatalogController controller) {
    if (controller.isLoading) return WalkaCatalogFeedbackKind.loading;
    if (controller.isUsingCache) return WalkaCatalogFeedbackKind.cache;
    return WalkaCatalogFeedbackKind.bundled;
  }

  @override
  Widget build(BuildContext context) {
    final WalkaCatalogFeedbackKind kind = kindFor(controller);
    final _CatalogFeedbackCopy copy = _copyFor(kind);
    final bool reduceMotion = WalkaMotion.reduceMotion(context);

    return Semantics(
      key: ValueKey<String>('walka-catalog-status-${kind.name}'),
      container: true,
      liveRegion: true,
      label: '${copy.title}. ${copy.body}',
      child: ExcludeSemantics(
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: WalkaColors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: WalkaColors.line),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: WalkaColors.navyDark.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 2,
                child: kind == WalkaCatalogFeedbackKind.loading && !reduceMotion
                    ? const LinearProgressIndicator(
                        backgroundColor: Color(0xFFF2E9CF),
                        color: WalkaColors.gold,
                        minHeight: 2,
                      )
                    : const ColoredBox(color: WalkaColors.gold),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 11),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2E9CF),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        copy.icon,
                        size: 17,
                        color: WalkaColors.navy,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            copy.title,
                            style: const TextStyle(
                              color: WalkaColors.navy,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            copy.body,
                            style: const TextStyle(
                              color: WalkaColors.muted,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_CatalogFeedbackCopy _copyFor(WalkaCatalogFeedbackKind kind) {
  return switch (kind) {
    WalkaCatalogFeedbackKind.loading => const _CatalogFeedbackCopy(
        title: 'Refreshing the WALKA catalog',
        body: 'Keep browsing while we check for the latest verified catalog.',
        icon: Icons.sync_rounded,
      ),
    WalkaCatalogFeedbackKind.cache => const _CatalogFeedbackCopy(
        title: 'Offline · saved catalog',
        body: 'Showing the last validated WALKA catalog stored on this device.',
        icon: Icons.cloud_off_outlined,
      ),
    WalkaCatalogFeedbackKind.bundled => const _CatalogFeedbackCopy(
        title: 'Offline · built-in catalog',
        body: 'Showing WALKA’s validated built-in catalog until connectivity returns.',
        icon: Icons.inventory_2_outlined,
      ),
  };
}

class _CatalogFeedbackCopy {
  const _CatalogFeedbackCopy({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;
}
