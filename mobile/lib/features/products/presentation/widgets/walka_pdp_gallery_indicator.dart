import 'package:flutter/material.dart';

import '../../../../design_system/walka_theme.dart';

class WalkaPdpGalleryIndicator extends StatelessWidget {
  const WalkaPdpGalleryIndicator({
    required this.selectedIndex,
    required this.itemCount,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final int itemCount;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Row(
      key: const ValueKey<String>('walka-pdp-gallery-indicator'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, (int index) {
        final bool selected = selectedIndex == index;
        return Semantics(
          button: true,
          selected: selected,
          label: 'Gallery view ${index + 1}',
          child: InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(99),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AnimatedContainer(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  width: selected ? 26 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? WalkaColors.navy : WalkaColors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
