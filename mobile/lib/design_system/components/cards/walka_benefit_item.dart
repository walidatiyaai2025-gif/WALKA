import 'package:flutter/material.dart';

import '../../walka_theme.dart';

enum WalkaBenefitItemLayout { stacked, compact }

/// Reusable icon/title/body unit for truthful WALKA benefit content.
///
/// The component deliberately owns presentation only; callers provide the
/// approved wording appropriate to the product or information surface.
class WalkaBenefitItem extends StatelessWidget {
  const WalkaBenefitItem({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
    this.layout = WalkaBenefitItemLayout.stacked,
    this.semanticLabel,
    this.iconColor = WalkaColors.gold,
    this.titleColor = WalkaColors.white,
    this.bodyColor = WalkaColors.white,
  });

  final IconData icon;
  final String title;
  final String body;
  final WalkaBenefitItemLayout layout;
  final String? semanticLabel;
  final Color iconColor;
  final Color titleColor;
  final Color bodyColor;

  Widget _icon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.14),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: iconColor),
    );
  }

  Widget _copy({required CrossAxisAlignment alignment}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: 13,
            height: 1.2,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: WalkaSpacing.xxs),
        Text(
          body,
          style: WalkaType.body.copyWith(
            color: bodyColor.withValues(alpha: 0.82),
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String resolvedSemanticLabel = semanticLabel ?? '$title. $body';

    final Widget content = layout == WalkaBenefitItemLayout.compact
        ? Row(
            key: const ValueKey<String>('walka-benefit-compact'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _icon(),
              const SizedBox(width: WalkaSpacing.sm),
              Expanded(child: _copy(alignment: CrossAxisAlignment.start)),
            ],
          )
        : Column(
            key: const ValueKey<String>('walka-benefit-stacked'),
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _icon(),
              const SizedBox(height: WalkaSpacing.sm),
              _copy(alignment: CrossAxisAlignment.start),
            ],
          );

    return Semantics(
      container: true,
      label: resolvedSemanticLabel,
      child: ExcludeSemantics(child: content),
    );
  }
}
