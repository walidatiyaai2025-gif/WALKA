import 'package:flutter/material.dart';

import '../../design_system/components/layout/walka_content_width.dart';
import '../../design_system/components/layout/walka_responsive_grid.dart';
import '../../design_system/walka_platform_adaptive.dart';
import '../../design_system/walka_theme.dart';
import '../information/information_v102.dart';
import 'presentation/widgets/about/walka_about_closing.dart';
import 'presentation/widgets/about/walka_about_hero.dart';
import 'presentation/widgets/about/walka_about_principles.dart';
import 'presentation/widgets/about/walka_about_story_intro.dart';
import 'presentation/widgets/about/walka_about_values.dart';
import 'presentation/widgets/account/walka_account_groups.dart';
import 'presentation/widgets/account/walka_account_identity.dart';
import 'presentation/widgets/account/walka_account_overview.dart';
import 'presentation/widgets/account/walka_account_top_bar.dart';
import 'secondary_premium_v130.dart' show WalkaAppInfoPremiumV130;

/// Android/iOS/desktop Account composition backed only by released WALKA state.
class WalkaAccountReferenceV131 extends StatelessWidget {
  const WalkaAccountReferenceV131({required this.onFavorites, super.key});

  final VoidCallback onFavorites;

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          const WalkaAccountTopBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double width = constraints.maxWidth;
                final WalkaWindowClass window =
                    WalkaPlatformAdaptive.windowClassForWidth(width);
                final bool desktop = window == WalkaWindowClass.desktop;
                final WalkaContentTier tier =
                    WalkaContentWidthMetrics.tierForWidth(width);
                final double maxWidth =
                    WalkaContentWidthMetrics.maxWidthForTier(tier);
                final double gutter =
                    WalkaPlatformAdaptive.horizontalGutterForWidth(width);

                final Widget productSupport = WalkaAccountProductSupportGroup(
                  onFavorites: onFavorites,
                  onOurStory: () =>
                      _push(context, const WalkaAboutReferenceV131()),
                  onFaq: () => _push(context, const WalkaFaqV102()),
                  onContact: () => _push(context, const WalkaContactV102()),
                );
                final Widget official = WalkaAccountOfficialDestinationsGroup(
                  onAmazonStore: () =>
                      _push(context, const WalkaAmazonStoreV102()),
                  onSocial: () => _push(context, const WalkaSocialV102()),
                );
                final Widget legal = WalkaAccountLegalAppGroup(
                  onPrivacy: () => _push(
                    context,
                    const WalkaLegalV102(type: WalkaLegalTypeV102.privacy),
                  ),
                  onTerms: () => _push(
                    context,
                    const WalkaLegalV102(type: WalkaLegalTypeV102.terms),
                  ),
                  onAppInfo: () =>
                      _push(context, const WalkaAppInfoPremiumV130()),
                );

                return CustomScrollView(
                  key: const PageStorageKey<String>(
                    'walka-reference-account-scroll',
                  ),
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxWidth),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              gutter,
                              22,
                              gutter,
                              42 + MediaQuery.paddingOf(context).bottom,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                if (desktop)
                                  const Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            WalkaAccountIdentity(),
                                            SizedBox(height: 16),
                                            WalkaAccountDestinationNotice(),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 24),
                                      Expanded(child: WalkaAccountOverview()),
                                    ],
                                  )
                                else ...const <Widget>[
                                  WalkaAccountIdentity(),
                                  SizedBox(height: 16),
                                  WalkaAccountDestinationNotice(),
                                  SizedBox(height: 24),
                                  WalkaAccountOverview(),
                                ],
                                const SizedBox(height: 24),
                                WalkaResponsiveGrid(
                                  minItemWidth: desktop ? 300 : 520,
                                  maxColumns: 3,
                                  gap: 20,
                                  runGap: 22,
                                  children: <Widget>[
                                    productSupport,
                                    official,
                                    legal,
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Android/iOS/desktop Our Story composition using the same truthful content.
class WalkaAboutReferenceV131 extends StatelessWidget {
  const WalkaAboutReferenceV131({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: const Text(
          'WALKA',
          style: TextStyle(
            color: WalkaColors.navy,
            fontFamily: 'serif',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.6,
          ),
        ),
        shape: const Border(
          bottom: BorderSide(color: WalkaColors.line, width: 0.7),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            final WalkaWindowClass window =
                WalkaPlatformAdaptive.windowClassForWidth(width);
            final bool desktop = window == WalkaWindowClass.desktop;
            final WalkaContentTier tier =
                WalkaContentWidthMetrics.tierForWidth(width);
            final double maxWidth = WalkaContentWidthMetrics.maxWidthForTier(tier);
            final double gutter =
                WalkaPlatformAdaptive.horizontalGutterForWidth(width);

            return SingleChildScrollView(
              key: const PageStorageKey<String>('walka-reference-about-scroll'),
              padding: EdgeInsets.fromLTRB(
                gutter,
                18,
                gutter,
                42 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (desktop)
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(flex: 6, child: WalkaAboutHero()),
                            SizedBox(width: 28),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: WalkaAboutStoryIntro(),
                              ),
                            ),
                          ],
                        )
                      else ...const <Widget>[
                        WalkaAboutHero(),
                        SizedBox(height: 32),
                        WalkaAboutStoryIntro(),
                      ],
                      const SizedBox(height: 28),
                      const WalkaAboutValues(),
                      const SizedBox(height: 28),
                      const WalkaAboutPrinciples(),
                      const SizedBox(height: 28),
                      const WalkaAboutClosing(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
