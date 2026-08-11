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

const List<int> _targetWidths = <int>[96, 160, 240, 384];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final MapEntry<String, String> entry in _released.entries) {
    for (final int targetWidth in _targetWidths) {
      testWidgets('${entry.key} decodes at ${targetWidth}px without failure',
          (WidgetTester tester) async {
        final ByteData data = await rootBundle.load(entry.value);
        final ui.Codec codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          targetWidth: targetWidth,
          allowUpscaling: false,
        );
        addTearDown(codec.dispose);
        final ui.FrameInfo frame = await codec.getNextFrame();
        addTearDown(frame.image.dispose);

        expect(frame.image.width, greaterThan(0));
        expect(frame.image.width, lessThanOrEqualTo(targetWidth));
        expect(frame.image.height, greaterThan(0));
      });
    }
  }
}
