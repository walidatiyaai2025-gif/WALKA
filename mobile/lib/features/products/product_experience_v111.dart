import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../commerce/amazon_purchase.dart';
import '../favorites/favorites_state.dart';
import '../lunch/lunch_box_v6.dart';

/// DESIGN-007B.3 Android-reference Drawer Product Detail.
///
/// The composition follows the approved Android PDP reference while preserving
/// the released Product Master facts, favorites state and Amazon handoff.
class WalkaDrawerProductDetailV111 extends StatefulWidget {
  const WalkaDrawerProductDetailV111({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  State<WalkaDrawerProductDetailV111> createState() =>
      _WalkaDrawerProductDetailV111State();
}

class _WalkaDrawerProductDetailV111State
    extends State<WalkaDrawerProductDetailV111> {
  late bool _gray = widget.initialGray;

  Color get _productColor =>
      _gray ? const Color(0xFFD3D7D9) : const Color(0xFFF7F4EC);
  Color get _surface =>
      _gray ? const Color(0xFFE9ECEE) : const Color(0xFFF4EEDF);

  Future<void> _buy() async {
    final bool launched = await openDrawerOrganizerOnAmazon(gray: _gray);
    if (!mounted || launched) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Amazon could not be opened. Please try again.')),
    );
  }

  Future<void> _toggleFavorite(WalkaFavoritesController controller) async {
    final bool saved = await controller.toggleDrawer(gray: _gray);
    if (!mounted || saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite could not be updated.')),
    );
  }

  Future<void> _share() => _showReferenceShareSheet(
        context,
        title: 'WALKA Drawer Organizer · ${_gray ? 'Gray' : 'White'}',
        uri: amazonDrawerOrganizerUri(gray: _gray),
      );

  void _openGallery(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _ReferenceFullscreenGallery(
          initialIndex: index,
          title: 'Drawer Organizer',
          kind: WalkaProductVisualKind.drawerOrganizer,
          primaryColor: _productColor,
          surface: _surface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WalkaFavoritesController favorites = WalkaFavoritesScope.of(context);
    final bool isFavorite = favorites.isDrawerFavorite(gray: _gray);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: _referencePdpAppBar(
        onShare: _share,
        onFavorite: () => _toggleFavorite(favorites),
        isFavorite: isFavorite,
      ),
      bottomNavigationBar: _ReferenceAmazonBar(
        selectedLabel: _gray ? 'GRAY' : 'WHITE',
        onPressed: _buy,
      ),
      body: _ReferencePdpBody(
        scrollKey: const PageStorageKey<String>('design-007b3-drawer-pdp-scroll'),
        hero: _ReferenceProductGallery(
          key: ValueKey<String>('drawer-gallery-${_gray ? 'gray' : 'white'}'),
          kind: WalkaProductVisualKind.drawerOrganizer,
          primaryColor: _productColor,
          surface: _surface,
          semanticLabel: 'WALKA Drawer Organizer ${_gray ? 'Gray' : 'White'} gallery',
          onExpand: _openGallery,
        ),
        eyebrow: 'DRAWER ORGANIZATION',
        title: 'WALKA Drawer Organizer',
        facts: '8 compartments · 13 × 15 × 2 in · expandable to 22.4 in',
        selectedLabel: '${_gray ? 'Gray' : 'White'} finish',
        variantPicker: _DrawerReferencePicker(
          gray: _gray,
          onChanged: (bool gray) => setState(() => _gray = gray),
        ),
        featureItems: const <_ReferenceFeature>[
          _ReferenceFeature(Icons.grid_view_rounded, '8 compartments'),
          _ReferenceFeature(Icons.open_in_full_rounded, 'Expands to 22.4 in'),
          _ReferenceFeature(Icons.pan_tool_alt_outlined, 'Non-slip base'),
          _ReferenceFeature(Icons.layers_outlined, 'Durable plastic'),
        ],
        detailSections: const <Widget>[
          _ReferenceEditorialPanel(
            title: 'Organize the drawer. Keep the counter calm.',
            body:
                'An expandable eight-compartment layout gives everyday utensils a defined place while keeping the visual language clean and minimal.',
          ),
          SizedBox(height: 14),
          _ReferenceDetailCard(
            title: 'Product details',
            rows: <(String, String)>[
              ('Closed size', '13 × 15 × 2 in'),
              ('Expandable width', '13 to 22.4 in'),
              ('Compartments', '8'),
              ('Base', 'Non-slip'),
              ('Approved finishes', 'White · Gray'),
            ],
          ),
        ],
      ),
    );
  }
}

/// DESIGN-007B.3 Android-reference Lunch Product Detail.
class WalkaLunchProductDetailV111 extends StatefulWidget {
  const WalkaLunchProductDetailV111({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  State<WalkaLunchProductDetailV111> createState() =>
      _WalkaLunchProductDetailV111State();
}

class _WalkaLunchProductDetailV111State
    extends State<WalkaLunchProductDetailV111> {
  late WalkaLunchVariant _variant = widget.initialVariant;
  bool _favorite = false;

  WalkaAmazonLunchVariant get _amazonVariant => switch (_variant) {
        WalkaLunchVariant.blue => WalkaAmazonLunchVariant.blue,
        WalkaLunchVariant.pink => WalkaAmazonLunchVariant.pink,
        WalkaLunchVariant.green => WalkaAmazonLunchVariant.green,
      };

  Future<void> _buy() async {
    final bool launched = await openLunchBoxOnAmazon(_amazonVariant);
    if (!mounted || launched) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Amazon could not be opened. Please try again.')),
    );
  }

  Future<void> _share() => _showReferenceShareSheet(
        context,
        title: 'WALKA Large Bento Lunch Box · ${_variant.label}',
        uri: amazonLunchBoxUri(_amazonVariant),
      );

  void _openGallery(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _ReferenceFullscreenGallery(
          initialIndex: index,
          title: '${_variant.label} Lunch Box',
          kind: WalkaProductVisualKind.lunchBox,
          primaryColor: _variant.color,
          surface: _variant.surface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: _referencePdpAppBar(
        onShare: _share,
        onFavorite: () => setState(() => _favorite = !_favorite),
        isFavorite: _favorite,
      ),
      bottomNavigationBar: _ReferenceAmazonBar(
        selectedLabel: _variant.label.toUpperCase(),
        onPressed: _buy,
      ),
      body: _ReferencePdpBody(
        scrollKey: const PageStorageKey<String>('design-007b3-lunch-pdp-scroll'),
        hero: _ReferenceProductGallery(
          key: ValueKey<WalkaLunchVariant>(_variant),
          kind: WalkaProductVisualKind.lunchBox,
          primaryColor: _variant.color,
          surface: _variant.surface,
          semanticLabel: 'WALKA ${_variant.label} Lunch Box gallery',
          onExpand: _openGallery,
        ),
        eyebrow: 'LUNCH COLLECTION',
        title: 'Large Stainless Steel Bento Lunch Box',
        facts: '1200 ml · 4 compartments · SUS304 stainless steel tray',
        selectedLabel: '${_variant.label} · ${_variant.pantone}',
        variantPicker: _LunchReferencePicker(
          selected: _variant,
          onChanged: (WalkaLunchVariant variant) => setState(() => _variant = variant),
        ),
        usagePanel: const _ApprovedReferenceUsagePanel(),
        featureItems: const <_ReferenceFeature>[
          _ReferenceFeature(Icons.local_drink_outlined, '1200 ml capacity'),
          _ReferenceFeature(Icons.grid_view_rounded, '4 compartments'),
          _ReferenceFeature(Icons.kitchen_outlined, 'SUS304 food tray'),
          _ReferenceFeature(Icons.shopping_bag_outlined, 'Bag + utensils included'),
        ],
        detailSections: const <Widget>[
          _ReferenceEditorialPanel(
            title: 'A complete lunch system for the workday.',
            body:
                'The food-grade stainless tray, PP outer box, sauce cup, utensils and carry bag form one coordinated adult lunch set.',
          ),
          SizedBox(height: 14),
          _ReferenceDetailCard(
            title: 'What is included',
            rows: <(String, String)>[
              ('Bento box', 'PP outer + SUS304 tray'),
              ('Sauce cup', 'Stainless cup with lid'),
              ('Utensils', 'Spoon + fork'),
              ('Carry', 'Carry bag'),
            ],
          ),
          SizedBox(height: 10),
          _ReferenceDetailCard(
            title: 'Dimensions',
            rows: <(String, String)>[
              ('Lunch box', '11.42 × 8.66 × 3.15 in'),
              ('With bag', '11.81 × 8.86 × 3.54 in'),
              ('Bag only', '10.63 × 7.48 × 2.76 in'),
              ('Weight with bag', '1.84 lb'),
            ],
          ),
          SizedBox(height: 10),
          _ReferenceDetailCard(
            title: 'Care & use',
            rows: <(String, String)>[
              ('SUS304 tray', 'Dishwasher safe · not microwave safe'),
              ('Lid & gasket', 'Top-rack dishwasher · not microwave safe'),
              ('Microwave', 'PP outer only · remove tray, lid & gasket'),
              ('Carry', 'Keep upright'),
            ],
          ),
        ],
      ),
    );
  }
}

PreferredSizeWidget _referencePdpAppBar({
  required VoidCallback onShare,
  required VoidCallback onFavorite,
  required bool isFavorite,
}) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    title: const WalkaWordmark(compact: true, showDescriptor: false),
    actions: <Widget>[
      IconButton(
        onPressed: onShare,
        tooltip: 'Share product',
        icon: const Icon(Icons.ios_share_rounded, color: WalkaColors.navy),
      ),
      IconButton(
        onPressed: onFavorite,
        tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: Icon(
            isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey<bool>(isFavorite),
            color: isFavorite ? WalkaColors.gold : WalkaColors.navy,
          ),
        ),
      ),
      const SizedBox(width: 4),
    ],
    shape: const Border(bottom: BorderSide(color: WalkaColors.line, width: 0.7)),
  );
}

