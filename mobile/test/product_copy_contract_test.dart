import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('final product UI copy follows docs/PRODUCT_MASTER.md', () async {
    final String master = await File('../docs/PRODUCT_MASTER.md').readAsString();
    final String finalProductUi = await File(
      'lib/features/products/product_experience_v100.dart',
    ).readAsString();
    final String finalStorefront = await File(
      'lib/features/storefront/storefront_v101.dart',
    ).readAsString();

    expect(master, contains('Product weight: 1.72 lb'));
    expect(master, contains('Packaging: 13.46 × 15.16 × 2.36 in'));
    expect(master, contains('Outer body: BPA-free PP'));
    expect(master, contains('stainless sauce cup with lid'));
    expect(master, contains('Lid and silicone gasket: hand wash'));
    expect(master, contains('dishwasher safe on the top rack'));
    expect(
      master,
      contains('PP outer body: microwave safe without the stainless steel tray'),
    );
    expect(master, contains('Secure Lock | Helps Prevent Spills'));
    expect(master, contains('Best for dry & semi-wet foods'));
    expect(master, contains('Not intended for liquids'));
    expect(master, contains('Carry upright'));

    expect(finalProductUi, contains("('Product weight', '1.72 lb')"));
    expect(
      finalProductUi,
      contains("('Packaging', '13.46 × 15.16 × 2.36 in')"),
    );
    expect(finalProductUi, contains("('Outer body', 'BPA-free PP')"));
    expect(finalProductUi, contains("('Lid & gasket', 'Hand wash')"));
    expect(
      finalProductUi,
      contains("('SUS304 tray', 'Dishwasher safe · top rack')"),
    );
    expect(
      finalProductUi,
      contains("('PP outer body', 'Microwave safe without steel tray')"),
    );
    expect(finalProductUi, contains('Secure Lock | Helps Prevent Spills'));
    expect(finalProductUi, contains('Best for dry & semi-wet foods'));
    expect(finalProductUi, contains('Not intended for liquids'));
    expect(finalProductUi, contains('Carry upright'));

    expect(finalStorefront, contains('Hand wash the lid and silicone gasket'));
    expect(finalStorefront, contains('stainless sauce cup with lid'));
    expect(finalStorefront, isNot(contains('WalkaProductDetailV2')));
    expect(finalStorefront, isNot(contains('WalkaLunchProductDetailV6')));
  });
}
