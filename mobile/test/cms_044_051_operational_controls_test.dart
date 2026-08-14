import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_operational_cache.dart';
import 'package:walka/features/content/data/walka_operational_repository.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/content/domain/walka_operational_content.dart';
import 'package:walka/features/storefront/account_about_cms_v140.dart';
import 'package:walka/features/storefront/storefront_v102.dart';

void main() {
  group('CMS-044 maintenance notice contract', () {
    test('uses inclusive start and exclusive end and rejects markup', () {
      final WalkaMaintenanceNoticeContent notice =
          WalkaMaintenanceNoticeContent.fromJson(<String, dynamic>{
        'enabled': true,
        'severity': 'maintenance',
        'title': 'Short maintenance window',
        'body': 'Product discovery remains available.',
        'starts_at': '2026-08-14T08:00:00.000Z',
        'ends_at': '2026-08-14T09:00:00.000Z',
      });

      expect(
        notice.isActiveAt(DateTime.parse('2026-08-14T08:00:00Z')),
        isTrue,
      );
      expect(
        notice.isActiveAt(DateTime.parse('2026-08-14T08:59:59Z')),
        isTrue,
      );
      expect(
        notice.isActiveAt(DateTime.parse('2026-08-14T09:00:00Z')),
        isFalse,
      );
      expect(
        () => WalkaMaintenanceNoticeContent.fromJson(<String, dynamic>{
          ...notice.toJson(),
          'body': '<script>alert(1)</script>',
        }),
        throwsFormatException,
      );
    });

    testWidgets('compiled notice banner has inert copy and no remote action',
        (WidgetTester tester) async {
      const WalkaMaintenanceNoticeContent notice =
          WalkaMaintenanceNoticeContent(
        enabled: true,
        severity: 'warning',
        title: 'Service update',
        body: 'Product discovery remains available.',
        startsAt: null,
        endsAt: null,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WalkaOperationalNoticeBanner(notice: notice),
          ),
        ),
      );

      expect(find.byKey(const Key('walka-operational-notice')), findsOneWidget);
      expect(find.text('Service update'), findsOneWidget);
      expect(find.text('Product discovery remains available.'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });

  group('CMS-045 compiled App Config', () {
    test('rejects unknown or missing flag identities', () {
      expect(
        () => WalkaAppConfigContent.fromJson(<String, dynamic>{
          'flags': <String, dynamic>{
            'show_operational_notice': true,
            'show_account_service_note': false,
            'disable_authentication': true,
          },
        }),
        throwsFormatException,
      );
      expect(
        () => WalkaAppConfigContent.fromJson(<String, dynamic>{
          'flags': <String, dynamic>{
            'show_operational_notice': true,
          },
        }),
        throwsFormatException,
      );
    });

    testWidgets('account service switch renders only compiled note',
        (WidgetTester tester) async {
      final _MemoryAppConfigCache configCache = _MemoryAppConfigCache();
      final WalkaContentController content = WalkaContentController(
        appConfigRepository: WalkaAppConfigRepository(
          cache: configCache,
          remoteLoader: () async => WalkaAppConfigPayload(
            content: const WalkaAppConfigContent(
              showOperationalNotice: true,
              showAccountServiceNote: true,
            ),
            revision: 4,
            publishedAt: DateTime.parse('2026-08-14T08:00:00Z'),
          ),
        ),
      );
      await content.load();

      await tester.pumpWidget(
        WalkaContentScope(
          controller: content,
          child: MaterialApp(
            home: Scaffold(
              body: WalkaAccountCmsV140(onFavorites: _noop),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('walka-account-service-note')), findsOneWidget);
      expect(find.text('SERVICE INFORMATION'), findsOneWidget);

      content.dispose();
    });
  });

  group('CMS-044/045 revision-aware LKG', () {
    test('older remote snapshots cannot replace newer cached revisions', () async {
      final _MemoryMaintenanceCache noticeCache = _MemoryMaintenanceCache();
      final _MemoryAppConfigCache configCache = _MemoryAppConfigCache();

      final WalkaMaintenanceNoticeRepository noticeV2 =
          WalkaMaintenanceNoticeRepository(
        cache: noticeCache,
        remoteLoader: () async => WalkaMaintenanceNoticePayload(
          content: const WalkaMaintenanceNoticeContent(
            enabled: true,
            severity: 'info',
            title: 'Revision two',
            body: 'Newer notice',
            startsAt: null,
            endsAt: null,
          ),
          revision: 2,
          publishedAt: DateTime.parse('2026-08-14T08:00:00Z'),
        ),
      );
      final WalkaAppConfigRepository configV5 = WalkaAppConfigRepository(
        cache: configCache,
        remoteLoader: () async => WalkaAppConfigPayload(
          content: const WalkaAppConfigContent(
            showOperationalNotice: true,
            showAccountServiceNote: true,
          ),
          revision: 5,
          publishedAt: DateTime.parse('2026-08-14T08:00:00Z'),
        ),
      );

      expect((await noticeV2.load()).revision, 2);
      expect((await configV5.load()).revision, 5);

      final WalkaMaintenanceNoticeSnapshot noticeAfterOlder =
          await WalkaMaintenanceNoticeRepository(
        cache: noticeCache,
        remoteLoader: () async => WalkaMaintenanceNoticePayload(
          content: const WalkaMaintenanceNoticeContent(
            enabled: false,
            severity: 'info',
            title: 'Revision one',
            body: 'Older notice',
            startsAt: null,
            endsAt: null,
          ),
          revision: 1,
          publishedAt: DateTime.parse('2026-08-14T07:00:00Z'),
        ),
      ).load();
      final WalkaAppConfigSnapshot configAfterOlder =
          await WalkaAppConfigRepository(
        cache: configCache,
        remoteLoader: () async => WalkaAppConfigPayload(
          content: const WalkaAppConfigContent(
            showOperationalNotice: false,
            showAccountServiceNote: false,
          ),
          revision: 4,
          publishedAt: DateTime.parse('2026-08-14T07:00:00Z'),
        ),
      ).load();

      expect(noticeAfterOlder.revision, 2);
      expect(noticeAfterOlder.content.title, 'Revision two');
      expect(noticeAfterOlder.source, WalkaContentSource.cache);
      expect(configAfterOlder.revision, 5);
      expect(configAfterOlder.content.showAccountServiceNote, isTrue);
      expect(configAfterOlder.source, WalkaContentSource.cache);
    });

    test('divergent same-revision remote content also preserves LKG', () async {
      final _MemoryAppConfigCache cache = _MemoryAppConfigCache()
        ..snapshot = WalkaAppConfigSnapshot(
          content: const WalkaAppConfigContent(
            showOperationalNotice: true,
            showAccountServiceNote: false,
          ),
          revision: 7,
          publishedAt: DateTime.parse('2026-08-14T08:00:00Z'),
          fetchedAt: DateTime.parse('2026-08-14T08:00:01Z'),
          source: WalkaContentSource.remote,
        );

      final WalkaAppConfigSnapshot result = await WalkaAppConfigRepository(
        cache: cache,
        remoteLoader: () async => WalkaAppConfigPayload(
          content: const WalkaAppConfigContent(
            showOperationalNotice: false,
            showAccountServiceNote: true,
          ),
          revision: 7,
          publishedAt: DateTime.parse('2026-08-14T08:00:00Z'),
        ),
      ).load();

      expect(result.revision, 7);
      expect(result.content.showOperationalNotice, isTrue);
      expect(result.content.showAccountServiceNote, isFalse);
      expect(result.source, WalkaContentSource.cache);
    });
  });
}

void _noop() {}

class _MemoryMaintenanceCache implements WalkaMaintenanceNoticeCache {
  WalkaMaintenanceNoticeSnapshot? snapshot;

  @override
  Future<WalkaMaintenanceNoticeSnapshot?> read() async => snapshot;

  @override
  Future<void> write(WalkaMaintenanceNoticeSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}

class _MemoryAppConfigCache implements WalkaAppConfigCache {
  WalkaAppConfigSnapshot? snapshot;

  @override
  Future<WalkaAppConfigSnapshot?> read() async => snapshot;

  @override
  Future<void> write(WalkaAppConfigSnapshot snapshot) async {
    this.snapshot = snapshot;
  }
}
