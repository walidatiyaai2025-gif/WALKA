import 'package:flutter/material.dart';

import 'walka_test_harness.dart';

/// Deterministic capture surface shared by visual/golden regression cases.
///
/// Goldens can opt into [RepaintBoundary] by key without re-declaring device,
/// platform, text-scale, safe-area or reduced-motion MediaQuery state.
class WalkaGoldenHarness extends StatelessWidget {
  const WalkaGoldenHarness({
    required this.device,
    required this.child,
    super.key,
    this.textScale = 1,
    this.disableAnimations = true,
    this.boundaryKey = const ValueKey<String>('walka-golden-boundary'),
  });

  final WalkaTestDevice device;
  final Widget child;
  final double textScale;
  final bool disableAnimations;
  final Key boundaryKey;

  @override
  Widget build(BuildContext context) {
    return WalkaTestHarness(
      device: device,
      textScale: textScale,
      disableAnimations: disableAnimations,
      child: RepaintBoundary(
        key: boundaryKey,
        child: ColoredBox(
          color: const Color(0xFFFFFEFC),
          child: child,
        ),
      ),
    );
  }
}
