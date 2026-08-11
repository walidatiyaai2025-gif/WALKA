import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _allRuntimeDart() {
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
  const List<String> releasedVariants = <String>[
    'drawer-organizer:white',
    'drawer-organizer:gray',
    'lunch-box:blue',
    'lunch-box:pink',
    'lunch-box:green',
  ];

  test('runtime code knows every exact canonical production-media path', () {
    final String runtime = _allRuntimeDart();
    for (final String path in canonicalPaths) {
      expect(runtime, contains(path), reason: 'Missing runtime mapping for $path');
    }
  });

  test('runtime code keeps every released variant identity explicit', () {
    final String runtime = _allRuntimeDart();
    for (final String variant in releasedVariants) {
      expect(runtime, contains(variant), reason: 'Missing runtime variant $variant');
    }
  });

  test('protected reference masters are never runtime Image assets', () {
    final String runtime = _allRuntimeDart();
    expect(runtime, isNot(contains("Image.asset('Images/")));
    expect(runtime, isNot(contains('Image.asset("Images/')));
    expect(runtime, isNot(contains("AssetImage('Images/")));
    expect(runtime, isNot(contains('AssetImage("Images/')));
  });

  test('product directories remain directory-bundled for deterministic variants', () {
    final String pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/products/drawer/'));
    expect(pubspec, contains('assets/products/lunch/'));
  });
}
