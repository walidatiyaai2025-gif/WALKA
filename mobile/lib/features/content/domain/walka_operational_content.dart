import 'walka_mobile_content.dart';

class WalkaMaintenanceNoticeContent {
  const WalkaMaintenanceNoticeContent({
    required this.enabled,
    required this.severity,
    required this.title,
    required this.body,
    required this.startsAt,
    required this.endsAt,
  });

  static const WalkaMaintenanceNoticeContent bundled =
      WalkaMaintenanceNoticeContent(
    enabled: false,
    severity: 'info',
    title: 'WALKA service update',
    body:
        'We are making a few improvements. Product discovery and official Amazon purchase links remain available.',
    startsAt: null,
    endsAt: null,
  );

  final bool enabled;
  final String severity;
  final String title;
  final String body;
  final DateTime? startsAt;
  final DateTime? endsAt;

  bool isActiveAt(DateTime at) {
    if (!enabled) return false;
    final DateTime instant = at.toUtc();
    final DateTime? start = startsAt;
    final DateTime? end = endsAt;
    if (start != null && instant.isBefore(start)) return false;
    if (end != null && !instant.isBefore(end)) return false;
    return true;
  }

  factory WalkaMaintenanceNoticeContent.fromJson(Map<String, dynamic> json) {
    final Object? enabled = json['enabled'];
    if (enabled is! bool) {
      throw const FormatException('Maintenance enabled must be a boolean.');
    }
    final Object? severityValue = json['severity'];
    if (severityValue is! String ||
        !const <String>{'info', 'warning', 'maintenance'}
            .contains(severityValue)) {
      throw const FormatException('Unsupported maintenance severity.');
    }

    String requiredText(String key, int maxLength) {
      final Object? value = json[key];
      if (value is! String || value.trim().isEmpty || value.length > maxLength) {
        throw FormatException('Maintenance $key is invalid.');
      }
      if (value.contains('<') || value.contains('>')) {
        throw FormatException('Maintenance $key cannot contain markup.');
      }
      return value.trim();
    }

    DateTime? optionalUtc(String key) {
      final Object? value = json[key];
      if (value == null) return null;
      if (value is! String) {
        throw FormatException('Maintenance $key must be an ISO-8601 string.');
      }
      final DateTime? parsed = DateTime.tryParse(value);
      if (parsed == null || !parsed.isUtc) {
        throw FormatException('Maintenance $key must use UTC.');
      }
      return parsed;
    }

    final DateTime? startsAt = optionalUtc('starts_at');
    final DateTime? endsAt = optionalUtc('ends_at');
    if (startsAt != null && endsAt != null && !endsAt.isAfter(startsAt)) {
      throw const FormatException('Maintenance end must be after start.');
    }

    return WalkaMaintenanceNoticeContent(
      enabled: enabled,
      severity: severityValue,
      title: requiredText('title', 140),
      body: requiredText('body', 700),
      startsAt: startsAt,
      endsAt: endsAt,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'enabled': enabled,
        'severity': severity,
        'title': title,
        'body': body,
        'starts_at': startsAt?.toIso8601String(),
        'ends_at': endsAt?.toIso8601String(),
      };
}

class WalkaMaintenanceNoticePayload {
  const WalkaMaintenanceNoticePayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaMaintenanceNoticeContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaMaintenanceNoticePayload.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = _requiredMap(json, 'data');
    if (data['key'] != 'app.maintenance_notice' ||
        data['type'] != 'app.maintenance_notice' ||
        data['schema_version'] != 1) {
      throw const FormatException('Unexpected maintenance notice contract.');
    }
    final int revision = _positiveRevision(data['revision']);
    final DateTime publishedAt = _requiredDate(data['published_at']);
    final Map<String, dynamic> meta = _requiredMap(json, 'meta');
    if (meta['api_version'] != 'v1') {
      throw const FormatException('Unsupported maintenance API version.');
    }

    return WalkaMaintenanceNoticePayload(
      content: WalkaMaintenanceNoticeContent.fromJson(
        _requiredMap(data, 'payload'),
      ),
      revision: revision,
      publishedAt: publishedAt,
    );
  }
}

class WalkaMaintenanceNoticeSnapshot {
  const WalkaMaintenanceNoticeSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaMaintenanceNoticeContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaMaintenanceNoticeSnapshot.bundled({DateTime? fetchedAt}) =>
      WalkaMaintenanceNoticeSnapshot(
        content: WalkaMaintenanceNoticeContent.bundled,
        revision: 0,
        publishedAt: null,
        fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
        source: WalkaContentSource.bundled,
      );

