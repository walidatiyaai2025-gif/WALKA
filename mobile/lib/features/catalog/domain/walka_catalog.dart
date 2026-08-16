enum WalkaCatalogSource { remote, cache, unavailable, bundled }

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

class WalkaCatalogCategory {
  const WalkaCatalogCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final int sortOrder;

  factory WalkaCatalogCategory.fromJson(Map<String, dynamic> json) {
    final Object? order = json['sort_order'];
    if (order is! int || order < 0) {
      throw const FormatException('Category sort_order must be a non-negative integer.');
    }
    return WalkaCatalogCategory(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      sortOrder: order,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'sort_order': sortOrder,
      };
}

class WalkaCatalogVariant {
  const WalkaCatalogVariant({
    required this.id,
    required this.color,
    required this.asin,
    required this.purchaseUrl,
    this.pantone,
    this.swatchHex,
  });

  final String id;
  final String color;
  final String asin;
  final String? pantone;
  final String? swatchHex;
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
    final Object? swatchValue = json['swatch_hex'];
    if (swatchValue != null &&
        (swatchValue is! String ||
            !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(swatchValue))) {
      throw const FormatException('Variant swatch_hex must be #RRGGBB or null.');
    }

    final WalkaCatalogVariant variant = WalkaCatalogVariant(
      id: _requiredString(json, 'id'),
      color: _requiredString(json, 'color'),
      asin: _requiredString(json, 'asin'),
      pantone: pantoneValue as String?,
      swatchHex: swatchValue as String?,
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
        'swatch_hex': swatchHex,
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
  });

  final String id;
  final String name;
  final String category;
  final List<String> features;
  final Map<String, dynamic> facts;
  final List<WalkaCatalogVariant> variants;

  factory WalkaCatalogProduct.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawFeatures = _requiredList(json, 'features');
    final List<dynamic> rawVariants = _requiredList(json, 'variants');
    final Map<String, dynamic> facts = _requiredMap(json, 'facts');

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
        'facts': facts,
        'variants': variants
            .map((WalkaCatalogVariant variant) => variant.toJson())
            .toList(growable: false),
      };
}

class WalkaCatalogPayload {
  const WalkaCatalogPayload({
    required this.products,
    required this.categories,
    required this.release,
    required this.apiVersion,
    required this.purchaseMode,
  });

  final List<WalkaCatalogProduct> products;
  final List<WalkaCatalogCategory> categories;
  final String release;
  final String apiVersion;
  final String purchaseMode;

  factory WalkaCatalogPayload.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawProducts = _requiredList(json, 'data');
    final Map<String, dynamic> meta = _requiredMap(json, 'meta');
    final List<WalkaCatalogProduct> products = rawProducts.map((dynamic value) {
      if (value is! Map) {
        throw const FormatException('Catalog products must be objects.');
      }
      return WalkaCatalogProduct.fromJson(Map<String, dynamic>.from(value));
    }).toList(growable: false);

    final Object? categoryValue = meta['categories'];
    final List<WalkaCatalogCategory> categories;
    if (categoryValue == null) {
      final List<String> ids = products.map((p) => p.category).toSet().toList()..sort();
      categories = <WalkaCatalogCategory>[
        for (int index = 0; index < ids.length; index++)
          WalkaCatalogCategory(id: ids[index], name: ids[index], sortOrder: index),
      ];
    } else if (categoryValue is List) {
      categories = categoryValue.map((dynamic value) {
        if (value is! Map) {
          throw const FormatException('Catalog categories must be objects.');
        }
        return WalkaCatalogCategory.fromJson(Map<String, dynamic>.from(value));
      }).toList(growable: false);
    } else {
      throw const FormatException('Catalog categories must be a list.');
    }

