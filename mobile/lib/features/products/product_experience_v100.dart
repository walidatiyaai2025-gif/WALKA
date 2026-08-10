import 'package:flutter/material.dart';

import '../lunch/lunch_box_v6.dart';
import 'product_experience_v112.dart';

/// Final Drawer Product Detail entry point.
///
/// V112 preserves the released Product Master, Favorites and Amazon contracts
/// while composing the screen from independently tested PDP presentation atoms.
class WalkaDrawerProductDetailV100 extends StatelessWidget {
  const WalkaDrawerProductDetailV100({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  Widget build(BuildContext context) {
    return WalkaDrawerProductDetailV112(initialGray: initialGray);
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
    return WalkaLunchProductDetailV112(initialVariant: initialVariant);
  }
}
