import 'package:flutter/foundation.dart';

const Set<String> _allowedRemoteMediaMime = <String>{
  'image/png',
  'image/jpeg',
  'image/webp',
};

const Map<String, List<String>> walkaSupportedProductVariants =
    <String, List<String>>{
  'drawer-organizer': <String>[
    'drawer-organizer:white',
    'drawer-organizer:gray',
  ],
  'stainless-steel-bento-lunch-box': <String>[
    'lunch-box:blue',
    'lunch-box:pink',
    'lunch-box:green',
  ],
};

const Map<String, ({String purpose, String? categoryId})>
    walkaSupportedRemoteMediaSlots =
    <String, ({String purpose, String? categoryId})>{
  'home.hero': (purpose: 'home', categoryId: null),
  'home.editorial.small_changes': (purpose: 'editorial', categoryId: null),
  'category:drawer-organization': (
    purpose: 'category',
    categoryId: 'drawer-organization',
  ),
  'category:lunch': (purpose: 'category', categoryId: 'lunch'),
};

@immutable
class WalkaRemoteMediaItem {
  const WalkaRemoteMediaItem({
    required this.mediaId,
    required this.semanticLabel,
    required this.mime,
    required this.width,
    required this.height,
    required this.sha256,
  });

  final String mediaId;
  final String semanticLabel;
  final String mime;
  final int width;
  final int height;
  final String sha256;

  String get cacheKey => 'walka-media-$mediaId-$sha256';

  String get fileExtension => switch (mime) {
        'image/png' => 'png',
        'image/jpeg' => 'jpg',
        'image/webp' => 'webp',
        _ => 'bin',
      };

  factory WalkaRemoteMediaItem.fromJson(Map<String, dynamic> json) {
    final String mediaId = _requiredString(json, 'media_id', maxLength: 64);
    if (!RegExp(r'^[0-9A-HJKMNP-TV-Z]{26}$').hasMatch(mediaId)) {
      throw const FormatException('Remote media ID must be a canonical ULID.');
    }
    final String semanticLabel =
        _requiredString(json, 'semantic_label', maxLength: 160);
    final Object? canonicalObject = json['canonical'];
    if (canonicalObject is! Map) {
      throw const FormatException('Remote media canonical metadata is required.');
    }
    final Map<String, dynamic> canonical =
        Map<String, dynamic>.from(canonicalObject);
    final String mime = _requiredString(canonical, 'mime', maxLength: 32);
    if (!_allowedRemoteMediaMime.contains(mime)) {
      throw const FormatException('Unsupported remote media MIME type.');
    }
    final int width = _requiredInt(canonical, 'width', min: 1, max: 8192);
    final int height = _requiredInt(canonical, 'height', min: 1, max: 8192);
    final String sha256 =
        _requiredString(canonical, 'sha256', maxLength: 64).toLowerCase();
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(sha256)) {
      throw const FormatException('Remote media SHA-256 is invalid.');
    }

    return WalkaRemoteMediaItem(
      mediaId: mediaId,
      semanticLabel: semanticLabel,
      mime: mime,
      width: width,
      height: height,
      sha256: sha256,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'media_id': mediaId,
        'semantic_label': semanticLabel,
        'canonical': <String, dynamic>{
          'mime': mime,
          'width': width,
          'height': height,
          'sha256': sha256,
        },
      };
}

@immutable
class WalkaRemoteProductMediaPayload {
  WalkaRemoteProductMediaPayload({
    required this.revisionToken,
    required Map<String, List<WalkaRemoteMediaItem>> galleriesByVariant,
  }) : galleriesByVariant = Map<String, List<WalkaRemoteMediaItem>>.unmodifiable(
          galleriesByVariant.map(
            (String key, List<WalkaRemoteMediaItem> value) => MapEntry(
              key,
              List<WalkaRemoteMediaItem>.unmodifiable(value),
            ),
          ),
        );

