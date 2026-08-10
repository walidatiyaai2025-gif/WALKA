import 'package:flutter/material.dart';

import '../../../../design_system/components/media/walka_product_media_resolver.dart';
import '../../../../design_system/walka_product_visual.dart';
import '../../../../design_system/walka_theme.dart';

class WalkaPdpFullscreenGallery extends StatefulWidget {
  const WalkaPdpFullscreenGallery({
    required this.initialIndex,
    required this.title,
    required this.variantId,
    required this.kind,
    required this.primaryColor,
    required this.surface,
    super.key,
  });

  final int initialIndex;
  final String title;
  final String variantId;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;

  @override
  State<WalkaPdpFullscreenGallery> createState() =>
      _WalkaPdpFullscreenGalleryState();
}

class _WalkaPdpFullscreenGalleryState extends State<WalkaPdpFullscreenGallery> {
  late final PageController _controller =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey<String>('walka-pdp-fullscreen-gallery'),
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.title),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: 3,
                onPageChanged: (int value) => setState(() => _index = value),
                itemBuilder: (BuildContext context, int index) {
                  final Widget media = index == 0
                      ? WalkaResolvedProductMedia(
                          variantId: widget.variantId,
                          kind: widget.kind,
                          primaryColor: widget.primaryColor,
                          backgroundColor: widget.surface,
                          semanticLabel:
                              '${widget.title} primary fullscreen product image',
                        )
                      : WalkaProductVisual(
                          kind: widget.kind,
                          primaryColor: widget.primaryColor,
                          backgroundColor: widget.surface,
                          semanticLabel:
                              '${widget.title} illustrative fullscreen fallback view ${index + 1}; approved secondary product photography pending',
                        );
                  return InteractiveViewer(
                    key: ValueKey<String>('walka-pdp-zoom-$index'),
                    minScale: 0.8,
                    maxScale: 3.2,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: media,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Text(
                '${_index + 1} / 3',
                style: const TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
