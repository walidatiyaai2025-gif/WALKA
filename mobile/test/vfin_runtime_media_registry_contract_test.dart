import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _runtimeDart() {
  final StringBuffer buffer = StringBuffer();
  for (final FileSystemEntity entity
      in Directory('lib').listSync(recursive: true, followLinks: false)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    buffer
      ..writeln('// ${entity.path}')
      ..writeln(entity.readAsStringSync());
  }
  return buffer.toString();
}

void main() {
  const List<String> canonicalPaths = <String>[
    'assets/products/drawer/white.png',
    'assets/products/drawer/gray.png',
    'assets/products/lunch/blue.png',
    'assets/products/lunch/pink.png',
    'assets/products/lunch/green.png',
  ];

  test('runtime registry includes every exact canonical production-media path', () {
    final String runtime = _runtimeDart();
    for (final String path in canonicalPaths) {
      expect(runtime, contains(path), reason: path);
    }
  });

  test('runtime image loading never targets protected reference masters', () {
    final String runtime = _runtimeDart();
    expect(runtime, isNot(contains("Image.asset('Images/")));
    expect(runtime, isNot(contains('Image.asset("Images/')));
    expect(runtime, isNot(contains("AssetImage('Images/")));
    expect(runtime, isNot(contains('AssetImage("Images/')));
  });

  test('runtime does not hardcode local filesystem product-media paths', () {
    final String runtime = _runtimeDart();
    expect(runtime, isNot(contains('/mnt/data/')));
    expect(runtime, isNot(contains('C:\\\\')));
  });
}
