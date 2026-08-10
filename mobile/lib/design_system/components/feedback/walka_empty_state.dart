import 'package:flutter/material.dart';

import '../../walka_theme.dart';
import '../cards/walka_surface_card.dart';

/// Shared WALKA empty-state composition for truthful, caller-owned messaging.
///
/// The primitive owns only presentation: premium surface, visual treatment,
/// centered hierarchy and optional action placement. Feature copy, destinations
/// and business behavior remain the caller's responsibility.
class WalkaEmptyState extends StatelessWidget {
  const WalkaEmptyState({
    required this.title,
    required this.body,
    this.visual,
    this.icon = Icons.inventory_2_outlined,
    this.actionLabel,
    this.onAction,
    this.actionKey,
    this.titleStyle,
    this.bodyStyle,
    this.padding = const EdgeInsets.fromLTRB(
      WalkaSpacing.lg,
      WalkaSpacing.xl,
      WalkaSpacing.lg,
      WalkaSpacing.lg,
    ),
    super.key,
  }) : assert(
          (actionLabel == null) == (onAction == null),
          'actionLabel and onAction must either both be provided or both be null.',
        );

  final String title;
  final String body;
  final Widget? visual;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Key? actionKey;
  final TextStyle? titleStyle;
  final TextStyle? bodyStyle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return WalkaSurfaceCard(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(child: visual ?? _DefaultEmptyVisual(icon: icon)),
          const SizedBox(height: WalkaSpacing.lg),
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: titleStyle ??
                  WalkaType.sectionTitle.copyWith(
                    fontSize: 24,
                    height: 1.15,
                  ),
            ),
          ),
          const SizedBox(height: WalkaSpacing.sm),
          Text(
            body,
            textAlign: TextAlign.center,
            style: bodyStyle ?? WalkaType.body.copyWith(fontSize: 13),
          ),
          if (onAction != null) ...<Widget>[
            const SizedBox(height: WalkaSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                key: actionKey,
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DefaultEmptyVisual extends StatelessWidget {
  const _DefaultEmptyVisual({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        key: const ValueKey<String>('walka-empty-state-default-visual'),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: WalkaColors.gold.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
            color: WalkaColors.gold.withValues(alpha: 0.35),
          ),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: WalkaColors.navy, size: 32),
      ),
    );
  }
}
