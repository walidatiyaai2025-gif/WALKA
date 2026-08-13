enum WalkaCatalogSource { remote, cache, bundled }

class WalkaStorefrontConfig {
  const WalkaStorefrontConfig({
    required this.brand,
    required this.release,
    required this.apiVersion,
    required this.purchaseMode,
  });

  final String brand;
  final String release;
  final String apiVersion;
  final String purchaseMode;

  factory WalkaStorefrontConfig.fromJson(Map<String, dynamic> json) {
    return WalkaStorefrontConfig(
      brand: _requiredString(json, 'brand'),
      release: _requiredString(json, 'release'),
      apiVersion: _requiredString(json, 'api_version'),
      purchaseMode: _requiredString(json, 'purchase_mode'),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'brand': brand,
        'release': release,
        'api_version': apiVersion,
        'purchase_mode': purchaseMode,
      };
}

class WalkaCatalogVariant {
  const WalkaCatalogVariant({
    required this.id,
    required this.color,
    required this.asin,
    required this.purchaseUrl,
    this.pantone,
  });

  final String id;
  final String color;
  final String asin;
  final String? pantone;
  final String purchaseUrl;

  Uri get purchaseUri {
    final Uri? uri = Uri.tryParse(purchaseUrl);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw FormatException('Invalid WALKA purchase URL for $id.');
    }
    return uri;
  }

  factory WalkaCatalogVariant.fromJson(Map<String, dynamic> json) {
    final Object? pantoneValue = json['pantone'];
    if (pantoneValue != null && pantoneValue is! String) {
      throw const FormatException('Variant pantone must be a string or null.');
    }

    final WalkaCatalogVariant variant = WalkaCatalogVariant(
      id: _requiredString(json, 'id'),
      color: _requiredString(json, 'color'),
      asin: _requiredString(json, 'asin'),
      pantone: pantoneValue as String?,
      purchaseUrl: _requiredString(json, 'purchase_url'),
    );
    variant.purchaseUri;
    return variant;
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'color': color,
        'asin': asin,
        'pantone': pantone,
        'purchase_url': purchaseUrl,
      };
}

class WalkaCatalogProduct {
  const WalkaCatalogProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.features,
    required this.facts,
    required this.variants,
    this.shortDescription,
    this.highlights = const <String>[],
    this.featured = false,
    this.presentationOrder = 0,
  });

  final String id;
  final String name;
  final String category;
  final List<String> features;
  final String? shortDescription;
  final List<String> highlights;
  final bool featured;
  final int presentationOrder;
  final Map<String, dynamic> facts;
  final List<WalkaCatalogVariant> variants;

  factory WalkaCatalogProduct.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawFeatures = _requiredList(json, 'features');
    final List<dynamic> rawVariants = _requiredList(json, 'variants');
    final Map<String, dynamic> facts = _requiredMap(json, 'facts');
    final Object? rawDescription = json['short_description'];
    if (rawDescription != null && rawDescription is! String) {
      throw const FormatException('short_description must be a string or null.');
    }
    final Object? rawHighlights = json['highlights'];
    if (rawHighlights != null && rawHighlights is! List) {
      throw const FormatException('highlights must be a list when present.');
    }
    final Object? rawFeatured = json['featured'];
    if (rawFeatured != null && rawFeatured is! bool) {
      throw const FormatException('featured must be a boolean when present.');
    }
    final Object? rawOrder = json['presentation_order'];
    if (rawOrder != null && (rawOrder is! int || rawOrder < 0)) {
      throw const FormatException('presentation_order must be a non-negative integer.');
    }

    final List<String> highlights = (rawHighlights as List<dynamic>? ?? const <dynamic>[])
        .map((dynamic value) {
      if (value is! String || value.trim().isEmpty) {
        throw const FormatException('Product highlights must be strings.');
      }
      return value;
    }).toList(growable: false);

    return WalkaCatalogProduct(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      category: _requiredString(json, 'category'),
      features: rawFeatures.map((dynamic value) {
        if (value is! String || value.trim().isEmpty) {
          throw const FormatException('Product features must be strings.');
        }
        return value;
      }).toList(growable: false),
      shortDescription: rawDescription == null || rawDescription.trim().isEmpty
          ? null
          : rawDescription.trim(),
      highlights: highlights,
      featured: rawFeatured as bool? ?? false,
      presentationOrder: rawOrder as int? ?? 0,
      facts: Map<String, dynamic>.unmodifiable(facts),
      variants: rawVariants.map((dynamic value) {
        if (value is! Map) {
          throw const FormatException('Product variants must be objects.');
        }
        return WalkaCatalogVariant.fromJson(Map<String, dynamic>.from(value));
      }).toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'category': category,
        'features': features,
        'short_description': shortDescription,
        'highlights': highlights,
        'featured': featured,
        'presentation_order': presentationOrder,
        'facts': facts,
        'variants': variants
            .map((WalkaCatalogVariant variant) => variant.toJson())
            .toList(growable: false),
      };
}

class WalkaCatalogPayload {
  const WalkaCatalogPayload({
    required this.products,
    required this.release,
    required this.apiVersion,
    required this.purchaseMode,
  });

  final List<WalkaCatalogProduct> products;
  final String release;
  final String apiVersion;
  final String purchaseMode;

