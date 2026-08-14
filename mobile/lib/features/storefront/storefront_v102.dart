import 'package:flutter/material.dart';

import '../../design_system/walka_adaptive.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../catalog/catalog_state.dart';
import '../content/content_state.dart';
import '../content/domain/walka_operational_content.dart';
import 'account_about_cms_v140.dart';
import 'favorites_reference_v131.dart';
import 'storefront_resilient_v130.dart';

/// API-002 connected storefront entry surface with premium reusable shell.
class WalkaStorefrontSplashV102 extends StatelessWidget {
  const WalkaStorefrontSplashV102({super.key});

  @override
  Widget build(BuildContext context) {
    final bool compact =
        MediaQuery.sizeOf(context).width < WalkaAdaptiveMetrics.compactWidth;

    return Scaffold(
      backgroundColor: WalkaColors.navy,
      body: WalkaAdaptiveFrame(
        backgroundColor: WalkaColors.navy,
        child: WalkaSafeAreaChrome(
          backgroundColor: WalkaColors.navy,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        WalkaShellMetrics.horizontalGutter(context),
                        compact ? 18 : 24,
                        WalkaShellMetrics.horizontalGutter(context),
                        compact ? 20 : 28,
                      ),
                      child: WalkaSplashContent(
                        compact: compact,
                        onEnter: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute<void>(
                              builder: (_) => const WalkaStorefrontShellV102(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class WalkaStorefrontShellV102 extends StatefulWidget {
  const WalkaStorefrontShellV102({super.key});

  @override
  State<WalkaStorefrontShellV102> createState() =>
      _WalkaStorefrontShellV102State();
}

class _WalkaStorefrontShellV102State extends State<WalkaStorefrontShellV102> {
  late final WalkaCatalogController _fallbackCatalog = WalkaCatalogController();
  late final WalkaShellController _shellController = WalkaShellController();

  void _select(WalkaShellDestination destination) {
    FocusManager.instance.primaryFocus?.unfocus();
    _shellController.select(destination);
  }

  @override
  void dispose() {
    _shellController.dispose();
    _fallbackCatalog.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (WalkaCatalogScope.maybeOf(context) == null) {
      return WalkaCatalogScope(
        controller: _fallbackCatalog,
        child: Builder(builder: _buildShell),
      );
    }
    return _buildShell(context);
  }

  Widget _buildShell(BuildContext context) {
    final List<Widget> pages = <Widget>[
      WalkaHomePremiumV130(
        onShopAll: () => _select(WalkaShellDestination.categories),
        onSearch: () => _select(WalkaShellDestination.search),
      ),
      const WalkaSearchPremiumV130(),
      WalkaCategoriesPremiumV130(
        onSearch: () => _select(WalkaShellDestination.search),
      ),
      WalkaFavoritesReferenceV131(
        onExplore: () => _select(WalkaShellDestination.categories),
      ),
      WalkaAccountCmsV140(
        onFavorites: () => _select(WalkaShellDestination.favorites),
      ),
    ];

    final WalkaContentController? content = WalkaContentScope.maybeOf(context);
    final WalkaMaintenanceNoticeContent notice =
        content?.maintenanceNotice.content ?? WalkaMaintenanceNoticeContent.bundled;
    final WalkaAppConfigContent appConfig =
        content?.appConfig.content ?? WalkaAppConfigContent.bundled;
    final bool showOperationalNotice = appConfig.showOperationalNotice &&
        notice.isActiveAt(DateTime.now().toUtc());

    return WalkaMobileShellScaffold(
      controller: _shellController,
      pages: pages,
      topBanner: showOperationalNotice
          ? WalkaOperationalNoticeBanner(notice: notice)
          : null,
    );
  }
}

class WalkaOperationalNoticeBanner extends StatelessWidget {
  const WalkaOperationalNoticeBanner({required this.notice, super.key});

  final WalkaMaintenanceNoticeContent notice;

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (notice.severity) {
      'maintenance' => Icons.build_circle_outlined,
      'warning' => Icons.warning_amber_rounded,
      _ => Icons.info_outline_rounded,
    };

    return SafeArea(
      bottom: false,
      child: Semantics(
        liveRegion: true,
        container: true,
        label: '${notice.title}. ${notice.body}',
        child: Material(
          key: const Key('walka-operational-notice'),
          color: const Color(0xFFFFF8E7),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: WalkaColors.line)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, size: 20, color: WalkaColors.navy),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        notice.title,
                        style: const TextStyle(
                          color: WalkaColors.navy,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        notice.body,
                        style: const TextStyle(
                          color: WalkaColors.muted,
                          height: 1.35,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