    return WalkaCatalogPayload(
      products: products,
      categories: categories,
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
    this.categories = const <WalkaCatalogCategory>[],
  });

  final WalkaStorefrontConfig config;
  final List<WalkaCatalogCategory> categories;
  final List<WalkaCatalogProduct> products;
  final WalkaCatalogSource source;
  final DateTime fetchedAt;

  bool get isStale => source != WalkaCatalogSource.remote;
  bool get isAvailable => products.isNotEmpty;

  Iterable<WalkaCatalogVariant> get variants sync* {
    for (final WalkaCatalogProduct product in products) {
      yield* product.variants;
    }
  }

  WalkaCatalogCategory? categoryById(String id) {
    for (final WalkaCatalogCategory category in categories) {
      if (category.id == id) return category;
    }
    return null;
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
      categories: categories,
      products: products,
      source: nextSource,
      fetchedAt: fetchedAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'config': config.toJson(),
        'categories': categories.map((category) => category.toJson()).toList(growable: false),
        'products': products.map((product) => product.toJson()).toList(growable: false),
        'fetched_at': fetchedAt.toUtc().toIso8601String(),
      };

  factory WalkaCatalogSnapshot.fromJson(
    Map<String, dynamic> json, {
    WalkaCatalogSource source = WalkaCatalogSource.cache,
  }) {
    final Map<String, dynamic> rawConfig = _requiredMap(json, 'config');
    final List<dynamic> rawProducts = _requiredList(json, 'products');
    final Object? rawCategoriesValue = json['categories'];
    final String fetchedAt = _requiredString(json, 'fetched_at');
    final DateTime? parsedFetchedAt = DateTime.tryParse(fetchedAt);
    if (parsedFetchedAt == null) {
      throw const FormatException('Catalog fetched_at is invalid.');
    }

    final List<WalkaCatalogProduct> products = rawProducts.map((dynamic value) {
      if (value is! Map) {
        throw const FormatException('Cached products must be objects.');
      }
      return WalkaCatalogProduct.fromJson(Map<String, dynamic>.from(value));
    }).toList(growable: false);

    final List<WalkaCatalogCategory> categories;
    if (rawCategoriesValue is List) {
      categories = rawCategoriesValue.map((dynamic value) {
        if (value is! Map) {
          throw const FormatException('Cached categories must be objects.');
        }
        return WalkaCatalogCategory.fromJson(Map<String, dynamic>.from(value));
      }).toList(growable: false);
    } else {
      final List<String> ids = products.map((p) => p.category).toSet().toList()..sort();
      categories = <WalkaCatalogCategory>[
        for (int index = 0; index < ids.length; index++)
          WalkaCatalogCategory(id: ids[index], name: ids[index], sortOrder: index),
      ];
    }

    return WalkaCatalogSnapshot(
      config: WalkaStorefrontConfig.fromJson(rawConfig),
      categories: categories,
      products: products,
      source: source,
      fetchedAt: parsedFetchedAt.toUtc(),
    );
  }
}

abstract final class WalkaCatalogContract {
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
    if (snapshot.source != WalkaCatalogSource.unavailable && snapshot.products.isEmpty) {
      throw const FormatException('Catalog contains no visible products.');
    }

    final Set<String> categoryIds = <String>{};
    for (final WalkaCatalogCategory category in snapshot.categories) {
      if (!categoryIds.add(category.id)) {
        throw const FormatException('Catalog contains duplicate category IDs.');
      }
    }

    final Set<String> productIds = <String>{};
    final Set<String> variantIds = <String>{};
    for (final WalkaCatalogProduct product in snapshot.products) {
      if (!productIds.add(product.id)) {
        throw const FormatException('Catalog contains duplicate product IDs.');
      }
      if (categoryIds.isNotEmpty && !categoryIds.contains(product.category)) {
        throw FormatException('Product ${product.id} references an unknown category.');
      }
      if (product.variants.isEmpty) {
        throw FormatException('Product ${product.id} has no visible variants.');
      }
      for (final WalkaCatalogVariant variant in product.variants) {
        if (!variantIds.add(variant.id)) {
          throw const FormatException('Catalog contains duplicate variant IDs.');
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
