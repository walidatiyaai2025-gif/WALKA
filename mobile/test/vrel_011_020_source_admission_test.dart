import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> admission;
  late List<dynamic> variants;
  late String resolverSource;

  setUpAll(() {
    admission = jsonDecode(
      File('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    variants = admission['variants'] as List<dynamic>;
    resolverSource = File(
      'lib/design_system/components/media/walka_product_media_resolver.dart',
    ).readAsStringSync();
  });

  test('source admission schema uses only APPROVED BLOCKED REPLACE states', () {
    expect(
      admission['allowedSourceStates'],
      equals(<dynamic>['APPROVED', 'BLOCKED', 'REPLACE']),
    );
    final Set<String> allowed =
        (admission['allowedSourceStates'] as List<dynamic>)
            .cast<String>()
            .toSet();
    for (final dynamic row in variants) {
      expect(allowed, contains(row['sourceState']));
      expect((row['reason'] as String).trim(), isNotEmpty);
      expect((row['unblockAction'] as String).trim(), isNotEmpty);
    }
  });

  test('registry covers exactly the five released product variants', () {
    expect(
      variants.map((dynamic row) => row['variantId']).toSet(),
      equals(<String>{
        'drawer-organizer:white',
        'drawer-organizer:gray',
        'lunch-box:blue',
        'lunch-box:pink',
        'lunch-box:green',
      }),
    );
  });

  test('protected Images references are never declared as runtime product sources',
      () {
    for (final dynamic row in variants) {
      final String source = row['sourceFilename'] as String;
      final String target = row['canonicalPath'] as String;
      expect(source.startsWith('Images/'), isFalse);
      expect(target.startsWith('Images/'), isFalse);
      expect(target, startsWith('assets/products/'));
    }
  });

  test('source admission IDs and canonical paths agree with production resolver',
      () {
    for (final dynamic row in variants) {
      expect(resolverSource, contains("'${row['variantId']}'"));
      expect(resolverSource, contains("'${row['canonicalPath']}'"));
    }
  });

  test('Gray stays blocked while the other primary sources stay approved', () {
    final Map<String, dynamic> byId = <String, dynamic>{
      for (final dynamic row in variants) row['variantId'] as String: row,
    };
    expect(byId['drawer-organizer:gray']['sourceState'], 'BLOCKED');
    expect(byId['drawer-organizer:white']['sourceState'], 'APPROVED');
    expect(byId['lunch-box:blue']['sourceState'], 'APPROVED');
    expect(byId['lunch-box:pink']['sourceState'], 'APPROVED');
    expect(byId['lunch-box:green']['sourceState'], 'APPROVED');
  });

  test('only Drawer White confirms a canonical export at this stage', () {
    final Map<String, dynamic> byId = <String, dynamic>{
      for (final dynamic row in variants) row['variantId'] as String: row,
    };
    expect(byId['drawer-organizer:white']['canonicalExportPresent'], isTrue);
    for (final String id in <String>[
      'drawer-organizer:gray',
      'lunch-box:blue',
      'lunch-box:pink',
      'lunch-box:green',
    ]) {
      expect(byId[id]['canonicalExportPresent'], isFalse, reason: id);
    }
  });
}
