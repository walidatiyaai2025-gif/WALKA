import 'domain/walka_catalog.dart';

/// The domain snapshot has already passed [WalkaCatalogContract] validation.
/// Keep the validated server/bundled presentation intact so governed product
/// and variant visibility/order cannot be reintroduced by a legacy hardcoded
/// presentation adapter.
WalkaCatalogSnapshot walkaPresentationSnapshot(WalkaCatalogSnapshot source) {
  return source;
}
