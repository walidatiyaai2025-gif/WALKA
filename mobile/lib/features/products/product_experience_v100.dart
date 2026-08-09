import 'package:flutter/material.dart';

import '../lunch/lunch_box_v6.dart';
import 'product_experience_v10.dart';

/// Final 1.0 Drawer Product Detail entry point.
///
/// UI-009 intentionally composes the released UI-008 Product Experience rather
/// than copying product specifications into another implementation. This keeps
/// gallery, share, Amazon routing, persistent favorites and Product Master copy
/// on one verified code path.
class WalkaDrawerProductDetailV100 extends StatelessWidget {
  const WalkaDrawerProductDetailV100({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  Widget build(BuildContext context) {
    return WalkaDrawerProductDetailV10(initialGray: initialGray);
  }
}

/// Final 1.0 Lunch Product Detail entry point.
///
/// The released V10 experience remains the source of truth for product facts
/// and usage/care language. UI-009 only provides the final public route.
class WalkaLunchProductDetailV100 extends StatelessWidget {
  const WalkaLunchProductDetailV100({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  Widget build(BuildContext context) {
    return WalkaLunchProductDetailV10(initialVariant: initialVariant);
  }
}
