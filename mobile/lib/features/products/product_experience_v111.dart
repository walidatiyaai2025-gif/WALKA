import 'package:flutter/material.dart';

import '../lunch/lunch_box_v6.dart';
import 'product_experience_v112.dart';

/// Compatibility surface retained for released routes/tests.
///
/// Rendering and behavior are owned by the modular V112 implementation.
class WalkaDrawerProductDetailV111 extends StatelessWidget {
  const WalkaDrawerProductDetailV111({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  Widget build(BuildContext context) {
    return WalkaDrawerProductDetailV112(initialGray: initialGray);
  }
}

/// Compatibility surface retained for released routes/tests.
///
/// Rendering and behavior are owned by the modular V112 implementation.
class WalkaLunchProductDetailV111 extends StatelessWidget {
  const WalkaLunchProductDetailV111({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  Widget build(BuildContext context) {
    return WalkaLunchProductDetailV112(initialVariant: initialVariant);
  }
}
