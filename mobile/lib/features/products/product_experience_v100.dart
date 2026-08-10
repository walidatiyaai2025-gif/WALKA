import 'package:flutter/material.dart';

import '../lunch/lunch_box_v6.dart';
import 'product_experience_v110.dart';

/// Final Drawer Product Detail entry point.
///
/// DESIGN-004 promotes the premium V110 commerce surface while the verified
/// V10 implementation remains in the repository as the legacy Product Master
/// copy contract and regression reference. Amazon routing and persistent Drawer
/// favorites still use the same underlying services.
class WalkaDrawerProductDetailV100 extends StatelessWidget {
  const WalkaDrawerProductDetailV100({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  Widget build(BuildContext context) {
    return WalkaDrawerProductDetailV110(initialGray: initialGray);
  }
}

/// Final Lunch Product Detail entry point.
///
/// Product Master facts and approved usage/care language are preserved on the
/// premium V110 surface; purchase continues to hand off to the selected Amazon
/// listing through the existing commerce registry.
class WalkaLunchProductDetailV100 extends StatelessWidget {
  const WalkaLunchProductDetailV100({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  Widget build(BuildContext context) {
    return WalkaLunchProductDetailV110(initialVariant: initialVariant);
  }
}
