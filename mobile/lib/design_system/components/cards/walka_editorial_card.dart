import 'package:flutter/material.dart';

import '../../walka_theme.dart';
import 'walka_surface_card.dart';

/// Reusable editorial card for WALKA storytelling surfaces.
///
/// Feature copy, imagery and actions remain owned by the caller. This atom
/// centralizes only the premium hierarchy and spacing contract.
class WalkaEditorialCard extends StatelessWidget {
  const WalkaEditorialCard({
    required this.title,
    required this.body,
    super.key,
    this.eyebrow,
    this.visual,
    this.action,
    this.padding = const EdgeInsets.all(WalkaSpacing.md),
    this.textAlign = TextAlign.start,
  });

  final String title;
  final String body;
  final String? eyebrow;
  final Widget? visual;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final bool centered = textAlign == TextAlign.center;
    final CrossAxisAlignment crossAxisAlignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return WalkaSurfaceCard(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: <Widget>[
          if (visual != null) ...<Widget>[
            visual!,
            const SizedBox(height: WalkaSpacing.md),
          ],
          if (eyebrow != null) ...<Widget>[
            Text(
              eyebrow!,
              textAlign: textAlign,
              style: WalkaType.eyebrow.copyWith(
                fontSize: 10,
                height: 1,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.9,
              ),
            ),
            const SizedBox(height: WalkaSpacing.xs),
          ],
          Semantics(
            header: true,
            child: Text(
              title,
              textAlign: textAlign,
              style: WalkaType.sectionTitle.copyWith(
                fontSize: 22,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: WalkaSpacing.xs),
          Text(
            body,
            textAlign: textAlign,
            style: WalkaType.body,
          ),
          if (action != null) ...<Widget>[
            const SizedBox(height: WalkaSpacing.md),
            action!,
          ],
        ],
      ),
    );
  }
}
