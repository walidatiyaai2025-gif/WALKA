import 'package:flutter/material.dart';

import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_theme.dart';

import 'walka_home_featured_visual.dart';

class WalkaHomeSmallChanges extends StatelessWidget {
  const WalkaHomeSmallChanges({
    required this.variantId,
    required this.productSemanticLabel,
    required this.onTap,
    this.title = 'Small Changes,\nBetter Living',
    this.body = 'Simple solutions that bring order, beauty and peace of mind.',
    super.key,
  });

  final String variantId;
  final String productSemanticLabel;
  final VoidCallback onTap;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final WalkaHomeFeaturedVisualSpec visualSpec =
        walkaHomeFeaturedVisualFor(variantId);

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool stack = constraints.maxWidth < 350 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.15;
        final Widget copy = Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: WalkaColors.gold,
                    ),
                    child: Icon(
                      visualSpec.kind.name == 'lunchBox'
                          ? Icons.lunch_dining_rounded
                          : Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 17,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: const TextStyle(
                  color: WalkaColors.muted,
                  fontSize: 10.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );

        final Widget visual = SizedBox(
          height: stack ? 126 : 164,
          child: ColoredBox(
            color: visualSpec.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: WalkaResolvedProductMedia(
                variantId: visualSpec.variantId,
                kind: visualSpec.kind,
                primaryColor: visualSpec.primaryColor,
                backgroundColor: visualSpec.backgroundColor,
                compact: true,
                mediaSurface: WalkaProductMediaSurface.home,
                semanticLabel: productSemanticLabel,
              ),
            ),
          ),
        );

        return Material(
          color: const Color(0xFFF8F2E7),
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: stack
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[copy, visual],
                  )
                : IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(flex: 5, child: copy),
                        Expanded(flex: 4, child: visual),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