class _ReferencePdpBody extends StatelessWidget {
  const _ReferencePdpBody({
    required this.scrollKey,
    required this.hero,
    required this.eyebrow,
    required this.title,
    required this.facts,
    required this.selectedLabel,
    required this.variantPicker,
    required this.featureItems,
    required this.detailSections,
    this.usagePanel,
  });

  final Key scrollKey;
  final Widget hero;
  final String eyebrow;
  final String title;
  final String facts;
  final String selectedLabel;
  final Widget variantPicker;
  final List<_ReferenceFeature> featureItems;
  final List<Widget> detailSections;
  final Widget? usagePanel;

  @override
  Widget build(BuildContext context) {
    final double gutter = WalkaShellMetrics.horizontalGutter(context);
    return SingleChildScrollView(
      key: scrollKey,
      padding: EdgeInsets.fromLTRB(gutter, 12, gutter, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          hero,
          const SizedBox(height: 18),
          Text(eyebrow, style: WalkaType.eyebrow),
          const SizedBox(height: 7),
          Text(
            title,
            key: const ValueKey<String>('reference-pdp-title'),
            style: const TextStyle(
              fontFamily: 'serif',
              color: WalkaColors.navy,
              fontSize: 30,
              height: 1.04,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.45,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            facts,
            style: const TextStyle(
              color: WalkaColors.muted,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: WalkaColors.line),
          const SizedBox(height: 16),
          const Text(
            'COLOR / FINISH',
            style: TextStyle(
              color: WalkaColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedLabel,
            key: const ValueKey<String>('premium-pdp-selected-variant'),
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          variantPicker,
          if (usagePanel != null) ...<Widget>[
            const SizedBox(height: 18),
            usagePanel!,
          ],
          const SizedBox(height: 24),
          const Text('WHY WALKA', style: WalkaType.eyebrow),
          const SizedBox(height: 12),
          _ReferenceFeatureGrid(items: featureItems),
          const SizedBox(height: 24),
          ...detailSections,
        ],
      ),
    );
  }
}

class _ReferenceProductGallery extends StatefulWidget {
  const _ReferenceProductGallery({
    required this.kind,
    required this.primaryColor,
    required this.surface,
    required this.semanticLabel,
    required this.onExpand,
    super.key,
  });

  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;
  final String semanticLabel;
  final ValueChanged<int> onExpand;

  @override
  State<_ReferenceProductGallery> createState() => _ReferenceProductGalleryState();
}

class _ReferenceProductGalleryState extends State<_ReferenceProductGallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.02,
          child: Material(
            color: widget.surface,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                PageView.builder(
                  controller: _controller,
                  itemCount: 3,
                  onPageChanged: (int value) => setState(() => _index = value),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () => widget.onExpand(index),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(index == 0 ? 22 : 30),
                          child: Transform.rotate(
                            angle: index == 1 ? -0.035 : 0,
                            child: Transform.scale(
                              scale: index == 2 ? 0.90 : 1,
                              child: WalkaProductVisual(
                                kind: widget.kind,
                                primaryColor: widget.primaryColor,
                                backgroundColor: widget.surface,
                                semanticLabel: '${widget.semanticLabel} view ${index + 1}',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.94),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () => widget.onExpand(_index),
                      tooltip: 'View fullscreen',
                      icon: const Icon(Icons.fullscreen_rounded, color: WalkaColors.navy),
                    ),
                  ),
                ),
                Positioned(
                  left: 13,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_index + 1} / 3',
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (int item) {
            final bool selected = item == _index;
            return Semantics(
              button: true,
              selected: selected,
              label: 'Gallery view ${item + 1}',
              child: InkWell(
                onTap: () => _controller.animateToPage(
                  item,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                ),
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  width: 44,
                  height: 38,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: selected ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: selected ? WalkaColors.navy : WalkaColors.line,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ReferenceFullscreenGallery extends StatefulWidget {
  const _ReferenceFullscreenGallery({
    required this.initialIndex,
    required this.title,
    required this.kind,
    required this.primaryColor,
    required this.surface,
  });

  final int initialIndex;
  final String title;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;

  @override
  State<_ReferenceFullscreenGallery> createState() => _ReferenceFullscreenGalleryState();
}

class _ReferenceFullscreenGalleryState extends State<_ReferenceFullscreenGallery> {
  late final PageController _controller = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: 3,
              onPageChanged: (int value) => setState(() => _index = value),
              itemBuilder: (BuildContext context, int index) {
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 3.2,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: WalkaProductVisual(
                        kind: widget.kind,
                        primaryColor: widget.primaryColor,
                        backgroundColor: widget.surface,
                        semanticLabel: '${widget.title} fullscreen view ${index + 1}',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
              child: Text(
                '${_index + 1} / 3',
                style: const TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerReferencePicker extends StatelessWidget {
  const _DrawerReferencePicker({required this.gray, required this.onChanged});

  final bool gray;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: <Widget>[
        _ReferenceVariantTile(
          key: const ValueKey<String>('premium-drawer-white'),
          label: 'White',
          color: const Color(0xFFF7F4EC),
          selected: !gray,
          onTap: () => onChanged(false),
        ),
        _ReferenceVariantTile(
          key: const ValueKey<String>('premium-drawer-gray'),
          label: 'Gray',
          color: const Color(0xFFD3D7D9),
          selected: gray,
          onTap: () => onChanged(true),
        ),
      ],
    );
  }
}

class _LunchReferencePicker extends StatelessWidget {
  const _LunchReferencePicker({required this.selected, required this.onChanged});

  final WalkaLunchVariant selected;
  final ValueChanged<WalkaLunchVariant> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: WalkaLunchVariant.values
          .map(
            (WalkaLunchVariant variant) => _ReferenceVariantTile(
              key: ValueKey<String>('premium-lunch-${variant.name}'),
              label: variant.label,
              color: variant.color,
              selected: selected == variant,
              onTap: () => onChanged(variant),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _ReferenceVariantTile extends StatelessWidget {
  const _ReferenceVariantTile({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFFFF8E7) : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minWidth: 88, minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? WalkaColors.gold : WalkaColors.line,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: WalkaColors.navy.withValues(alpha: 0.12)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprovedReferenceUsagePanel extends StatelessWidget {
  const _ApprovedReferenceUsagePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-approved-lunch-usage'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEDF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'ADULT LUNCH · UPRIGHT CARRY',
            style: TextStyle(
              color: WalkaColors.gold,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Best for dry & semi-wet foods · Not intended for liquids · Carry upright',
            style: TextStyle(
              color: WalkaColors.navy,
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceFeatureGrid extends StatelessWidget {
  const _ReferenceFeatureGrid({required this.items});

  final List<_ReferenceFeature> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items
              .map(
                (_ReferenceFeature item) => SizedBox(
                  width: width,
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 86),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: WalkaColors.line),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(item.icon, color: WalkaColors.gold, size: 21),
                        const SizedBox(height: 9),
                        Text(
                          item.label,
                          style: const TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 10.5,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _ReferenceFeature {
  const _ReferenceFeature(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _ReferenceEditorialPanel extends StatelessWidget {
  const _ReferenceEditorialPanel({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'DESIGNED FOR EVERYDAY ORDER',
            style: TextStyle(
              color: WalkaColors.gold,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.9,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'serif',
              fontSize: 22,
              height: 1.08,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFD6E0E8),
              fontSize: 11.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceDetailCard extends StatelessWidget {
  const _ReferenceDetailCard({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...rows.map(
            ((String, String) row) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      row.$1,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceAmazonBar extends StatelessWidget {
  const _ReferenceAmazonBar({required this.selectedLabel, required this.onPressed});

  final String selectedLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool compact = MediaQuery.sizeOf(context).width < 350;
    return Material(
      color: Colors.white,
      elevation: 14,
      shadowColor: WalkaColors.navy.withValues(alpha: 0.10),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(compact ? 12 : 16, 10, compact ? 12 : 16, 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'SELECTED',
                      style: TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      selectedLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: compact ? 162 : 180),
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: const Icon(Icons.open_in_new_rounded, size: 17),
                  label: const Text('BUY ON AMAZON'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showReferenceShareSheet(
  BuildContext context, {
  required String title,
  required Uri uri,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('SHARE WALKA', style: WalkaType.eyebrow),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: WalkaColors.navy,
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                uri.toString(),
                style: const TextStyle(color: WalkaColors.muted, fontSize: 11.5),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: uri.toString()));
                    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                  },
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('COPY PRODUCT LINK'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
