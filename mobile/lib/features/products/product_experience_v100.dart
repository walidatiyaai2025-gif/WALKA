import 'package:flutter/material.dart';

import '../lunch/lunch_box_v6.dart';
import 'product_experience_v111.dart';

/// Final Drawer Product Detail entry point.
///
/// DESIGN-007B.3 promotes the approved Android-reference V111 composition while
/// preserving the existing Product Master, favorites and Amazon commerce
/// contracts behind the stable V100 entry point.
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
/// purchase continues to hand off to the selected official Amazon listing.
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
