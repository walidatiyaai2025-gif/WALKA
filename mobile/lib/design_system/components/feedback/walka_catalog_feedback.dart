import 'package:flutter/material.dart';

import '../../walka_theme.dart';
import '../cards/walka_surface_card.dart';

enum WalkaCatalogFeedbackKind {
  loading,
  cached,
  bundledFallback,
  offline,
}

/// Presentation-only feedback for catalog loading and availability states.
class WalkaCatalogFeedback extends StatelessWidget {
  const WalkaCatalogFeedback({
    required this.kind,
    super.key,
    this.title,
    this.body,
    this.onRetry,
    this.retryLabel = 'TRY AGAIN',
    this.compact = false,
  });

  final WalkaCatalogFeedbackKind kind;
  final String? title;
  final String? body;
  final VoidCallback? onRetry;
  final String retryLabel;
  final bool compact;

  String get _title => title ?? switch (kind) {
        WalkaCatalogFeedbackKind.loading => 'Refreshing catalog',
        WalkaCatalogFeedbackKind.cached => 'Showing saved catalog',
        WalkaCatalogFeedbackKind.bundledFallback => 'Catalog unavailable',
        WalkaCatalogFeedbackKind.offline => 'Catalog is offline',
      };

  String get _body => body ?? switch (kind) {
        WalkaCatalogFeedbackKind.loading =>
          'The latest Dashboard catalog data is being checked.',
        WalkaCatalogFeedbackKind.cached =>
          'The last validated Dashboard catalog is available while the latest version is unavailable.',
        WalkaCatalogFeedbackKind.bundledFallback =>
          'No remote or last-known-good Dashboard catalog is available. No built-in products are substituted.',
        WalkaCatalogFeedbackKind.offline =>
          'Catalog refresh is unavailable right now.',
      };

  IconData get _icon => switch (kind) {
        WalkaCatalogFeedbackKind.loading => Icons.sync_rounded,
        WalkaCatalogFeedbackKind.cached => Icons.inventory_2_outlined,
        WalkaCatalogFeedbackKind.bundledFallback => Icons.inventory_2_outlined,
        WalkaCatalogFeedbackKind.offline => Icons.cloud_off_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final String semanticLabel = '$_title. $_body';

    return Semantics(
      container: true,
      liveRegion: true,
      label: semanticLabel,
      child: ExcludeSemantics(
        child: WalkaSurfaceCard(
          padding: EdgeInsets.all(compact ? WalkaSpacing.sm : WalkaSpacing.md),
          surfaceColor: WalkaColors.ivory,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 32,
                height: 32,
                child: kind == WalkaCatalogFeedbackKind.loading
                    ? const Padding(
                        padding: EdgeInsets.all(6),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_icon, color: WalkaColors.navy, size: 24),
              ),
              const SizedBox(width: WalkaSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      _title,
                      style: WalkaType.sectionTitle.copyWith(
                        fontSize: compact ? 17 : 19,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: WalkaSpacing.xxs),
                    Text(
                      _body,
                      style: WalkaType.body.copyWith(fontSize: compact ? 12 : 13),
                    ),
                    if (onRetry != null) ...<Widget>[
                      const SizedBox(height: WalkaSpacing.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(retryLabel),
                        ),
                      ),
                    ],
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
