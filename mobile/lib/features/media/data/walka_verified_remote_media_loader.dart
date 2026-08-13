import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

import '../../../core/api/walka_api_client.dart';
import '../domain/walka_remote_media.dart';

abstract interface class WalkaRemoteBinaryCache {
  Future<Uint8List?> read(String key);

  Future<void> write({
    required String key,
    required String url,
    required Uint8List bytes,
    required String eTag,
    required String fileExtension,
  });

  Future<void> remove(String key);
}

class FlutterCacheManagerWalkaRemoteBinaryCache
    implements WalkaRemoteBinaryCache {
  FlutterCacheManagerWalkaRemoteBinaryCache({BaseCacheManager? manager})
      : _manager = manager ?? DefaultCacheManager();

  final BaseCacheManager _manager;

  @override
  Future<Uint8List?> read(String key) async {
    final FileInfo? info = await _manager.getFileFromCache(key);
    if (info == null) return null;
    return info.file.readAsBytes();
  }

  @override
  Future<void> write({
    required String key,
    required String url,
    required Uint8List bytes,
    required String eTag,
    required String fileExtension,
  }) async {
    await _manager.putFile(
      url,
      bytes,
      key: key,
      eTag: eTag,
      maxAge: const Duration(hours: 1),
      fileExtension: fileExtension,
    );
  }

  @override
  Future<void> remove(String key) => _manager.removeFile(key);
}

class WalkaVerifiedRemoteMediaLoader {
  WalkaVerifiedRemoteMediaLoader({
    required WalkaApiSettings settings,
    required WalkaRemoteBinaryCache cache,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
    this.maxBytes = 16 * 1024 * 1024,
  })  : _settings = settings,
        _cache = cache,
        _client = client ?? http.Client(),
        _ownsClient = client == null;

  final WalkaApiSettings _settings;
  final WalkaRemoteBinaryCache _cache;
  final http.Client _client;
  final bool _ownsClient;
  final Duration timeout;
  final int maxBytes;

  Future<Uint8List> load(WalkaRemoteMediaItem item) async {
    final Uint8List? cached = await _tryCache(item);
    if (cached != null) return cached;
    if (!_settings.isConfigured) {
      throw const WalkaRemoteMediaLoadException('WALKA API is not configured.');
    }

    final Uri uri = _settings.canonicalMediaEndpoint(item.mediaId);
    late final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const <String, String>{'Accept': 'image/*'},
      ).timeout(timeout);
    } on TimeoutException catch (_) {
      throw const WalkaRemoteMediaLoadException('Remote media request timed out.');
    } on Object catch (error) {
      throw WalkaRemoteMediaLoadException('Remote media request failed: $error');
    }

    if (response.statusCode != 200) {
      throw WalkaRemoteMediaLoadException(
        'Remote media returned HTTP ${response.statusCode}.',
      );
    }

    final Uint8List bytes = response.bodyBytes;
    _verifyBytes(item, bytes);

    final String responseMime =
        (response.headers['content-type'] ?? '').split(';').first.trim();
    if (responseMime != item.mime) {
      throw const WalkaRemoteMediaLoadException(
        'Remote media Content-Type does not match metadata.',
      );
    }
    final String? contentLength = response.headers['content-length'];
    if (contentLength != null && int.tryParse(contentLength) != bytes.length) {
      throw const WalkaRemoteMediaLoadException(
        'Remote media Content-Length does not match received bytes.',
      );
    }
    final String expectedEtag = '"sha256-${item.sha256}"';
    if (response.headers['etag'] != expectedEtag) {
      throw const WalkaRemoteMediaLoadException(
        'Remote media ETag does not match canonical SHA-256.',
      );
    }

    try {
      await _cache.write(
        key: item.cacheKey,
        url: uri.toString(),
        bytes: bytes,
        eTag: expectedEtag,
        fileExtension: item.fileExtension,
      );
    } on Object {
      // Verified bytes remain usable even when persistent cache writes fail.
    }
    return bytes;
  }

  Future<void> evict(WalkaRemoteMediaItem item) => _cache.remove(item.cacheKey);

  Future<Uint8List?> _tryCache(WalkaRemoteMediaItem item) async {
    try {
      final Uint8List? bytes = await _cache.read(item.cacheKey);
      if (bytes == null) return null;
      try {
        _verifyBytes(item, bytes);
        return bytes;
      } on WalkaRemoteMediaLoadException {
        await _cache.remove(item.cacheKey);
        return null;
      }
    } on Object {
      return null;
    }
  }

  void _verifyBytes(WalkaRemoteMediaItem item, Uint8List bytes) {
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const WalkaRemoteMediaLoadException(
        'Remote media byte size is outside the safe delivery limit.',
      );
    }
    if (sha256.convert(bytes).toString() != item.sha256) {
      throw const WalkaRemoteMediaLoadException(
        'Remote media SHA-256 verification failed.',
      );
    }
  }

  void close() {
    if (_ownsClient) _client.close();
  }
}

class WalkaRemoteMediaLoadException implements Exception {
  const WalkaRemoteMediaLoadException(this.message);

  final String message;

  @override
  String toString() => 'WalkaRemoteMediaLoadException: $message';
}
