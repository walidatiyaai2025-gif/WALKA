import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../features/catalog/domain/walka_catalog.dart';

class WalkaApiSettings {
  const WalkaApiSettings({required this.baseUrl});

  static const String environmentBaseUrl = String.fromEnvironment(
    'WALKA_API_BASE_URL',
    defaultValue: '',
  );

  final String baseUrl;

  bool get isConfigured => baseUrl.trim().isNotEmpty;

  Uri endpoint(String path) {
    if (!isConfigured) {
      throw const StateError('WALKA_API_BASE_URL is not configured.');
    }

    final Uri? parsed = Uri.tryParse(baseUrl.trim());
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) {
      throw const FormatException('WALKA_API_BASE_URL must be an absolute URL.');
    }
    if (parsed.scheme != 'http' && parsed.scheme != 'https') {
      throw const FormatException('WALKA API URL must use http or https.');
    }

    final Uri normalized = parsed.path.endsWith('/')
        ? parsed
        : parsed.replace(path: '${parsed.path}/');
    return normalized.resolve(path.replaceFirst(RegExp(r'^/+'), ''));
  }
}

abstract interface class WalkaCatalogRemoteDataSource {
  Future<WalkaStorefrontConfig> fetchConfig();

  Future<WalkaCatalogPayload> fetchCatalog();
}

class WalkaApiException implements Exception {
  const WalkaApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'WalkaApiException: $message'
      : 'WalkaApiException($statusCode): $message';
}

class WalkaApiClient implements WalkaCatalogRemoteDataSource {
  WalkaApiClient({
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

  bool get isConfigured => _settings.isConfigured;

  Future<Map<String, dynamic>> _getJson(String path) async {
    final Uri uri = _settings.endpoint(path);
    late final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const <String, String>{'Accept': 'application/json'})
          .timeout(timeout);
    } on TimeoutException catch (_) {
      throw const WalkaApiException('WALKA API request timed out.');
    } on Exception catch (error) {
      throw WalkaApiException('WALKA API request failed: $error');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw WalkaApiException(
        'WALKA API returned a non-success response.',
        statusCode: response.statusCode,
      );
    }

    try {
      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map) {
        throw const FormatException('API response root must be an object.');
      }
      return Map<String, dynamic>.from(decoded as Map);
    } on FormatException {
      rethrow;
    } on Object catch (error) {
      throw FormatException('Invalid WALKA API JSON: $error');
    }
  }

  @override
  Future<WalkaStorefrontConfig> fetchConfig() async {
    final Map<String, dynamic> json = await _getJson('/api/v1/config');
    final Object? data = json['data'];
    if (data is! Map) {
      throw const FormatException('Config data must be an object.');
    }
    return WalkaStorefrontConfig.fromJson(
      Map<String, dynamic>.from(data as Map),
    );
  }

  @override
  Future<WalkaCatalogPayload> fetchCatalog() async {
    return WalkaCatalogPayload.fromJson(await _getJson('/api/v1/catalog'));
  }

  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
