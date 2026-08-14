import 'dart:convert';

import '../domain/walka_mobile_content.dart';
import '../domain/walka_operational_content.dart';
import 'walka_operational_cache.dart';

class WalkaMaintenanceNoticeRepository {
  WalkaMaintenanceNoticeRepository({
    required WalkaMaintenanceNoticeCache cache,
    Future<WalkaMaintenanceNoticePayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaMaintenanceNoticeCache _cache;
  final Future<WalkaMaintenanceNoticePayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaMaintenanceNoticeSnapshot> load() async {
    final WalkaMaintenanceNoticeSnapshot? cached = await _tryCache();
    final WalkaMaintenanceNoticeSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaMaintenanceNoticeSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaMaintenanceNoticeSnapshot?> _tryRemote(
    WalkaMaintenanceNoticeSnapshot? cached,
  ) async {
    final Future<WalkaMaintenanceNoticePayload> Function()? loader =
        _remoteLoader;
    if (loader == null) return null;
    try {
      final WalkaMaintenanceNoticePayload payload = await loader();
      final WalkaMaintenanceNoticeSnapshot snapshot =
          WalkaMaintenanceNoticeSnapshot(
        content: payload.content,
        revision: payload.revision,
        publishedAt: payload.publishedAt,
        fetchedAt: _clock().toUtc(),
        source: WalkaContentSource.remote,
      );
      if (cached != null) {
        if (snapshot.revision < cached.revision) return cached;
        if (snapshot.revision == cached.revision &&
            jsonEncode(snapshot.content.toJson()) !=
                jsonEncode(cached.content.toJson())) {
          return cached;
        }
      }
      try {
        await _cache.write(snapshot);
      } on Object {
        // Valid remote content remains usable if local persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaMaintenanceNoticeSnapshot?> _tryCache() async {
    try {
      final WalkaMaintenanceNoticeSnapshot? snapshot = await _cache.read();
      if (snapshot == null || snapshot.revision < 1 || snapshot.publishedAt == null) {
        return null;
      }
      return snapshot.asSource(WalkaContentSource.cache);
    } on Object {
      return null;
    }
  }
}

class WalkaAppConfigRepository {
  WalkaAppConfigRepository({
    required WalkaAppConfigCache cache,
    Future<WalkaAppConfigPayload> Function()? remoteLoader,
    DateTime Function()? clock,
  })  : _cache = cache,
        _remoteLoader = remoteLoader,
        _clock = clock ?? DateTime.now;

  final WalkaAppConfigCache _cache;
  final Future<WalkaAppConfigPayload> Function()? _remoteLoader;
  final DateTime Function() _clock;

  Future<WalkaAppConfigSnapshot> load() async {
    final WalkaAppConfigSnapshot? cached = await _tryCache();
    final WalkaAppConfigSnapshot? remote = await _tryRemote(cached);
    if (remote != null) return remote;
    if (cached != null) return cached;
    return WalkaAppConfigSnapshot.bundled(fetchedAt: _clock());
  }

  Future<WalkaAppConfigSnapshot?> _tryRemote(
    WalkaAppConfigSnapshot? cached,
  ) async {
    final Future<WalkaAppConfigPayload> Function()? loader = _remoteLoader;
    if (loader == null) return null;
    try {
      final WalkaAppConfigPayload payload = await loader();
      final WalkaAppConfigSnapshot snapshot = WalkaAppConfigSnapshot(
        content: payload.content,
        revision: payload.revision,
        publishedAt: payload.publishedAt,
        fetchedAt: _clock().toUtc(),
        source: WalkaContentSource.remote,
      );
      if (cached != null) {
        if (snapshot.revision < cached.revision) return cached;
        if (snapshot.revision == cached.revision &&
            jsonEncode(snapshot.content.toJson()) !=
                jsonEncode(cached.content.toJson())) {
          return cached;
        }
      }
      try {
        await _cache.write(snapshot);
      } on Object {
        // Valid remote content remains usable if local persistence fails.
      }
      return snapshot;
    } on Object {
      return null;
    }
  }

  Future<WalkaAppConfigSnapshot?> _tryCache() async {
    try {
      final WalkaAppConfigSnapshot? snapshot = await _cache.read();
      if (snapshot == null || snapshot.revision < 1 || snapshot.publishedAt == null) {
        return null;
      }
      return snapshot.asSource(WalkaContentSource.cache);
    } on Object {
      return null;
    }
  }
}
