import 'protected_commerce_master.dart';

enum WalkaCommerceSource { remote, cache, bundled }

class WalkaCommerceTrace {
  const WalkaCommerceTrace({required this.source, required this.reference});

  final String source;
  final String? reference;

  factory WalkaCommerceTrace.fromJson(Map<String, dynamic> json) {
    final Object? sourceValue = json['source'];
    final Object? referenceValue = json['reference'];
    if (sourceValue is! String || !_machineKey(sourceValue)) {
      throw const FormatException('Commerce trace source is invalid.');
    }
    if (referenceValue != null &&
        (referenceValue is! String ||
            referenceValue.trim().isEmpty ||
            referenceValue.trim().length > 160)) {
      throw const FormatException('Commerce trace reference is invalid.');
    }
    return WalkaCommerceTrace(
      source: sourceValue.trim(),
      reference: referenceValue == null
          ? null
          : (referenceValue as String).trim(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'source': source,
        'reference': reference,
      };
}

class WalkaCommerceMapping {
  const WalkaCommerceMapping({
    required this.variantId,
    required this.variantRevision,
    required this.regionMarket,
    required this.asin,
    required this.destinationUri,
    required this.ctaKey,
    required this.disclosureKey,
    required this.entitlements,
    required this.trace,
  });

  final String variantId;
  final int variantRevision;
  final String regionMarket;
  final String asin;
  final Uri destinationUri;
  final String ctaKey;
  final String disclosureKey;
  final List<String> entitlements;
  final WalkaCommerceTrace trace;

  factory WalkaCommerceMapping.fromJson(Map<String, dynamic> json) {
    final String variantId = _requiredString(json, 'variant_id');
    final String market = WalkaProtectedCommerceMaster.normalizeMarket(
      _requiredString(json, 'region_market'),
    );
    final String asin = _requiredString(json, 'asin').toUpperCase();
    final String protectedAsin = WalkaProtectedCommerceMaster.asinForVariant(
      variantId,
    );
    if (asin != protectedAsin) {
      throw const FormatException(
        'Dynamic commerce mapping cannot change protected WALKA ASIN identity.',
      );
    }

    final Object? revisionValue = json['variant_revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Commerce variant revision must be positive.');
    }

    final Object? activeValue = json['active'];
    if (activeValue is! bool || !activeValue) {
      throw const FormatException('Public commerce mappings must be active.');
    }

    final String destination = _requiredString(json, 'destination_url');
    final Uri? destinationUri = Uri.tryParse(destination);
    if (destinationUri == null ||
        !WalkaProtectedCommerceMaster.isApprovedDestination(
          destinationUri,
          market: market,
          asin: asin,
        )) {
      throw const FormatException('Commerce destination is not canonical Amazon HTTPS.');
    }

    final String ctaKey = _requiredString(json, 'cta_key');
    final String disclosureKey = _requiredString(json, 'disclosure_key');
    if (!_machineKey(ctaKey) || !_machineKey(disclosureKey)) {
      throw const FormatException('Commerce CTA/disclosure keys are invalid.');
    }

    final Object? entitlementValue = json['entitlements'];
    if (entitlementValue is! List ||
        entitlementValue.isEmpty ||
        entitlementValue.length > 8) {
      throw const FormatException('Commerce entitlements are invalid.');
    }
    final List<String> entitlements = entitlementValue.map((Object? value) {
      if (value is! String || !_machineKey(value)) {
        throw const FormatException('Commerce entitlement key is invalid.');
      }
      return value.trim();
    }).toList(growable: false);
    if (entitlements.toSet().length != entitlements.length) {
      throw const FormatException('Commerce entitlements must be unique.');
    }
    final List<String> normalizedEntitlements = List<String>.from(entitlements)
      ..sort();

    final Object? traceValue = json['trace'];
    if (traceValue is! Map) {
      throw const FormatException('Commerce trace metadata is required.');
    }

    return WalkaCommerceMapping(
      variantId: variantId,
      variantRevision: revisionValue,
      regionMarket: market,
      asin: asin,
      destinationUri: destinationUri,
      ctaKey: ctaKey.trim(),
      disclosureKey: disclosureKey.trim(),
      entitlements: List<String>.unmodifiable(normalizedEntitlements),
      trace: WalkaCommerceTrace.fromJson(
        Map<String, dynamic>.from(traceValue),
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'variant_id': variantId,
        'variant_revision': variantRevision,
        'region_market': regionMarket,
        'asin': asin,
        'destination_url': destinationUri.toString(),
        'cta_key': ctaKey,
        'disclosure_key': disclosureKey,
        'entitlements': entitlements,
        'active': true,
        'trace': trace.toJson(),
      };
}

class WalkaCommerceSnapshot {
  const WalkaCommerceSnapshot({
    required this.revision,
    required this.verificationDigest,
    required this.mappings,
    required this.fetchedAt,
    required this.source,
  });

  final int revision;
  final String? verificationDigest;
  final List<WalkaCommerceMapping> mappings;
  final DateTime fetchedAt;
  final WalkaCommerceSource source;

  factory WalkaCommerceSnapshot.bundled({DateTime? fetchedAt}) {
    return WalkaCommerceSnapshot(
      revision: 0,
      verificationDigest: null,
      mappings: const <WalkaCommerceMapping>[],
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaCommerceSource.bundled,
    );
  }

  factory WalkaCommerceSnapshot.fromApiJson(
    Map<String, dynamic> json, {
    DateTime? fetchedAt,
  }) {
    final Object? dataValue = json['data'];
    if (dataValue is! Map) {
      throw const FormatException('Commerce data must be an object.');
    }
    final Map<String, dynamic> data = Map<String, dynamic>.from(dataValue);
    if (data['schema_version'] != 1) {
      throw const FormatException('Unsupported WALKA commerce schema.');
    }

    final Object? mappingsValue = data['mappings'];
    if (mappingsValue is! List) {
      throw const FormatException('Commerce mappings must be a list.');
    }
    final List<WalkaCommerceMapping> mappings = mappingsValue
        .map((Object? value) {
          if (value is! Map) {
            throw const FormatException('Commerce mapping must be an object.');
          }
          return WalkaCommerceMapping.fromJson(
            Map<String, dynamic>.from(value),
          );
        })
        .toList(growable: false);

    final Set<String> identities = <String>{};
    for (final WalkaCommerceMapping mapping in mappings) {
      if (!identities.add('${mapping.variantId}|${mapping.regionMarket}')) {
        throw const FormatException('Duplicate commerce variant/market mapping.');
      }
    }

    final Object? verificationValue = data['verification'];
    if (verificationValue is! Map) {
      throw const FormatException('Commerce verification metadata is required.');
    }
    final Map<String, dynamic> verification = Map<String, dynamic>.from(
      verificationValue,
    );
    if (verification['algorithm'] != 'sha256' ||
        verification['schema_version'] != 1) {
      throw const FormatException('Unsupported commerce verification contract.');
    }
    final Object? revisionValue = verification['published_revision'];
    if (revisionValue is! int || revisionValue < 1) {
      throw const FormatException('Commerce published revision must be positive.');
    }
    final Object? digestValue = verification['digest'];
    if (digestValue is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(digestValue)) {
      throw const FormatException('Commerce verification digest is invalid.');
    }
    if (verification['active_mapping_count'] != mappings.length) {
      throw const FormatException('Commerce verification mapping count mismatch.');
    }

    final Object? marketsValue = verification['markets'];
    if (marketsValue is! List) {
      throw const FormatException('Commerce verification markets are invalid.');
    }
    final List<String> expectedMarkets = mappings
        .map((WalkaCommerceMapping mapping) => mapping.regionMarket)
        .toSet()
        .toList()
      ..sort();
    final List<String> suppliedMarkets = marketsValue.map((Object? value) {
      if (value is! String) {
        throw const FormatException('Commerce verification market is invalid.');
      }
      return WalkaProtectedCommerceMaster.normalizeMarket(value);
    }).toSet().toList()
      ..sort();
    if (!_sameStrings(expectedMarkets, suppliedMarkets)) {
      throw const FormatException('Commerce verification market set mismatch.');
    }

    return WalkaCommerceSnapshot(
      revision: revisionValue,
      verificationDigest: digestValue,
      mappings: List<WalkaCommerceMapping>.unmodifiable(mappings),
      fetchedAt: (fetchedAt ?? DateTime.now()).toUtc(),
      source: WalkaCommerceSource.remote,
    );
  }

  WalkaCommerceSnapshot asSource(WalkaCommerceSource nextSource) {
    return WalkaCommerceSnapshot(
      revision: revision,
      verificationDigest: verificationDigest,
      mappings: mappings,
      fetchedAt: fetchedAt,
      source: nextSource,
    );
  }

  WalkaCommerceMapping? mappingFor(String variantId, String market) {
    final String normalizedMarket = WalkaProtectedCommerceMaster.normalizeMarket(
      market,
    );
    for (final WalkaCommerceMapping mapping in mappings) {
      if (mapping.variantId == variantId &&
          mapping.regionMarket == normalizedMarket) {
        return mapping;
      }
    }
    return null;
  }

  Map<String, dynamic> toCacheJson() {
    if (revision < 1 || verificationDigest == null) {
      throw const FormatException('Bundled commerce fallback is not cacheable.');
    }
    return <String, dynamic>{
      'cache_schema': 1,
      'revision': revision,
      'verification_digest': verificationDigest,
      'fetched_at': fetchedAt.toIso8601String(),
      'mappings': mappings
          .map((WalkaCommerceMapping mapping) => mapping.toJson())
          .toList(growable: false),
    };
  }

  factory WalkaCommerceSnapshot.fromCacheJson(Map<String, dynamic> json) {
    if (json['cache_schema'] != 1) {
      throw const FormatException('Unsupported commerce cache schema.');
    }
    final Object? revisionValue = json['revision'];
    final Object? digestValue = json['verification_digest'];
    final Object? fetchedValue = json['fetched_at'];
    final Object? mappingsValue = json['mappings'];
    final DateTime? fetchedAt = fetchedValue is String
        ? DateTime.tryParse(fetchedValue)?.toUtc()
        : null;
    if (revisionValue is! int ||
        revisionValue < 1 ||
        digestValue is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(digestValue) ||
        fetchedAt == null ||
        mappingsValue is! List) {
      throw const FormatException('Invalid commerce cache snapshot.');
    }
    final List<WalkaCommerceMapping> mappings = mappingsValue.map((Object? value) {
      if (value is! Map) {
        throw const FormatException('Cached commerce mapping must be an object.');
      }
      return WalkaCommerceMapping.fromJson(Map<String, dynamic>.from(value));
    }).toList(growable: false);

    return WalkaCommerceSnapshot(
      revision: revisionValue,
      verificationDigest: digestValue,
      mappings: List<WalkaCommerceMapping>.unmodifiable(mappings),
      fetchedAt: fetchedAt,
      source: WalkaCommerceSource.cache,
    );
  }
}

String _requiredString(Map<String, dynamic> json, String key) {
  final Object? value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string.');
  }
  return value.trim();
}

bool _machineKey(String value) {
  return RegExp(r'^[a-z][a-z0-9._-]{1,63}$').hasMatch(value.trim());
}

bool _sameStrings(List<String> left, List<String> right) {
  if (left.length != right.length) return false;
  for (int index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) return false;
  }
  return true;
}
