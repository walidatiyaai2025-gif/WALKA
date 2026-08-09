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

    expect(
      v10,
      contains("_SpecRowV10(label: 'Colors', value: 'White · Gray')"),
    );
    expect(v10, isNot(contains("value: '1.72 lb'")));

    expect(
      v10,
      contains(
        "_SpecRowV10(label: 'Lid & gasket', value: 'Dishwasher · top rack')",
      ),
    );
    expect(
      v10,
      isNot(
        contains("_SpecRowV10(label: 'Lid & gasket', value: 'Hand wash')"),
      ),
    );
    expect(
      v10,
      contains(
        "_SpecRowV10(label: 'Microwave', value: 'PP outer only · remove steel tray & lid')",
      ),
    );

    expect(
      legacyLunch,
      contains("'Lid and silicone gasket: dishwasher safe, top rack.'"),
    );
    expect(
      legacyLunch,
      contains(
        "'PP outer body is microwave safe after removing the stainless tray, lid and silicone gasket.'",
      ),
    );
    expect(
      legacyLunch,
      isNot(contains("'Lid and silicone gasket: hand wash.'")),
    );

    final String master = await File('../docs/PRODUCT_MASTER.md').readAsString();
    expect(master, contains('Do not publish a product weight'));
    expect(
      master,
      contains('Lid and silicone gasket: dishwasher safe on the top rack'),
    );
    expect(
      master,
      contains(
        'PP outer body: microwave safe only after removing the stainless tray, lid, and silicone gasket',
      ),
    );
  });
}
