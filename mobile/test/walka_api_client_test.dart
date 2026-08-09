import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:walka/core/api/walka_api_client.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';

void main() {
  test('API settings build versioned endpoints from configured base URL', () {
    const WalkaApiSettings settings = WalkaApiSettings(
      baseUrl: 'https://api.walkastore.test/root',
    );

    expect(
      settings.endpoint('/api/v1/catalog').toString(),
      'https://api.walkastore.test/root/api/v1/catalog',
    );
  });

  test('typed API client parses config and catalog contracts', () async {
    final MockClient httpClient = MockClient((http.Request request) async {
      if (request.url.path.endsWith('/api/v1/config')) {
        return http.Response(
          jsonEncode(<String, dynamic>{
            'data': <String, dynamic>{
              'brand': 'WALKA',
              'release': '1.1.0',
              'api_version': 'v1',
              'purchase_mode': 'amazon_redirect',
            },
          }),
          200,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }
      if (request.url.path.endsWith('/api/v1/catalog')) {
        return http.Response(
          jsonEncode(_catalogJson()),
          200,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      }
      return http.Response('not found', 404);
    });
    final WalkaApiClient client = WalkaApiClient(
      settings: const WalkaApiSettings(baseUrl: 'https://api.walkastore.test'),
      client: httpClient,
    );

    final WalkaStorefrontConfig config = await client.fetchConfig();
    final WalkaCatalogPayload catalog = await client.fetchCatalog();

    expect(config.brand, 'WALKA');
    expect(config.release, '1.1.0');
    expect(catalog.products.length, 2);
    expect(
      catalog.products.expand((WalkaCatalogProduct item) => item.variants).length,
      5,
    );
    expect(catalog.products[1].facts['outer_body'], 'Food-grade PP');
    expect(catalog.products[1].variants[2].pantone, 'PANTONE 6198 U');
    expect(
      catalog.products[1].variants[2].purchaseUri.toString(),
      'https://www.amazon.com/dp/B0GPZNKF9F',
    );
  });

  test('non-success API responses become WalkaApiException', () async {
    final WalkaApiClient client = WalkaApiClient(
      settings: const WalkaApiSettings(baseUrl: 'https://api.walkastore.test'),
      client: MockClient((http.Request _) async => http.Response('{}', 503)),
    );

    expect(
      client.fetchCatalog,
      throwsA(
        isA<WalkaApiException>().having(
          (WalkaApiException error) => error.statusCode,
          'statusCode',
          503,
        ),
      ),
    );
  });

  test('malformed catalog JSON is rejected before repository mapping', () async {
    final WalkaApiClient client = WalkaApiClient(
      settings: const WalkaApiSettings(baseUrl: 'https://api.walkastore.test'),
      client: MockClient(
        (http.Request _) async => http.Response(
          jsonEncode(<String, dynamic>{'data': 'not-a-list', 'meta': <String, dynamic>{}}),
          200,
        ),
      ),
    );

    expect(client.fetchCatalog, throwsFormatException);
  });
}

Map<String, dynamic> _catalogJson() {
  return <String, dynamic>{
    'data': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'drawer-organizer',
        'name': 'WALKA Drawer Organizer',
        'category': 'drawer-organization',
        'features': <String>['8 compartments', 'Expandable to 22.4 in'],
        'facts': <String, dynamic>{
          'material': 'Plastic',
          'compartments': 8,
          'closed_size_in': <num>[13, 15, 2],
          'expandable_width_in': 22.4,
          'non_slip_base': true,
        },
        'variants': <Map<String, dynamic>>[
          _variant('drawer-organizer:white', 'White', 'B0FQN4DCTG'),
          _variant('drawer-organizer:gray', 'Gray', 'B0FQN4L2ZD'),
        ],
      },
      <String, dynamic>{
        'id': 'stainless-steel-bento-lunch-box',
        'name': 'WALKA Large Stainless Steel Bento Lunch Box for Adults',
        'category': 'lunch',
        'features': <String>[
          '1200 ml',
          '4 compartments',
          'SUS304 stainless steel food tray',
          'Food-grade PP outer body',
        ],
        'facts': <String, dynamic>{
          'capacity_ml': 1200,
          'food_tray': 'SUS304 stainless steel',
          'compartments': 4,
          'outer_body': 'Food-grade PP',
          'lid': '4 clips with silicone gasket',
          'care': <String, String>{
            'sus304_tray': 'Dishwasher safe; not microwave safe.',
            'lid_and_gasket':
                'Dishwasher safe on the top rack; not microwave safe.',
            'pp_outer_body':
                'Microwave safe only after removing the stainless tray, lid, and silicone gasket.',
          },
        },
        'variants': <Map<String, dynamic>>[
          _variant(
            'lunch-box:blue',
            'Blue',
            'B0FQN4L8MW',
            pantone: 'PANTONE 4155 U',
          ),
          _variant(
            'lunch-box:pink',
            'Pink',
            'B0FQN3W4SF',
            pantone: 'PANTONE 9242 U',
          ),
          _variant(
            'lunch-box:green',
            'Green',
            'B0GPZNKF9F',
            pantone: 'PANTONE 6198 U',
          ),
        ],
      },
    ],
    'meta': <String, dynamic>{
      'release': '1.1.0',
      'api_version': 'v1',
      'purchase_mode': 'amazon_redirect',
    },
  };
}

Map<String, dynamic> _variant(
  String id,
  String color,
  String asin, {
  String? pantone,
}) {
  return <String, dynamic>{
    'id': id,
    'color': color,
    'asin': asin,
    'pantone': pantone,
    'purchase_url': 'https://www.amazon.com/dp/$asin',
  };
}
