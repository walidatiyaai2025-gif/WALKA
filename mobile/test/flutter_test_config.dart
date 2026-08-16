import 'dart:async';

import 'package:walka/features/catalog/catalog_state.dart';

import 'support/legacy_visual_catalog_fixture.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  WalkaCatalogController.presentationInitialSnapshotFactory =
      legacyVisualCatalogFixture;
  await testMain();
}
