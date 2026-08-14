import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/content/content_state.dart';
import 'package:walka/features/content/data/walka_information_cache.dart';
import 'package:walka/features/content/data/walka_information_repository.dart';
import 'package:walka/features/content/domain/walka_information_content.dart';
import 'package:walka/features/content/domain/walka_mobile_content.dart';
import 'package:walka/features/information/information_cms_v140.dart';
import 'package:walka/features/storefront/account_about_cms_v140.dart';

void main() {
  test('Information contract strips unknown destinations and rejects unsafe identity', () {
    final Map<String, dynamic> json = _cloneBundled();
    (json['support'] as Map<String, dynamic>)['website_url'] =
        'https://attacker.example';
    (json['legal'] as Map<String, dynamic>)['html'] = '<script>bad()</script>';

    final WalkaInformationContent content = WalkaInformationContent.fromJson(json);
    expect(content.toJson()['support'], isNot(contains('website_url')));
    expect(content.toJson()['legal'], isNot(contains('html')));

    final Map<String, dynamic> badEmail = _cloneBundled();
    (badEmail['support'] as Map<String, dynamic>)['support_email'] =
        'attacker@example.com';
    expect(
      () => WalkaInformationContent.fromJson(badEmail),
      throwsFormatException,
    );

    final Map<String, dynamic> duplicateFaq = _cloneBundled();
    final List<dynamic> faqItems =
        ((duplicateFaq['faq'] as Map<String, dynamic>)['items'] as List<dynamic>);
    (faqItems[1] as Map<String, dynamic>)['id'] =
        (faqItems[0] as Map<String, dynamic>)['id'];
    expect(
      () => WalkaInformationContent.fromJson(duplicateFaq),
      throwsFormatException,
    );

    final Map<String, dynamic> missingReviewNotice = _cloneBundled();
    (missingReviewNotice['legal'] as Map<String, dynamic>)
        .remove('review_notice_title');
    expect(
      () => WalkaInformationContent.fromJson(missingReviewNotice),
      throwsFormatException,
    );
  });

  test('Information repository uses newer remote and protects revision-aware LKG', () async {
    final _MemoryInformationCache cache = _MemoryInformationCache();
    final WalkaInformationContent revisionSeven = _contentWith(
      heroTitle: 'Remote About revision seven',
      faqQuestion: 'Remote FAQ revision seven?',
    );

    final WalkaInformationSnapshot remote = await WalkaInformationRepository(
      cache: cache,
      remoteLoader: () async => _payload(7, revisionSeven),
      clock: () => DateTime.utc(2026, 8, 14, 3),
    ).load();
    expect(remote.source, WalkaContentSource.remote);
    expect(remote.revision, 7);
    expect(cache.value?.revision, 7);

    final WalkaInformationSnapshot older = await WalkaInformationRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        6,
        _contentWith(heroTitle: 'Older remote must not win'),
      ),
    ).load();
    expect(older.source, WalkaContentSource.cache);
    expect(older.revision, 7);
    expect(older.content.about.heroTitle, 'Remote About revision seven');

    final WalkaInformationSnapshot divergent = await WalkaInformationRepository(
      cache: cache,
      remoteLoader: () async => _payload(
        7,
        _contentWith(heroTitle: 'Divergent same revision must not win'),
      ),
    ).load();
    expect(divergent.source, WalkaContentSource.cache);
    expect(divergent.content.about.heroTitle, 'Remote About revision seven');
  });

  testWidgets('CMS-040 About renders governed copy through the production composition',
      (WidgetTester tester) async {
    final WalkaContentController controller = await _controller(
      _contentWith(heroTitle: 'Backend-controlled About hero'),
    );
    addTearDown(controller.dispose);

    await _pump(
      tester,
      controller,
      const WalkaAboutCmsV140(),
    );

    expect(find.text('Backend-controlled About hero'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('reference-about-hero')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('reference-about-values')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('reference-about-closing')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('CMS-041 FAQ renders governed ordered entries',
      (WidgetTester tester) async {
    final WalkaContentController controller = await _controller(
      _contentWith(faqQuestion: 'A live backend FAQ question?'),
    );
    addTearDown(controller.dispose);

    await _pump(tester, controller, const WalkaFaqCmsV140());

    expect(find.text('A live backend FAQ question?'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('cms-faq-lunch-leakproof')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('CMS-042 Support renders governed email while destinations stay compiled',
      (WidgetTester tester) async {
    final WalkaContentController controller = await _controller(
      _contentWith(
        supportEmail: 'care@walkastore.com',
        supportTitle: 'Talk to WALKA support',
      ),
    );
    addTearDown(controller.dispose);

    await _pump(tester, controller, const WalkaContactCmsV140());

    expect(find.text('Talk to WALKA support'), findsOneWidget);
    expect(find.textContaining('care@walkastore.com'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('cms-support-website')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('cms-support-instagram')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('CMS-043 Legal renders governed terms and mandatory review notice',
      (WidgetTester tester) async {
    final WalkaContentController controller = await _controller(
      _contentWith(
        termsTitle: 'Backend-controlled Terms',
        reviewNoticeTitle: 'Mandatory legal review gate',
      ),
    );
    addTearDown(controller.dispose);

    await _pump(
      tester,
      controller,
      const WalkaLegalCmsV140(type: WalkaLegalTypeCmsV140.terms),
    );

    expect(find.text('Backend-controlled Terms'), findsOneWidget);
    expect(find.text('Mandatory legal review gate'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('cms-legal-review-notice')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<WalkaContentController> _controller(WalkaInformationContent content) async {
  final WalkaContentController controller = WalkaContentController(
    informationRepository: WalkaInformationRepository(
      cache: _MemoryInformationCache(),
      remoteLoader: () async => _payload(12, content),
      clock: () => DateTime.utc(2026, 8, 14, 4),
    ),
  );
  await controller.load();
  return controller;
}

Future<void> _pump(
  WidgetTester tester,
  WalkaContentController controller,
  Widget child,
) async {
  tester.view.physicalSize = const Size(390, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    WalkaContentScope(
      controller: controller,
      child: MaterialApp(
        theme: buildWalkaTheme(),
        home: child,
      ),
    ),
  );
  await tester.pump();
}

WalkaInformationContent _contentWith({
  String? heroTitle,
  String? faqQuestion,
  String? supportEmail,
  String? supportTitle,
  String? termsTitle,
  String? reviewNoticeTitle,
}) {
  final Map<String, dynamic> json = _cloneBundled();
  if (heroTitle != null) {
    (json['about'] as Map<String, dynamic>)['hero_title'] = heroTitle;
  }
  if (faqQuestion != null) {
    final List<dynamic> items =
        ((json['faq'] as Map<String, dynamic>)['items'] as List<dynamic>);
    (items.first as Map<String, dynamic>)['question'] = faqQuestion;
  }
  if (supportEmail != null) {
    (json['support'] as Map<String, dynamic>)['support_email'] = supportEmail;
  }
  if (supportTitle != null) {
    (json['support'] as Map<String, dynamic>)['title'] = supportTitle;
  }
  if (termsTitle != null) {
    final Map<String, dynamic> legal = json['legal'] as Map<String, dynamic>;
    (legal['terms'] as Map<String, dynamic>)['title'] = termsTitle;
  }
  if (reviewNoticeTitle != null) {
    (json['legal'] as Map<String, dynamic>)['review_notice_title'] =
        reviewNoticeTitle;
  }
  return WalkaInformationContent.fromJson(json);
}

Map<String, dynamic> _cloneBundled() {
  return Map<String, dynamic>.from(
    jsonDecode(jsonEncode(WalkaInformationContent.bundled.toJson())) as Map,
  );
}

WalkaInformationPayload _payload(
  int revision,
  WalkaInformationContent content,
) {
  return WalkaInformationPayload(
    content: content,
    revision: revision,
    publishedAt: DateTime.utc(2026, 8, 14, 2),
  );
}

class _MemoryInformationCache implements WalkaInformationCache {
  WalkaInformationSnapshot? value;

  @override
  Future<void> clear() async {
    value = null;
  }

  @override
  Future<WalkaInformationSnapshot?> read() async => value;

  @override
  Future<void> write(WalkaInformationSnapshot snapshot) async {
    value = snapshot;
  }
}
