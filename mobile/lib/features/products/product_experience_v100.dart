import 'package:flutter/material.dart';

import '../lunch/lunch_box_v6.dart';
import 'product_experience_v111.dart';

/// Final Drawer Product Detail entry point.
///
/// The released V111 route identity is retained for compatibility while V111
/// delegates all rendering/behavior to the modular V112 implementation.
class WalkaDrawerProductDetailV100 extends StatelessWidget {
  const WalkaDrawerProductDetailV100({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  Widget build(BuildContext context) {
    return WalkaDrawerProductDetailV111(initialGray: initialGray);
  }
}

/// Final Lunch Product Detail entry point.
///
/// Product Master facts and approved usage/care language remain unchanged;
/// V111 is a compatibility wrapper over the modular V112 implementation.
class WalkaLunchProductDetailV100 extends StatelessWidget {
  const WalkaLunchProductDetailV100({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  Widget build(BuildContext context) {
    return WalkaLunchProductDetailV111(initialVariant: initialVariant);
  }
}
