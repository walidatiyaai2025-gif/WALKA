import 'package:flutter/material.dart';

import 'package:walka/design_system/components/media/walka_product_media_resolver.dart';
import 'package:walka/design_system/walka_product_visual.dart';
import 'package:walka/design_system/walka_theme.dart';

class WalkaHomeSmallChanges extends StatelessWidget {
  const WalkaHomeSmallChanges({
    required this.drawerSemanticLabel,
    required this.onTap,
    super.key,
  });

  final String drawerSemanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                    child: const Icon(
                      Icons.grid_view_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Small Changes,\nBetter Living',
                      style: TextStyle(
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
              const Text(
                'Simple solutions that bring order, beauty and peace of mind.',
                style: TextStyle(
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
            color: const Color(0xFFEDE6DA),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: WalkaResolvedProductMedia(
                variantId: 'drawer-organizer:white',
                kind: WalkaProductVisualKind.drawerOrganizer,
                primaryColor: const Color(0xFFF7F4EC),
                backgroundColor: const Color(0xFFEDE6DA),
                compact: true,
                semanticLabel: drawerSemanticLabel,
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