  final String revisionToken;
  final Map<String, List<WalkaRemoteMediaItem>> galleriesByVariant;

  factory WalkaRemoteProductMediaPayload.fromApiJson(
    Map<String, dynamic> root,
  ) {
    _validateEnvelope(root);
    final Map<String, dynamic> data = _requiredMap(root, 'data');
    if (_requiredInt(data, 'schema_version', min: 1, max: 1) != 1) {
      throw const FormatException('Unsupported product media schema.');
    }
    final String revisionToken = _requiredSha(data, 'revision_token');
    final List<dynamic> products = _requiredList(data, 'products');
    if (products.length != walkaSupportedProductVariants.length) {
      throw const FormatException('Product media identity set is incomplete.');
    }

    final Map<String, List<WalkaRemoteMediaItem>> galleries =
        <String, List<WalkaRemoteMediaItem>>{};
    final Set<String> seenProducts = <String>{};
    for (final Object? rawProduct in products) {
      if (rawProduct is! Map) {
        throw const FormatException('Product media entry must be an object.');
      }
      final Map<String, dynamic> product = Map<String, dynamic>.from(rawProduct);
      final String productId =
          _requiredString(product, 'product_id', maxLength: 96);
      final List<String>? expectedVariants =
          walkaSupportedProductVariants[productId];
      if (expectedVariants == null || !seenProducts.add(productId)) {
        throw const FormatException('Unknown or duplicate product media identity.');
      }

      final List<dynamic> variants = _requiredList(product, 'variants');
      if (variants.length != expectedVariants.length) {
        throw FormatException('Variant media identity set is incomplete for $productId.');
      }
      final Set<String> seenVariants = <String>{};
      for (final Object? rawVariant in variants) {
        if (rawVariant is! Map) {
          throw const FormatException('Variant media entry must be an object.');
        }
        final Map<String, dynamic> variant = Map<String, dynamic>.from(rawVariant);
        final String variantId =
            _requiredString(variant, 'variant_id', maxLength: 96);
        if (!expectedVariants.contains(variantId) || !seenVariants.add(variantId)) {
          throw FormatException('Unknown or duplicate variant media identity: $variantId.');
        }
        final String source =
            _requiredString(variant, 'gallery_source', maxLength: 32);
        if (source != 'variant' && source != 'product_fallback') {
          throw const FormatException('Unsupported variant gallery source.');
        }
        galleries[variantId] = _parseMediaItems(
          _requiredList(variant, 'gallery'),
          maxItems: 12,
        );
      }
      if (!setEquals(seenVariants, expectedVariants.toSet())) {
        throw FormatException('Variant media identity set mismatch for $productId.');
      }
    }
    if (!setEquals(seenProducts, walkaSupportedProductVariants.keys.toSet())) {
      throw const FormatException('Product media identity set mismatch.');
    }

    return WalkaRemoteProductMediaPayload(
      revisionToken: revisionToken,
      galleriesByVariant: galleries,
    );
  }

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'revision_token': revisionToken,
        'galleries_by_variant': galleriesByVariant.map(
          (String key, List<WalkaRemoteMediaItem> value) =>
              MapEntry(key, value.map((WalkaRemoteMediaItem item) => item.toJson()).toList()),
        ),
      };

  factory WalkaRemoteProductMediaPayload.fromCacheJson(
    Map<String, dynamic> json,
  ) {
    final String revisionToken = _requiredSha(json, 'revision_token');
    final Map<String, dynamic> raw = _requiredMap(json, 'galleries_by_variant');
    if (!setEquals(raw.keys.toSet(),
        walkaSupportedProductVariants.values.expand((List<String> ids) => ids).toSet())) {
      throw const FormatException('Cached product media identity set mismatch.');
    }
    return WalkaRemoteProductMediaPayload(
      revisionToken: revisionToken,
      galleriesByVariant: raw.map(
        (String key, Object? value) => MapEntry(
          key,
          _parseMediaItems(_asList(value, 'cached gallery'), maxItems: 12),
        ),
      ),
    );
  }
}