  factory WalkaCatalogPayload.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawProducts = _requiredList(json, 'data');
    final Map<String, dynamic> meta = _requiredMap(json, 'meta');

    return WalkaCatalogPayload(
      products: rawProducts.map((dynamic value) {
        if (value is! Map) {
          throw const FormatException('Catalog products must be objects.');
        }
        return WalkaCatalogProduct.fromJson(Map<String, dynamic>.from(value));
      }).toList(growable: false),
      release: _requiredString(meta, 'release'),
      apiVersion: _requiredString(meta, 'api_version'),
      purchaseMode: _requiredString(meta, 'purchase_mode'),
    );
  }
}

class WalkaCatalogSnapshot {
  const WalkaCatalogSnapshot({
    required this.config,
    required this.products,
    required this.source,
    required this.fetchedAt,
  });

  final WalkaStorefrontConfig config;
  final List<WalkaCatalogProduct> products;
  final WalkaCatalogSource source;
  final DateTime fetchedAt;

  bool get isStale => source != WalkaCatalogSource.remote;

  Iterable<WalkaCatalogVariant> get variants sync* {
    for (final WalkaCatalogProduct product in products) {
      yield* product.variants;
    }
  }

  WalkaCatalogProduct? productById(String id) {
    for (final WalkaCatalogProduct product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  WalkaCatalogVariant? variantById(String id) {
    for (final WalkaCatalogVariant variant in variants) {
      if (variant.id == id) return variant;
    }
    return null;
  }

  WalkaCatalogSnapshot asSource(WalkaCatalogSource nextSource) {
    return WalkaCatalogSnapshot(
      config: config,
      products: products,
      source: nextSource,
      fetchedAt: fetchedAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'config': config.toJson(),
        'products': products
            .map((WalkaCatalogProduct product) => product.toJson())
            .toList(growable: false),
        'fetched_at': fetchedAt.toUtc().toIso8601String(),
      };

  factory WalkaCatalogSnapshot.fromJson(
    Map<String, dynamic> json, {
    WalkaCatalogSource source = WalkaCatalogSource.cache,
  }) {
    final Map<String, dynamic> rawConfig = _requiredMap(json, 'config');
    final List<dynamic> rawProducts = _requiredList(json, 'products');
    final String fetchedAt = _requiredString(json, 'fetched_at');
    final DateTime? parsedFetchedAt = DateTime.tryParse(fetchedAt);
    if (parsedFetchedAt == null) {
      throw const FormatException('Catalog fetched_at is invalid.');
    }

    return WalkaCatalogSnapshot(
      config: WalkaStorefrontConfig.fromJson(rawConfig),
      products: rawProducts.map((dynamic value) {
        if (value is! Map) {
          throw const FormatException('Cached products must be objects.');
        }
        return WalkaCatalogProduct.fromJson(Map<String, dynamic>.from(value));
      }).toList(growable: false),
      source: source,
      fetchedAt: parsedFetchedAt.toUtc(),
    );
  }
}

abstract final class WalkaCatalogContract {
  static const Set<String> allowedProductIds = <String>{
    'drawer-organizer',
    'stainless-steel-bento-lunch-box',
  };

  static const Map<String, Set<String>> allowedVariantIdsByProduct =
      <String, Set<String>>{
    'drawer-organizer': <String>{
      'drawer-organizer:white',
      'drawer-organizer:gray',
    },
    'stainless-steel-bento-lunch-box': <String>{
      'lunch-box:blue',
      'lunch-box:pink',
      'lunch-box:green',
    },
  };

  static void validate(WalkaCatalogSnapshot snapshot) {
    if (snapshot.config.brand != 'WALKA') {
      throw const FormatException('Unexpected catalog brand.');
    }
    if (snapshot.config.apiVersion != 'v1') {
      throw const FormatException('Unsupported WALKA API version.');
    }
    if (snapshot.config.purchaseMode != 'amazon_redirect') {
      throw const FormatException('Unsupported WALKA purchase mode.');
    }

    final Set<String> seenProducts = <String>{};
    int previousOrder = -1;
    String previousId = '';
    for (final WalkaCatalogProduct product in snapshot.products) {
      if (!allowedProductIds.contains(product.id) || !seenProducts.add(product.id)) {
        throw const FormatException('Catalog contains an unknown or duplicate product ID.');
      }
      if (product.presentationOrder < previousOrder ||
          (product.presentationOrder == previousOrder &&
              previousId.isNotEmpty &&
              product.id.compareTo(previousId) < 0)) {
        throw const FormatException('Catalog product presentation order is not deterministic.');
      }
      previousOrder = product.presentationOrder;
      previousId = product.id;

      final Set<String> allowedVariants =
          allowedVariantIdsByProduct[product.id] ?? const <String>{};
      final Set<String> seenVariants = <String>{};
      for (final WalkaCatalogVariant variant in product.variants) {
        if (!allowedVariants.contains(variant.id) || !seenVariants.add(variant.id)) {
          throw const FormatException('Catalog contains an invalid product variant identity.');
        }
        variant.purchaseUri;
      }
    }
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string.');
  }
  return value;
}

List<dynamic> _requiredList(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! List) {
    throw FormatException('$key must be a list.');
  }
  return List<dynamic>.from(value);
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! Map) {
    throw FormatException('$key must be an object.');
  }
  return Map<String, dynamic>.from(value);
}
