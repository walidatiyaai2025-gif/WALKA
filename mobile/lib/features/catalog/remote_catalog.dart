import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String walkaDrawerProductId = 'drawer-organizer';
const String walkaDrawerWhiteVariantId = 'drawer-organizer:white';
const String walkaDrawerGrayVariantId = 'drawer-organizer:gray';
const String walkaLunchProductId = 'stainless-steel-bento-lunch-box';
const String walkaLunchBlueVariantId = 'lunch-box:blue';
const String walkaLunchPinkVariantId = 'lunch-box:pink';
const String walkaLunchGreenVariantId = 'lunch-box:green';

const Set<String> walkaRequiredVariantIds = <String>{
  walkaDrawerWhiteVariantId,
  walkaDrawerGrayVariantId,
  walkaLunchBlueVariantId,
  walkaLunchPinkVariantId,
  walkaLunchGreenVariantId,
};

enum WalkaCatalogSource { remote, cache, bundled }

class WalkaCatalogVariant {
  const WalkaCatalogVariant({
    required this.id,
    required this.color,
    required this.asin,
    required this.purchaseUri,
    this.pantone,
  });

  final String id;
  final String color;
  final String asin;
  final Uri purchaseUri;
  final String? pantone;

  factory WalkaCatalogVariant.fromJson(Map<String, dynamic> json) {
    final String id = _requiredString(json, 'id');
    final String color = _requiredString(json, 'color');
    final String asin = _requiredString(json, 'asin');
    final String purchaseUrl = _requiredString(json, 'purchase_url');
    final Uri? purchaseUri = Uri.tryParse(purchaseUrl);
    if (purchaseUri == null || !purchaseUri.hasScheme) {
      throw const FormatException('Invalid WALKA purchase URL.');
    }

    return WalkaCatalogVariant(
      id: id,
      color: color,
      asin: asin,
      purchaseUri: purchaseUri,
      pantone: json['pantone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'color': color,
        'asin': asin,
        'pantone': pantone,
        'purchase_url': purchaseUri.toString(),
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
    return WalkaCatalogProduct(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      category: _requiredString(json, 'category'),
      features: _stringList(json['features'], 'features'),
      facts: _map(json['facts'], 'facts'),
      variants: _mapList(json['variants'], 'variants')
          .map(WalkaCatalogVariant.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'category': category,
        'features': features,
        'facts': facts,
        'variants': variants.map((variant) => variant.toJson()).toList(),
      };
}

class WalkaCatalogSnapshot {
  const WalkaCatalogSnapshot({
    required this.apiVersion,
    required this.release,
    required this.purchaseMode,
    required this.products,
    required this.fetchedAt,
    required this.source,
  });

  final String apiVersion;
  final String release;
  final String purchaseMode;
  final List<WalkaCatalogProduct> products;
  final DateTime fetchedAt;
  final WalkaCatalogSource source;

  Iterable<WalkaCatalogVariant> get variants =>
      products.expand((product) => product.variants);

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

  WalkaCatalogSnapshot withSource(WalkaCatalogSource value) {
    return WalkaCatalogSnapshot(
      apiVersion: apiVersion,
      release: release,
      purchaseMode: purchaseMode,
      products: products,
      fetchedAt: fetchedAt,
      source: value,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'api_version': apiVersion,
        'release': release,
        'purchase_mode': purchaseMode,
        'fetched_at': fetchedAt.toUtc().toIso8601String(),
        'products': products.map((product) => product.toJson()).toList(),
      };

  factory WalkaCatalogSnapshot.fromCacheJson(Map<String, dynamic> json) {
    return WalkaCatalogSnapshot(
      apiVersion: _requiredString(json, 'api_version'),
      release: _requiredString(json, 'release'),
      purchaseMode: _requiredString(json, 'purchase_mode'),
      fetchedAt: DateTime.parse(_requiredString(json, 'fetched_at')).toUtc(),
      source: WalkaCatalogSource.cache,
      products: _mapList(json['products'], 'products')
          .map(WalkaCatalogProduct.fromJson)
          .toList(growable: false),
    );
  }

  factory WalkaCatalogSnapshot.fromApi({
    required Map<String, dynamic> configJson,
    required Map<String, dynamic> catalogJson,
    DateTime? fetchedAt,
  }) {
    final Map<String, dynamic> config = _map(configJson['data'], 'config.data');
    final List<Map<String, dynamic>> products =
        _mapList(catalogJson['data'], 'catalog.data');
    final Map<String, dynamic> meta = _map(catalogJson['meta'], 'catalog.meta');

    final String configVersion = _requiredString(config, 'api_version');
    final String catalogVersion = _requiredString(meta, 'api_version');
    final String configMode = _requiredString(config, 'purchase_mode');
    final String catalogMode = _requiredString(meta, 'purchase_mode');

    if (_requiredString(config, 'brand') != 'WALKA' ||
        configVersion != catalogVersion ||
        configMode != catalogMode) {
      throw const FormatException('WALKA API config/catalog contract mismatch.');
    }

    return WalkaCatalogSnapshot(
      apiVersion: configVersion,
      release: _requiredString(config, 'release'),
      purchaseMode: configMode,
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaCatalogSource.remote,
      products: products.map(WalkaCatalogProduct.fromJson).toList(growable: false),
    );
  }

  static WalkaCatalogSnapshot bundled() {
    final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    Uri amazon(String asin) => Uri.https('www.amazon.com', '/dp/$asin');

    return WalkaCatalogSnapshot(
      apiVersion: 'v1',
      release: 'bundled-1.0.0',
      purchaseMode: 'amazon_redirect',
      fetchedAt: epoch,
      source: WalkaCatalogSource.bundled,
      products: <WalkaCatalogProduct>[
        WalkaCatalogProduct(
          id: walkaDrawerProductId,
          name: 'WALKA Drawer Organizer',
          category: 'drawer-organization',
          features: const <String>[
            '8 compartments',
            'Expandable to 22.4 in',
            'Non-slip base',
          ],
          facts: const <String, dynamic>{
            'material': 'Plastic',
            'compartments': 8,
            'closed_size_in': <double>[13.0, 15.0, 2.0],
            'expandable_width_in': 22.4,
            'non_slip_base': true,
          },
          variants: <WalkaCatalogVariant>[
            WalkaCatalogVariant(
              id: walkaDrawerWhiteVariantId,
              color: 'White',
              asin: 'B0FQN4DCTG',
              purchaseUri: amazon('B0FQN4DCTG'),
            ),
            WalkaCatalogVariant(
              id: walkaDrawerGrayVariantId,
              color: 'Gray',
              asin: 'B0FQN4L2ZD',
              purchaseUri: amazon('B0FQN4L2ZD'),
            ),
          ],
        ),
        WalkaCatalogProduct(
          id: walkaLunchProductId,
          name: 'WALKA Large Stainless Steel Bento Lunch Box for Adults',
          category: 'lunch',
          features: const <String>[
            '1200 ml',
            '4 compartments',
            'SUS304 stainless steel food tray',
            'Food-grade PP outer body',
            'Best suited for dry meals & snacks.',
          ],
          facts: const <String, dynamic>{
            'capacity_ml': 1200,
            'food_tray': 'SUS304 stainless steel',
            'compartments': 4,
            'outer_body': 'Food-grade PP',
            'lid': '4 clips with silicone gasket',
            'included': <String>[
              'Insulated carry bag',
              'Stainless sauce cup with lid',
              'Spoon',
              'Fork',
            ],
            'lunch_box_size_in': <double>[11.42, 8.66, 3.15],
            'with_bag_size_in': <double>[11.81, 8.86, 3.54],
            'bag_size_in': <double>[10.63, 7.48, 2.76],
            'weight_with_bag_lb': 1.84,
            'care': <String, String>{
              'sus304_tray': 'Dishwasher safe; not microwave safe.',
              'lid_and_gasket':
                  'Dishwasher safe on the top rack; not microwave safe.',
              'pp_outer_body':
                  'Microwave safe only after removing the stainless tray, lid, and silicone gasket.',
            },
            'usage_language': <String>[
              'Secure Lock | Helps Prevent Spills',
              'SPILL-RESISTANT DESIGN',
              'Best suited for dry meals & snacks.',
              'Not intended for liquids. Best for dry & semi-wet foods.',
              'Carry upright.',
            ],
          },
          variants: <WalkaCatalogVariant>[
            WalkaCatalogVariant(
              id: walkaLunchBlueVariantId,
              color: 'Blue',
              asin: 'B0FQN4L8MW',
              pantone: 'PANTONE 4155 U',
              purchaseUri: amazon('B0FQN4L8MW'),
            ),
            WalkaCatalogVariant(
              id: walkaLunchPinkVariantId,
              color: 'Pink',
              asin: 'B0FQN3W4SF',
              pantone: 'PANTONE 9242 U',
              purchaseUri: amazon('B0FQN3W4SF'),
            ),
            WalkaCatalogVariant(
              id: walkaLunchGreenVariantId,
              color: 'Green',
              asin: 'B0GPZNKF9F',
              pantone: 'PANTONE 6198 U',
              purchaseUri: amazon('B0GPZNKF9F'),
            ),
          ],
        ),
      ],
    );
  }
}

class WalkaCatalogValidator {
  const WalkaCatalogValidator();

  void validate(WalkaCatalogSnapshot snapshot) {
    if (snapshot.apiVersion != 'v1' || snapshot.purchaseMode != 'amazon_redirect') {
      throw const FormatException('Unsupported WALKA API contract.');
    }

    final Set<String> ids = snapshot.variants.map((variant) => variant.id).toSet();
    if (ids.length != walkaRequiredVariantIds.length ||
        !ids.containsAll(walkaRequiredVariantIds)) {
      throw const FormatException('WALKA catalog variant set is incompatible.');
    }

    if (snapshot.products.length != 2) {
      throw const FormatException('WALKA catalog product set is incompatible.');
    }

    final WalkaCatalogProduct? drawer = snapshot.productById(walkaDrawerProductId);
    final WalkaCatalogProduct? lunch = snapshot.productById(walkaLunchProductId);
    if (drawer == null || lunch == null) {
      throw const FormatException('Required WALKA products are missing.');
    }

    _validateDrawer(drawer);
    _validateLunch(lunch);
    _validatePurchaseTargets(snapshot.variants);
  }

  void _validateDrawer(WalkaCatalogProduct drawer) {
    if (drawer.facts.containsKey('weight_lb') ||
        drawer.facts.containsKey('weight') ||
        drawer.facts.containsKey('packaging_size_in') ||
        drawer.facts.containsKey('package_dimensions_in')) {
      throw const FormatException('Unverified Drawer facts are not allowed.');
    }

    if (_string(drawer.facts['material']).toLowerCase() != 'plastic' ||
        _number(drawer.facts['compartments']) != 8 ||
        !_numberListEquals(drawer.facts['closed_size_in'], <double>[13, 15, 2]) ||
        _number(drawer.facts['expandable_width_in']) != 22.4 ||
        drawer.facts['non_slip_base'] != true) {
      throw const FormatException('Drawer Product Master contract mismatch.');
    }
  }

  void _validateLunch(WalkaCatalogProduct lunch) {
    final Map<String, dynamic> care = _map(lunch.facts['care'], 'lunch.facts.care');
    final List<String> usage = _stringList(
      lunch.facts['usage_language'],
      'lunch.facts.usage_language',
    );

    if (_number(lunch.facts['capacity_ml']) != 1200 ||
        _number(lunch.facts['compartments']) != 4 ||
        _string(lunch.facts['food_tray']) != 'SUS304 stainless steel' ||
        _string(lunch.facts['outer_body']) != 'Food-grade PP' ||
        !_numberListEquals(
          lunch.facts['lunch_box_size_in'],
          <double>[11.42, 8.66, 3.15],
        ) ||
        _number(lunch.facts['weight_with_bag_lb']) != 1.84 ||
        _string(care['lid_and_gasket']) !=
            'Dishwasher safe on the top rack; not microwave safe.' ||
        _string(care['pp_outer_body']) !=
            'Microwave safe only after removing the stainless tray, lid, and silicone gasket.' ||
        !usage.contains('Not intended for liquids. Best for dry & semi-wet foods.') ||
        !usage.contains('Carry upright.')) {
      throw const FormatException('Lunch Product Master contract mismatch.');
    }

    const Map<String, String> pantones = <String, String>{
      walkaLunchBlueVariantId: 'PANTONE 4155 U',
      walkaLunchPinkVariantId: 'PANTONE 9242 U',
      walkaLunchGreenVariantId: 'PANTONE 6198 U',
    };
    for (final MapEntry<String, String> entry in pantones.entries) {
      if (lunch.variants.where((variant) => variant.id == entry.key).single.pantone !=
          entry.value) {
        throw const FormatException('Lunch Pantone contract mismatch.');
      }
    }
  }

  void _validatePurchaseTargets(Iterable<WalkaCatalogVariant> variants) {
    final Set<String> asins = <String>{};
    for (final WalkaCatalogVariant variant in variants) {
      final Uri uri = variant.purchaseUri;
      final List<String> segments = uri.pathSegments;
      if (uri.scheme != 'https' ||
          uri.host.toLowerCase() != 'www.amazon.com' ||
          segments.length != 2 ||
          segments.first != 'dp' ||
          segments.last != variant.asin ||
          !RegExp(r'^[A-Z0-9]{10}$').hasMatch(variant.asin) ||
          !asins.add(variant.asin)) {
        throw const FormatException('Invalid WALKA Amazon destination.');
      }
    }
  }
}

abstract interface class WalkaJsonTransport {
  Future<Map<String, dynamic>> getJson(Uri uri);
}

class IoWalkaJsonTransport implements WalkaJsonTransport {
  const IoWalkaJsonTransport({this.timeout = const Duration(seconds: 5)});

  final Duration timeout;

  @override
  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final HttpClient client = HttpClient()..connectionTimeout = timeout;
    try {
      final HttpClientRequest request = await client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      final HttpClientResponse response = await request.close().timeout(timeout);
      final String body = await response.transform(utf8.decoder).join().timeout(timeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException('WALKA API returned HTTP ${response.statusCode}.', uri: uri);
      }
      final Object? decoded = jsonDecode(body);
      return _map(decoded, 'response');
    } finally {
      client.close(force: true);
    }
  }
}

class WalkaApiClient {
  const WalkaApiClient({
    required this.baseUri,
    required this.transport,
  });

  final Uri? baseUri;
  final WalkaJsonTransport transport;

  static WalkaApiClient fromEnvironment({WalkaJsonTransport? transport}) {
    const String value = String.fromEnvironment('WALKA_API_BASE_URL');
    final String normalized = value.trim();
    return WalkaApiClient(
      baseUri: normalized.isEmpty ? null : Uri.tryParse(normalized),
      transport: transport ?? const IoWalkaJsonTransport(),
    );
  }

  bool get isEnabled =>
      baseUri != null && baseUri!.hasScheme && baseUri!.host.isNotEmpty;

  Future<Map<String, dynamic>> config() => _get('/api/v1/config');
  Future<Map<String, dynamic>> catalog() => _get('/api/v1/catalog');

  Future<Map<String, dynamic>> _get(String path) {
    if (!isEnabled) {
      throw StateError('WALKA_API_BASE_URL is not configured.');
    }
    final Uri uri = baseUri!.resolve(path);
    return transport.getJson(uri);
  }
}

abstract interface class WalkaCatalogCache {
  Future<WalkaCatalogSnapshot?> read();
  Future<void> write(WalkaCatalogSnapshot snapshot);
}

class SharedPreferencesWalkaCatalogCache implements WalkaCatalogCache {
  static const String storageKey = 'walka.catalog.snapshot.v1';

  @override
  Future<WalkaCatalogSnapshot?> read() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? value = preferences.getString(storageKey);
    if (value == null || value.isEmpty) return null;
    try {
      return WalkaCatalogSnapshot.fromCacheJson(_map(jsonDecode(value), 'cache'));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(WalkaCatalogSnapshot snapshot) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final bool saved = await preferences.setString(storageKey, jsonEncode(snapshot.toJson()));
    if (!saved) {
      throw StateError('Unable to persist WALKA catalog cache.');
    }
  }
}

class WalkaCatalogRepository {
  const WalkaCatalogRepository({
    required this.api,
    required this.cache,
    this.validator = const WalkaCatalogValidator(),
  });

  final WalkaApiClient api;
  final WalkaCatalogCache cache;
  final WalkaCatalogValidator validator;

  Future<WalkaCatalogSnapshot> load() async {
    if (api.isEnabled) {
      try {
        final List<Map<String, dynamic>> responses = await Future.wait(
          <Future<Map<String, dynamic>>>[api.config(), api.catalog()],
        );
        final WalkaCatalogSnapshot remote = WalkaCatalogSnapshot.fromApi(
          configJson: responses[0],
          catalogJson: responses[1],
        );
        validator.validate(remote);
        try {
          await cache.write(remote);
        } catch (_) {
          // A valid network response is still useful if local cache persistence fails.
        }
        return remote;
      } catch (_) {
        // Fall through to validated cache and then the deterministic bundle.
      }
    }

    try {
      final WalkaCatalogSnapshot? cached = await cache.read();
      if (cached != null) {
        validator.validate(cached);
        return cached.withSource(WalkaCatalogSource.cache);
      }
    } catch (_) {
      // Fall through to the immutable Product Master bundle.
    }

    final WalkaCatalogSnapshot bundled = WalkaCatalogSnapshot.bundled();
    validator.validate(bundled);
    return bundled;
  }
}

class WalkaCatalogController extends ChangeNotifier {
  WalkaCatalogController(this._repository)
      : _snapshot = WalkaCatalogSnapshot.bundled();

  final WalkaCatalogRepository _repository;
  WalkaCatalogSnapshot _snapshot;
  bool _isRefreshing = false;
  Object? _lastError;

  WalkaCatalogSnapshot get snapshot => _snapshot;
  bool get isRefreshing => _isRefreshing;
  Object? get lastError => _lastError;

  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    _lastError = null;
    notifyListeners();
    try {
      _snapshot = await _repository.load();
    } catch (error) {
      _lastError = error;
      _snapshot = WalkaCatalogSnapshot.bundled();
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  Uri purchaseUri(String variantId, {required Uri fallback}) {
    return _snapshot.variantById(variantId)?.purchaseUri ?? fallback;
  }
}

class WalkaCatalogScope extends InheritedNotifier<WalkaCatalogController> {
  const WalkaCatalogScope({
    required WalkaCatalogController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static WalkaCatalogController of(BuildContext context) {
    final WalkaCatalogScope? scope =
        context.dependOnInheritedWidgetOfExactType<WalkaCatalogScope>();
    assert(scope != null, 'WalkaCatalogScope is missing above this widget.');
    return scope!.notifier!;
  }

  static WalkaCatalogController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WalkaCatalogScope>()
        ?.notifier;
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing or invalid WALKA field: $key');
  }
  return value;
}

String _string(Object? value) {
  if (value is! String) throw const FormatException('Expected string.');
  return value;
}

num _number(Object? value) {
  if (value is! num) throw const FormatException('Expected number.');
  return value;
}

Map<String, dynamic> _map(Object? value, String field) {
  if (value is! Map) throw FormatException('Expected WALKA map: $field');
  return value.map((Object? key, Object? item) => MapEntry(key.toString(), item));
}

List<Map<String, dynamic>> _mapList(Object? value, String field) {
  if (value is! List) throw FormatException('Expected WALKA list: $field');
  return value.map((item) => _map(item, field)).toList(growable: false);
}

List<String> _stringList(Object? value, String field) {
  if (value is! List || value.any((item) => item is! String)) {
    throw FormatException('Expected WALKA string list: $field');
  }
  return value.cast<String>().toList(growable: false);
}

bool _numberListEquals(Object? value, List<double> expected) {
  if (value is! List || value.length != expected.length) return false;
  for (int index = 0; index < expected.length; index++) {
    final Object? item = value[index];
    if (item is! num || (item.toDouble() - expected[index]).abs() > 0.0001) {
      return false;
    }
  }
  return true;
}