  WalkaMaintenanceNoticeSnapshot asSource(WalkaContentSource source) =>
      WalkaMaintenanceNoticeSnapshot(
        content: content,
        revision: revision,
        publishedAt: publishedAt,
        fetchedAt: fetchedAt,
        source: source,
      );

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'cache_schema': 1,
        'revision': revision,
        'published_at': publishedAt?.toIso8601String(),
        'fetched_at': fetchedAt.toIso8601String(),
        'payload': content.toJson(),
      };

  factory WalkaMaintenanceNoticeSnapshot.fromCacheJson(
    Map<String, dynamic> json,
  ) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported maintenance cache schema.');
    }
    return WalkaMaintenanceNoticeSnapshot(
      content: WalkaMaintenanceNoticeContent.fromJson(
        _requiredMap(json, 'payload'),
      ),
      revision: _positiveRevision(json['revision']),
      publishedAt: _requiredDate(json['published_at']),
      fetchedAt: _requiredDate(json['fetched_at']),
      source: WalkaContentSource.cache,
    );
  }
}

class WalkaAppConfigContent {
  const WalkaAppConfigContent({
    required this.showOperationalNotice,
    required this.showAccountServiceNote,
  });

  static const WalkaAppConfigContent bundled = WalkaAppConfigContent(
    showOperationalNotice: true,
    showAccountServiceNote: false,
  );

  static const Set<String> flagIds = <String>{
    'show_operational_notice',
    'show_account_service_note',
  };

  final bool showOperationalNotice;
  final bool showAccountServiceNote;

  factory WalkaAppConfigContent.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> flags = _requiredMap(json, 'flags');
    if (flags.keys.toSet().difference(flagIds).isNotEmpty ||
        flagIds.difference(flags.keys.toSet()).isNotEmpty) {
      throw const FormatException('App Config flag identity mismatch.');
    }
    final Object? showNotice = flags['show_operational_notice'];
    final Object? showAccount = flags['show_account_service_note'];
    if (showNotice is! bool || showAccount is! bool) {
      throw const FormatException('App Config flags must be booleans.');
    }
    return WalkaAppConfigContent(
      showOperationalNotice: showNotice,
      showAccountServiceNote: showAccount,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'flags': <String, bool>{
          'show_operational_notice': showOperationalNotice,
          'show_account_service_note': showAccountServiceNote,
        },
      };
}

class WalkaAppConfigPayload {
  const WalkaAppConfigPayload({
    required this.content,
    required this.revision,
    required this.publishedAt,
  });

  final WalkaAppConfigContent content;
  final int revision;
  final DateTime publishedAt;

  factory WalkaAppConfigPayload.fromApiJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = _requiredMap(json, 'data');
    if (data['key'] != 'app.config' ||
        data['type'] != 'app.config' ||
        data['schema_version'] != 1) {
      throw const FormatException('Unexpected App Config contract.');
    }
    final Map<String, dynamic> meta = _requiredMap(json, 'meta');
    if (meta['api_version'] != 'v1') {
      throw const FormatException('Unsupported App Config API version.');
    }
    return WalkaAppConfigPayload(
      content: WalkaAppConfigContent.fromJson(_requiredMap(data, 'payload')),
      revision: _positiveRevision(data['revision']),
      publishedAt: _requiredDate(data['published_at']),
    );
  }
}

class WalkaAppConfigSnapshot {
  const WalkaAppConfigSnapshot({
    required this.content,
    required this.revision,
    required this.publishedAt,
    required this.fetchedAt,
    required this.source,
  });

  final WalkaAppConfigContent content;
  final int revision;
  final DateTime? publishedAt;
  final DateTime fetchedAt;
  final WalkaContentSource source;

  factory WalkaAppConfigSnapshot.bundled({DateTime? fetchedAt}) =>
      WalkaAppConfigSnapshot(
        content: WalkaAppConfigContent.bundled,
        revision: 0,
        publishedAt: null,
        fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
        source: WalkaContentSource.bundled,
      );

  WalkaAppConfigSnapshot asSource(WalkaContentSource source) =>
      WalkaAppConfigSnapshot(
        content: content,
        revision: revision,
        publishedAt: publishedAt,
        fetchedAt: fetchedAt,
        source: source,
      );

  Map<String, dynamic> toCacheJson() => <String, dynamic>{
        'cache_schema': 1,
        'revision': revision,
        'published_at': publishedAt?.toIso8601String(),
        'fetched_at': fetchedAt.toIso8601String(),
        'payload': content.toJson(),
      };

  factory WalkaAppConfigSnapshot.fromCacheJson(Map<String, dynamic> json) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported App Config cache schema.');
    }
    return WalkaAppConfigSnapshot(
      content: WalkaAppConfigContent.fromJson(_requiredMap(json, 'payload')),
      revision: _positiveRevision(json['revision']),
      publishedAt: _requiredDate(json['published_at']),
      fetchedAt: _requiredDate(json['fetched_at']),
      source: WalkaContentSource.cache,
    );
  }
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> source, String key) {
  final Object? value = source[key];
  if (value is! Map) {
    throw FormatException('$key must be an object.');
  }
  return Map<String, dynamic>.from(value);
}

int _positiveRevision(Object? value) {
  if (value is! int || value < 1) {
    throw const FormatException('Content revision must be positive.');
  }
  return value;
}

DateTime _requiredDate(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    throw const FormatException('Content timestamp is required.');
  }
  final DateTime? parsed = DateTime.tryParse(value);
  if (parsed == null) {
    throw const FormatException('Content timestamp is invalid.');
  }
  return parsed.toUtc();
}
