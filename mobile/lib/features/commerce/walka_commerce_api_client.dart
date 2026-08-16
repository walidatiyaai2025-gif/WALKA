import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/api/walka_api_client.dart';
import 'walka_commerce_map.dart';

class WalkaCommerceApiClient {
  WalkaCommerceApiClient({
    required WalkaApiSettings settings,
    http.Client? client,
    this.timeout = const Duration(seconds: 8),
  })  : _settings = settings,
        _client = client ?? http.Client(),
        _ownsClient = client == null;

  final WalkaApiSettings _settings;
  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;

  Future<WalkaCommerceSnapshot> fetchCommerceMap() async {
    final Uri uri = _settings.endpoint('/api/v1/commerce/amazon');
    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const <String, String>{'Accept': 'application/json'})
          .timeout(timeout);
    } on TimeoutException catch (_) {
      throw const WalkaApiException('WALKA commerce request timed out.');
    } on Exception catch (error) {
      throw WalkaApiException('WALKA commerce request failed: $error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WalkaApiException(
        'WALKA commerce API returned a non-success response.',
        statusCode: response.statusCode,
      );
    }

    try {
      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('Commerce API response root must be an object.');
      }
      return WalkaCommerceSnapshot.fromApiJson(
        Map<String, dynamic>.from(decoded),
      );
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw FormatException('Invalid WALKA commerce JSON: $error');
    }
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