@immutable
class WalkaRemoteSurfaceMediaPayload {
  WalkaRemoteSurfaceMediaPayload({
    required this.revisionToken,
    required Map<String, List<WalkaRemoteMediaItem>> itemsBySlot,
  }) : itemsBySlot = Map<String, List<WalkaRemoteMediaItem>>.unmodifiable(
          itemsBySlot.map(
            (String key, List<WalkaRemoteMediaItem> value) => MapEntry(
              key,
              List<WalkaRemoteMediaItem>.unmodifiable(value),
            ),
          ),
        );

  final String revisionToken;
  final Map<String, List<WalkaRemoteMediaItem>> itemsBySlot;

  factory WalkaRemoteSurfaceMediaPayload.fromApiJson(Map<String, dynamic> root) {
    _validateEnvelope(root);
    final Map<String, dynamic> data = _requiredMap(root, 'data');
    if (_requiredInt(data, 'schema_version', min: 1, max: 1) != 1) {
      throw const FormatException('Unsupported surface media schema.');
    }
    final String revisionToken = _requiredSha(data, 'revision_token');
    final List<dynamic> slots = _requiredList(data, 'slots');
    if (slots.length != walkaSupportedRemoteMediaSlots.length) {
      throw const FormatException('Surface media slot set is incomplete.');
    }

    final Map<String, List<WalkaRemoteMediaItem>> itemsBySlot =
        <String, List<WalkaRemoteMediaItem>>{};
    for (final Object? rawSlot in slots) {
      if (rawSlot is! Map) {
        throw const FormatException('Surface media slot must be an object.');
      }
      final Map<String, dynamic> slot = Map<String, dynamic>.from(rawSlot);
      final String slotKey = _requiredString(slot, 'slot_key', maxLength: 96);
      final ({String purpose, String? categoryId})? definition =
          walkaSupportedRemoteMediaSlots[slotKey];
      if (definition == null || itemsBySlot.containsKey(slotKey)) {
        throw const FormatException('Unknown or duplicate surface media slot.');
      }
      if (_requiredString(slot, 'purpose', maxLength: 32) != definition.purpose) {
        throw FormatException('Surface media purpose mismatch for $slotKey.');
      }
      final Object? categoryId = slot['category_id'];
      if (categoryId != definition.categoryId) {
        throw FormatException('Surface media category identity mismatch for $slotKey.');
      }
      itemsBySlot[slotKey] = _parseMediaItems(
        _requiredList(slot, 'items'),
        maxItems: 1,
      );
    }
    if (!setEquals(itemsBySlot.keys.toSet(), walkaSupportedRemoteMediaSlots.keys.toSet())) {
      throw const FormatException('Surface media slot identity set mismatch.');
    }

    return WalkaRemoteSurfaceMediaPayload(
      revisionToken: revisionToken,
      itemsBySlot: itemsBySlot,
    );
  }

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'revision_token': revisionToken,
        'items_by_slot': itemsBySlot.map(
          (String key, List<WalkaRemoteMediaItem> value) =>
              MapEntry(key, value.map((WalkaRemoteMediaItem item) => item.toJson()).toList()),
        ),
      };

  factory WalkaRemoteSurfaceMediaPayload.fromCacheJson(Map<String, dynamic> json) {
    final String revisionToken = _requiredSha(json, 'revision_token');
    final Map<String, dynamic> raw = _requiredMap(json, 'items_by_slot');
    if (!setEquals(raw.keys.toSet(), walkaSupportedRemoteMediaSlots.keys.toSet())) {
      throw const FormatException('Cached surface media slot set mismatch.');
    }
    return WalkaRemoteSurfaceMediaPayload(
      revisionToken: revisionToken,
      itemsBySlot: raw.map(
        (String key, Object? value) => MapEntry(
          key,
          _parseMediaItems(_asList(value, 'cached slot'), maxItems: 1),
        ),
      ),
    );
  }
}

