import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/content/domain/walka_home_banner_content.dart';

class WalkaHomeBanner extends StatelessWidget {
  const WalkaHomeBanner({
    required this.content,
    required this.onBrowse,
    required this.onSearch,
    super.key,
  });

  final WalkaHomeBannerContent content;
  final VoidCallback onBrowse;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final VoidCallback? action = switch (content.ctaAction) {
      WalkaHomeBannerAction.none => null,
      WalkaHomeBannerAction.browse => onBrowse,
      WalkaHomeBannerAction.search => onSearch,
    };

    return Semantics(
      container: true,
      label: '${content.eyebrow}. ${content.title}. ${content.body}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: WalkaColors.navy,
          borderRadius: BorderRadius.circular(20),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final bool compact = constraints.maxWidth < 460 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.15;
              final Widget copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    content.eyebrow,
                    style: const TextStyle(
                      color: WalkaColors.gold,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    content.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'serif',
                      fontSize: 20,
                      height: 1.08,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    content.body,
                    style: const TextStyle(
                      color: Color(0xFFDCE5EC),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              );

              final Widget? cta = action == null
                  ? null
                  : TextButton.icon(
                      key: const ValueKey<String>('home-banner-cta'),
                      onPressed: action,
                      style: TextButton.styleFrom(
                        foregroundColor: WalkaColors.gold,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: Text(
                        content.ctaLabel!,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    copy,
                    if (cta != null) ...<Widget>[
                      const SizedBox(height: 5),
                      Align(alignment: Alignment.centerLeft, child: cta),
                    ],
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: copy),
                  if (cta != null) ...<Widget>[
                    const SizedBox(width: 14),
                    cta,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
