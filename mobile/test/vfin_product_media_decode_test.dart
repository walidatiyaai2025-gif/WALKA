import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const Map<String, String> _released = <String, String>{
  'drawer-organizer:white': 'assets/products/drawer/white.png',
  'drawer-organizer:gray': 'assets/products/drawer/gray.png',
  'lunch-box:blue': 'assets/products/lunch/blue.png',
  'lunch-box:pink': 'assets/products/lunch/pink.png',
  'lunch-box:green': 'assets/products/lunch/green.png',
};

Map<String, Map<String, dynamic>> _provenanceByVariant() {
  final Map<String, dynamic> root = jsonDecode(
    File('../docs/ui/PRODUCTION_ASSET_PROVENANCE.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  return <String, Map<String, dynamic>>{
    for (final dynamic raw in root['variants'] as List<dynamic>)
      (raw as Map<String, dynamic>)['variantId'] as String: raw,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final MapEntry<String, String> entry in _released.entries) {
    testWidgets('${entry.key} canonical asset is bundle-decodable',
        (WidgetTester tester) async {
      final ByteData data = await rootBundle.load(entry.value);
      expect(data.lengthInBytes, greaterThan(0));

      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      addTearDown(codec.dispose);
      final ui.FrameInfo frame = await codec.getNextFrame();
      addTearDown(frame.image.dispose);
      expect(frame.image.width, greaterThan(0));
      expect(frame.image.height, greaterThan(0));

      final Map<String, dynamic> row = _provenanceByVariant()[entry.key]!;
      if (row['lifecycleState'] == 'ADMITTED') {
        expect(frame.image.width, row['width']);
        expect(frame.image.height, row['height']);
      }
    });
  }
}
