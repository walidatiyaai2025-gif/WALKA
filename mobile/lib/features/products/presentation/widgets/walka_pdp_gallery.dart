import 'package:flutter/material.dart';

import '../../../../design_system/walka_product_visual.dart';
import 'walka_pdp_gallery_indicator.dart';
import 'walka_pdp_gallery_viewport.dart';

class WalkaPdpGallery extends StatefulWidget {
  const WalkaPdpGallery({
    required this.variantId,
    required this.kind,
    required this.primaryColor,
    required this.surface,
    required this.semanticLabel,
    required this.onExpand,
    super.key,
  });

  final String variantId;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;
  final String semanticLabel;
  final ValueChanged<int> onExpand;

  @override
  State<WalkaPdpGallery> createState() => _WalkaPdpGalleryState();
}

class _WalkaPdpGalleryState extends State<WalkaPdpGallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Column(
      children: <Widget>[
        WalkaPdpGalleryViewport(
          controller: _controller,
          selectedIndex: _index,
          variantId: widget.variantId,
          kind: widget.kind,
          primaryColor: widget.primaryColor,
          surface: widget.surface,
          semanticLabel: widget.semanticLabel,
          onPageChanged: (int value) => setState(() => _index = value),
          onExpand: widget.onExpand,
        ),
        const SizedBox(height: 6),
        WalkaPdpGalleryIndicator(
          selectedIndex: _index,
          itemCount: WalkaPdpGalleryViewport.pageCount,
          onSelected: (int value) {
            _controller.animateToPage(
              value,
              duration: reduceMotion
                  ? Duration.zero
                  : const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
            );
          },
        ),
      ],
    );
  }
}
