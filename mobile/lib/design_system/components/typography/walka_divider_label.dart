import 'package:flutter/material.dart';

import '../../walka_theme.dart';

/// Reusable section divider/title treatment for WALKA secondary screens.
class WalkaDividerLabel extends StatelessWidget {
  const WalkaDividerLabel({
    required this.label,
    super.key,
    this.showLeadingRule = false,
    this.showTrailingRule = true,
    this.textAlign = TextAlign.left,
  });

  final String label;
  final bool showLeadingRule;
  final bool showTrailingRule;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final Widget text = Flexible(
      child: Semantics(
        header: true,
        child: Text(
          label.toUpperCase(),
          textAlign: textAlign,
          style: WalkaType.eyebrow.copyWith(
            color: WalkaColors.navy,
            letterSpacing: 1.25,
          ),
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (showLeadingRule) ...<Widget>[
          const Expanded(child: Divider(color: WalkaColors.line)),
          const SizedBox(width: WalkaSpacing.sm),
        ],
        text,
        if (showTrailingRule) ...<Widget>[
          const SizedBox(width: WalkaSpacing.sm),
          const Expanded(child: Divider(color: WalkaColors.line)),
        ],
      ],
    );
  }
}
