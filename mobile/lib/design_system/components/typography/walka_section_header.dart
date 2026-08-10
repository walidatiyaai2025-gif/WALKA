import 'package:flutter/material.dart';

import '../../walka_theme.dart';

enum WalkaSectionHeaderAlignment { start, center }

/// Reusable premium section heading used across WALKA presentation surfaces.
///
/// The component owns the shared eyebrow/title hierarchy while allowing an
/// optional trailing action. Screen-specific copy stays with the feature; visual
/// styling stays centralized in the design system.
class WalkaSectionHeader extends StatelessWidget {
  const WalkaSectionHeader({
    required this.title,
    super.key,
    this.eyebrow,
    this.action,
    this.alignment = WalkaSectionHeaderAlignment.center,
    this.eyebrowSpacing = 6,
    this.actionSpacing = 12,
  });

  final String title;
  final String? eyebrow;
  final Widget? action;
  final WalkaSectionHeaderAlignment alignment;
  final double eyebrowSpacing;
  final double actionSpacing;

  @override
  Widget build(BuildContext context) {
    final bool centered = alignment == WalkaSectionHeaderAlignment.center;
    final CrossAxisAlignment crossAxisAlignment = centered
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final TextAlign textAlign = centered ? TextAlign.center : TextAlign.start;

    final TextStyle eyebrowStyle = WalkaType.eyebrow.copyWith(
      color: WalkaColors.gold,
      fontSize: 10,
      height: 1,
      fontWeight: FontWeight.w900,
      letterSpacing: 0.8,
    );
    final TextStyle titleStyle = WalkaType.sectionTitle.copyWith(
      color: WalkaColors.navy,
      fontSize: 27,
      height: 1.1,
      fontWeight: FontWeight.w600,
    );

    final Widget titleWidget = Semantics(
      header: true,
      child: Text(
        title,
        textAlign: textAlign,
        style: titleStyle,
      ),
    );

    return Column(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (eyebrow != null) ...<Widget>[
          Text(
            eyebrow!,
            textAlign: textAlign,
            style: eyebrowStyle,
          ),
          SizedBox(height: eyebrowSpacing),
        ],
        if (action == null)
          titleWidget
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(child: titleWidget),
              SizedBox(width: actionSpacing),
              action!,
            ],
          ),
      ],
    );
  }
}
