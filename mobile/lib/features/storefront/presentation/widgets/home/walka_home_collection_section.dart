import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

import 'walka_home_collection_card.dart';
import 'walka_home_featured_visual.dart';

class WalkaHomeCollectionSection extends StatelessWidget {
  const WalkaHomeCollectionSection({
    required this.firstVariantId,
    required this.secondVariantId,
    required this.firstSemanticLabel,
    required this.secondSemanticLabel,
    required this.onFirst,
    required this.onSecond,
    this.eyebrow = 'OUR COLLECTION',
    this.title = 'Everything in Its Place',
    super.key,
  });

  final String firstVariantId;
  final String secondVariantId;
  final String firstSemanticLabel;
  final String secondSemanticLabel;
  final VoidCallback onFirst;
  final VoidCallback onSecond;
  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final WalkaHomeFeaturedVisualSpec first =
        walkaHomeFeaturedVisualFor(firstVariantId);
    final WalkaHomeFeaturedVisualSpec second =
        walkaHomeFeaturedVisualFor(secondVariantId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          eyebrow,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: WalkaColors.gold,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontFamily: 'serif',
            fontSize: 27,
            height: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          key: const PageStorageKey<String>('home-reference-collection'),
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _FeaturedCollectionCard(
                spec: first,
                semanticLabel: firstSemanticLabel,
                onTap: onFirst,
              ),
              const SizedBox(width: 12),
              _FeaturedCollectionCard(
                spec: second,
                semanticLabel: secondSemanticLabel,
                onTap: onSecond,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturedCollectionCard extends StatelessWidget {
  const _FeaturedCollectionCard({
    required this.spec,
    required this.semanticLabel,
    required this.onTap,
  });

  final WalkaHomeFeaturedVisualSpec spec;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return WalkaHomeCollectionCard(
      key: ValueKey<String>('home-reference-${spec.variantId}-card'),
      variantId: spec.variantId,
      title: spec.title,
      subtitle: spec.subtitle,
      kind: spec.kind,
      primaryColor: spec.primaryColor,
      visualBackground: spec.backgroundColor,
      semanticLabel: semanticLabel,
      onTap: onTap,
    );
  }
}
