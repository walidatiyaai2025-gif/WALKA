import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> acceptance;
  late Map<String, dynamic> admission;
  late String resolver;

  setUpAll(() {
    acceptance = jsonDecode(
      File('../docs/ui/PRODUCT_MEDIA_VISUAL_ACCEPTANCE.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    admission = jsonDecode(
      File('../docs/ui/PRODUCTION_SOURCE_ADMISSION.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    resolver = File(
      'lib/design_system/components/media/walka_product_media_resolver.dart',
    ).readAsStringSync();
  });

  test('Home Discovery PDP Favorites and Account/About each have explicit visual acceptance rows', () {
    final Set<String> screens = (acceptance['screens'] as List<dynamic>)
        .map((dynamic row) => row['screen'] as String)
        .toSet();
    expect(
      screens,
      equals(<String>{'Home', 'Discovery', 'PDP', 'Favorites', 'Account/About'}),
    );
  });

  test('all referenced acceptance masters stay under protected Images prefix', () {
    for (final dynamic row in acceptance['screens'] as List<dynamic>) {
      for (final dynamic reference in row['references'] as List<dynamic>) {
        expect(reference as String, startsWith('Images/'));
      }
      expect(row['status'], 'PENDING');
    }
  });

  test('cross-variant color and alpha edge checks remain pending real assets', () {
    expect(acceptance['crossVariant']['task'], 'VREL-086');
    expect(acceptance['crossVariant']['status'], 'PENDING');
    expect(acceptance['alphaEdges']['task'], 'VREL-087');
    expect(acceptance['alphaEdges']['status'], 'PENDING');
    expect(
      acceptance['alphaEdges']['checks'],
      containsAll(<String>['no white matte', 'no dark fringe', 'no halo']),
    );
  });

  test('baked-content contract explicitly rejects marketplace and unsupported claims', () {
    final List<dynamic> forbidden = acceptance['bakedContent']['forbidden'] as List<dynamic>;
    expect(forbidden, contains('price'));
    expect(forbidden, contains('rating'));
    expect(forbidden, contains('review count'));
    expect(forbidden, contains('marketplace navigation'));
    expect(forbidden, contains('unsupported leak-proof claim'));
    expect(forbidden, contains('cart or checkout UI'));
    expect(acceptance['bakedContent']['status'], 'PENDING');
  });

  test('source admission resolver and acceptance matrix reconcile the same five variants', () {
    final Set<String> admitted = (admission['variants'] as List<dynamic>)
        .map((dynamic row) => row['variantId'] as String)
        .toSet();
    final Set<String> accepted = <String>{
      for (final dynamic row in acceptance['screens'] as List<dynamic>)
        ...((row['requiredVariants'] as List<dynamic>).cast<String>()),
    };
    expect(admitted, equals(<String>{
      'drawer-organizer:white',
      'drawer-organizer:gray',
      'lunch-box:blue',
      'lunch-box:pink',
      'lunch-box:green',
    }));
    expect(accepted, containsAll(admitted));
    for (final String variantId in admitted) {
      expect(resolver, contains("'$variantId'"));
    }
  });

  test('protected reference guard is wired into CI with full-history checkout', () {
    final String workflow =
        File('../.github/workflows/flutter-preview.yml').readAsStringSync();
    final String guard =
        File('tool/guard_protected_reference_masters.sh').readAsStringSync();

    expect(workflow, contains('fetch-depth: 0'));
    expect(workflow, contains('Guard protected reference masters'));
    expect(workflow, contains('guard_protected_reference_masters.sh'));
    expect(guard, contains(":(top)Images/"));
    expect(guard, contains('WALKA_ALLOW_PROTECTED_IMAGES_MUTATION'));
  });

  test('protected guard passes a normal non-Images branch diff', () async {
    final ProcessResult result = await Process.run(
      'bash',
      <String>['tool/guard_protected_reference_masters.sh', 'HEAD^'],
    );
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(result.stdout, contains('Protected reference masters unchanged'));
  });
}
