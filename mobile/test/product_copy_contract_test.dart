import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('product UI copy follows docs/PRODUCT_MASTER.md', () async {
    final String v10 = await File(
      'lib/features/products/product_experience_v10.dart',
    ).readAsString();
    final String legacyLunch = await File(
      'lib/features/lunch/lunch_box_v6.dart',
    ).readAsString();
    final String master = await File('../docs/PRODUCT_MASTER.md').readAsString();

    expect(master, contains('Product weight: 1.72 lb'));
    expect(
      v10,
      contains("_SpecRowV10(label: 'Weight', value: '1.72 lb')"),
    );

    expect(
      master,
      contains('SUS304 stainless tray: dishwasher safe on the top rack; not microwave safe.'),
    );
    expect(
      v10,
      contains("_SpecRowV10(label: 'Steel tray', value: 'Dishwasher · top rack')"),
    );
    expect(
      legacyLunch,
      contains("'Stainless steel tray: dishwasher, top rack.'"),
    );

    expect(master, contains('Lid and silicone gasket: hand wash.'));
    expect(
      v10,
      contains("_SpecRowV10(label: 'Lid & gasket', value: 'Hand wash')"),
    );
    expect(
      legacyLunch,
      contains("'Lid and silicone gasket: hand wash.'"),
    );

    expect(
      master,
      contains('PP outer body: microwave safe without the stainless steel tray.'),
    );
    expect(
      v10,
      contains("_SpecRowV10(label: 'Microwave', value: 'Remove stainless tray')"),
    );
    expect(
      legacyLunch,
      contains("'PP body may be used in the microwave without the steel tray.'"),
    );

    expect(master, contains('Best for dry & semi-wet foods'));
    expect(master, contains('Not intended for liquids'));
    expect(master, contains('Carry upright'));
    expect(v10, contains('Best for dry & semi-wet foods. Not intended for liquids. Carry upright.'));
    expect(legacyLunch, contains('Best for dry & semi-wet foods. Not intended for liquids. Carry upright.'));

    expect(
      v10.toLowerCase(),
      isNot(contains('fully leakproof')),
    );
    expect(
      legacyLunch.toLowerCase(),
      isNot(contains('fully leakproof')),
    );
  });
}