enum WalkaRemoteMediaSource { remote, cache, bundled }

@immutable
class WalkaRemoteMediaSnapshot {
  const WalkaRemoteMediaSnapshot({
    required this.products,
    required this.surfaces,
    required this.source,
    required this.fetchedAt,
  });

  final WalkaRemoteProductMediaPayload products;
  final WalkaRemoteSurfaceMediaPayload surfaces;
  final WalkaRemoteMediaSource source;
  final DateTime fetchedAt;

  List<WalkaRemoteMediaItem> galleryForVariant(String variantId) =>
      products.galleriesByVariant[variantId] ?? const <WalkaRemoteMediaItem>[];

  WalkaRemoteMediaItem? firstForVariant(String variantId) {
    final List<WalkaRemoteMediaItem> gallery = galleryForVariant(variantId);
    return gallery.isEmpty ? null : gallery.first;
  }

  WalkaRemoteMediaItem? firstForSlot(String slotKey) {
    final List<WalkaRemoteMediaItem> items =
        surfaces.itemsBySlot[slotKey] ?? const <WalkaRemoteMediaItem>[];
    return items.isEmpty ? null : items.first;
  }
}

void _validateEnvelope(Map<String, dynamic> root) {
  final Map<String, dynamic> meta = _requiredMap(root, 'meta');
  if (_requiredString(meta, 'api_version', maxLength: 8) != 'v1' ||
      _requiredString(meta, 'binary_delivery', maxLength: 40) !=
          'canonical_by_media_id') {
    throw const FormatException('Unsupported remote media delivery contract.');
  }
}

List<WalkaRemoteMediaItem> _parseMediaItems(
  List<dynamic> raw, {
  required int maxItems,
}) {
  if (raw.length > maxItems) {
    throw FormatException('Remote media list exceeds maximum $maxItems.');
  }
  final List<WalkaRemoteMediaItem> items = <WalkaRemoteMediaItem>[];
  final Set<String> ids = <String>{};
  for (final Object? value in raw) {
    if (value is! Map) {
      throw const FormatException('Remote media item must be an object.');
    }
    final WalkaRemoteMediaItem item =
        WalkaRemoteMediaItem.fromJson(Map<String, dynamic>.from(value));
    if (!ids.add(item.mediaId)) {
      throw const FormatException('Duplicate remote media ID in one gallery.');
    }
    items.add(item);
  }
  return List<WalkaRemoteMediaItem>.unmodifiable(items);
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! Map) throw FormatException('$key must be an object.');
  return Map<String, dynamic>.from(value);
}

List<dynamic> _requiredList(Map<String, dynamic> json, String key) =>
    _asList(json[key], key);

List<dynamic> _asList(Object? value, String label) {
  if (value is! List) throw FormatException('$label must be a list.');
  return List<dynamic>.from(value);
}

String _requiredString(
  Map<String, dynamic> json,
  String key, {
  required int maxLength,
}) {
  final Object? value = json[key];
  if (value is! String || value.trim().isEmpty || value.trim().length > maxLength) {
    throw FormatException('$key must be a bounded non-empty string.');
  }
  return value.trim();
}

String _requiredSha(Map<String, dynamic> json, String key) {
  final String value = _requiredString(json, key, maxLength: 64).toLowerCase();
  if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(value)) {
    throw FormatException('$key must be a SHA-256 digest.');
  }
  return value;
}

int _requiredInt(
  Map<String, dynamic> json,
  String key, {
  required int min,
  required int max,
}) {
  final Object? value = json[key];
  if (value is! int || value < min || value > max) {
    throw FormatException('$key must be between $min and $max.');
  }
  return value;
}
