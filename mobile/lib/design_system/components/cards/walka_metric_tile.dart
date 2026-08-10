import 'package:flutter/material.dart';

import '../../walka_theme.dart';

enum WalkaMetricTileAlignment { start, center }

/// Compact value/label unit for truthful released-state metrics.
///
/// The widget owns only visual hierarchy and semantics. Callers remain
/// responsible for supplying real values from released application state.
class WalkaMetricTile extends StatelessWidget {
  const WalkaMetricTile({
    required this.value,
    required this.label,
    super.key,
    this.supportingText,
    this.alignment = WalkaMetricTileAlignment.center,
    this.semanticLabel,
  });

  final String value;
  final String label;
  final String? supportingText;
  final WalkaMetricTileAlignment alignment;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bool centered = alignment == WalkaMetricTileAlignment.center;
    final CrossAxisAlignment crossAxisAlignment =
        centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final TextAlign textAlign = centered ? TextAlign.center : TextAlign.start;
    final String resolvedSemanticLabel = semanticLabel ??
        '$label, $value${supportingText == null ? '' : ', $supportingText'}';

    return Semantics(
      container: true,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: <Widget>[
            Text(
              value,
              textAlign: textAlign,
              style: WalkaType.sectionTitle.copyWith(
                color: WalkaColors.navy,
                fontSize: 24,
                height: 1.05,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: WalkaSpacing.xxs),
            Text(
              label,
              textAlign: textAlign,
              style: const TextStyle(
                color: WalkaColors.text,
                fontSize: 11,
                height: 1.2,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.35,
              ),
            ),
            if (supportingText != null) ...<Widget>[
              const SizedBox(height: WalkaSpacing.xxs),
              Text(
                supportingText!,
                textAlign: textAlign,
                style: WalkaType.body.copyWith(
                  fontSize: 11.5,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
