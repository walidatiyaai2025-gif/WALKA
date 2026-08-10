import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../commerce/amazon_purchase.dart';
import '../favorites/favorites_state.dart';
import '../lunch/lunch_box_v6.dart';

/// DESIGN-004 premium Drawer Product Detail surface.
///
/// Product facts remain governed by docs/PRODUCT_MASTER.md. Purchase continues
/// to hand off to the selected official Amazon listing.
class WalkaDrawerProductDetailV110 extends StatefulWidget {
  const WalkaDrawerProductDetailV110({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  State<WalkaDrawerProductDetailV110> createState() =>
      _WalkaDrawerProductDetailV110State();
}

class _WalkaDrawerProductDetailV110State
    extends State<WalkaDrawerProductDetailV110> {
  late bool _gray = widget.initialGray;

  Color get _productColor =>
      _gray ? const Color(0xFFD3D7D9) : const Color(0xFFF7F4EC);

  Color get _surface =>
      _gray ? const Color(0xFFE8EAEC) : const Color(0xFFF3EEDF);

  Future<void> _buy() async {
    final bool launched = await openDrawerOrganizerOnAmazon(gray: _gray);
    if (!mounted || launched) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Amazon could not be opened. Please try again.'),
      ),
    );
  }

  Future<void> _share() {
    return _showPremiumShareSheet(
      context,
      title: 'WALKA Drawer Organizer · ${_gray ? 'Gray' : 'White'}',
      uri: amazonDrawerOrganizerUri(gray: _gray),
    );
  }

  Future<void> _toggleFavorite(WalkaFavoritesController controller) async {
    final bool saved = await controller.toggleDrawer(gray: _gray);
    if (!mounted || saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite could not be updated.')),
    );
  }

  void _openGallery(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _PremiumFullscreenGalleryV110(
          initialIndex: index,
          title: 'Drawer Organizer',
          visualKind: WalkaProductVisualKind.drawerOrganizer,
          primaryColor: _productColor,
          backgroundColor: _surface,
        ),
      ),
    );
  }

  void _openLunch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WalkaLunchProductDetailV110(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WalkaFavoritesController favorites = WalkaFavoritesScope.of(context);
    final bool isFavorite = favorites.isDrawerFavorite(gray: _gray);
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return Scaffold(
      appBar: _premiumPdpAppBar(
        onShare: _share,
        onFavorite: () => _toggleFavorite(favorites),
        isFavorite: isFavorite,
      ),
      bottomNavigationBar: _ResponsiveAmazonPurchaseBarV110(
        selectedLabel: _gray ? 'GRAY' : 'WHITE',
        onPressed: _buy,
      ),
      body: SingleChildScrollView(
        key: const PageStorageKey<String>('design-004-drawer-pdp-scroll'),
        padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _PremiumProductGalleryV110(
              key: ValueKey<String>('drawer-gallery-${_gray ? 'gray' : 'white'}'),
              visualKind: WalkaProductVisualKind.drawerOrganizer,
              primaryColor: _productColor,
              backgroundColor: _surface,
              semanticLabel:
                  'WALKA Drawer Organizer ${_gray ? 'Gray' : 'White'} gallery',
              onExpand: _openGallery,
            ),
            const SizedBox(height: 18),
            _PremiumCommerceSummaryV110(
              eyebrow: 'DRAWER ORGANIZATION',
              title: 'WALKA Drawer Organizer',
              facts: '8 compartments · Expandable to 22.4 in · Non-slip base',
              selectedLabel: '${_gray ? 'Gray' : 'White'} finish',
              variantPicker: _DrawerVariantPickerV110(
                gray: _gray,
                onChanged: (bool gray) => setState(() => _gray = gray),
              ),
            ),
            const SizedBox(height: 22),
            const _PremiumFactGridV110(
              facts: <(IconData, String, String)>[
                (Icons.grid_view_rounded, 'Compartments', '8'),
                (Icons.straighten_rounded, 'Closed size', '13 × 15 × 2 in'),
                (Icons.open_in_full_rounded, 'Expandable', 'Up to 22.4 in'),
                (Icons.pan_tool_alt_outlined, 'Base', 'Non-slip'),
              ],
            ),
            const SizedBox(height: 24),
            const _EditorialPdpPanelV110(
              eyebrow: 'MADE FOR DAILY ORDER',
              title: 'A calmer drawer starts with clear structure.',
              body:
                  'Eight compartments and an expandable footprint give everyday cutlery and utensils a defined place without adding visual clutter.',
              icon: Icons.auto_awesome_outlined,
            ),
            const SizedBox(height: 18),
            const _PremiumDisclosureV110(
              title: 'Materials & finish',
              icon: Icons.layers_outlined,
              rows: <(String, String)>[
                ('Material', 'Plastic'),
                ('Base', 'Non-slip'),
                ('Expandable width', 'Up to 22.4 in'),
                ('Approved colors', 'White · Gray'),
              ],
            ),
            const SizedBox(height: 24),
            _RelatedCollectionV110(
              eyebrow: 'CONTINUE THE WALKA EDIT',
              title: 'Lunch, organized.',
              subtitle: '1200 ml · SUS304 tray · 4 compartments',
              visualKind: WalkaProductVisualKind.lunchBox,
              productColor: WalkaLunchVariant.blue.color,
              surface: WalkaLunchVariant.blue.surface,
              onTap: _openLunch,
            ),
          ],
        ),
      ),
    );
  }
}

/// DESIGN-004 premium Lunch Product Detail surface.
class WalkaLunchProductDetailV110 extends StatefulWidget {
  const WalkaLunchProductDetailV110({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  State<WalkaLunchProductDetailV110> createState() =>
      _WalkaLunchProductDetailV110State();
}

class _WalkaLunchProductDetailV110State
    extends State<WalkaLunchProductDetailV110> {
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
      const SnackBar(
        content: Text('Amazon could not be opened. Please try again.'),
      ),
    );
  }

  Future<void> _share() {
    return _showPremiumShareSheet(
      context,
      title: 'WALKA Large Bento Lunch Box · ${_variant.label}',
      uri: amazonLunchBoxUri(_amazonVariant),
    );
  }

  void _openGallery(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _PremiumFullscreenGalleryV110(
          initialIndex: index,
          title: '${_variant.label} Lunch Box',
          visualKind: WalkaProductVisualKind.lunchBox,
          primaryColor: _variant.color,
          backgroundColor: _variant.surface,
        ),
      ),
    );
  }

  void _openDrawer() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WalkaDrawerProductDetailV110(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return Scaffold(
      appBar: _premiumPdpAppBar(
        onShare: _share,
        onFavorite: () => setState(() => _favorite = !_favorite),
        isFavorite: _favorite,
      ),
      bottomNavigationBar: _ResponsiveAmazonPurchaseBarV110(
        selectedLabel: _variant.label.toUpperCase(),
        onPressed: _buy,
      ),
      body: SingleChildScrollView(
        key: const PageStorageKey<String>('design-004-lunch-pdp-scroll'),
        padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 44),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _PremiumProductGalleryV110(
              key: ValueKey<WalkaLunchVariant>(_variant),
              visualKind: WalkaProductVisualKind.lunchBox,
              primaryColor: _variant.color,
              backgroundColor: _variant.surface,
              semanticLabel: 'WALKA ${_variant.label} Lunch Box gallery',
              onExpand: _openGallery,
            ),
            const SizedBox(height: 18),
            _PremiumCommerceSummaryV110(
              eyebrow: 'LUNCH COLLECTION',
              title: 'Large Stainless Steel Bento Lunch Box',
              facts: '1200 ml · 4 compartments · SUS304 stainless steel tray',
              selectedLabel: '${_variant.label} · ${_variant.pantone}',
              variantPicker: _LunchVariantPickerV110(
                selected: _variant,
                onChanged: (WalkaLunchVariant variant) {
                  setState(() => _variant = variant);
                },
              ),
            ),
            const SizedBox(height: 16),
            const _ApprovedUsagePanelV110(),
            const SizedBox(height: 22),
            const _PremiumFactGridV110(
              facts: <(IconData, String, String)>[
                (Icons.local_drink_outlined, 'Capacity', '1200 ml'),
                (Icons.grid_view_rounded, 'Compartments', '4'),
                (Icons.kitchen_outlined, 'Food tray', 'SUS304 steel'),
                (Icons.shopping_bag_outlined, 'Included', 'Carry bag + set'),
              ],
            ),
            const SizedBox(height: 24),
            const _EditorialPdpPanelV110(
              eyebrow: 'A COMPLETE LUNCH SYSTEM',
              title: 'Built around the workday, not a lunch-hour compromise.',
              body:
                  'Stainless steel where food sits, a practical PP outer body and the included sauce cup, utensils and carry bag form one coordinated set.',
              icon: Icons.work_outline_rounded,
            ),
            const SizedBox(height: 18),
            const _PremiumDisclosureV110(
              title: 'What is included',
              icon: Icons.inventory_2_outlined,
              rows: <(String, String)>[
                ('Bento box', 'PP outer + SUS304 tray'),
                ('Sauce cup', 'Stainless cup with lid'),
                ('Utensils', 'Spoon + fork'),
                ('Carry', 'Carry bag'),
              ],
            ),
            const SizedBox(height: 10),
            const _PremiumDisclosureV110(
              title: 'Dimensions',
              icon: Icons.straighten_rounded,
              rows: <(String, String)>[
                ('Lunch box', '11.42 × 8.66 × 3.15 in'),
                ('With bag', '11.81 × 8.86 × 3.54 in'),
                ('Bag only', '10.63 × 7.48 × 2.76 in'),
                ('Weight with bag', '1.84 lb'),
              ],
            ),
            const SizedBox(height: 10),
            const _PremiumDisclosureV110(
              title: 'Care & use',
              icon: Icons.cleaning_services_outlined,
              rows: <(String, String)>[
                ('SUS304 tray', 'Dishwasher safe · not microwave safe'),
                ('Lid & gasket', 'Top-rack dishwasher · not microwave safe'),
                ('Microwave', 'PP outer only · remove tray, lid & gasket'),
                ('Carry', 'Keep upright'),
              ],
            ),
            const SizedBox(height: 24),
            _RelatedCollectionV110(
              eyebrow: 'CONTINUE THE WALKA EDIT',
              title: 'A calmer drawer.',
              subtitle: '8 compartments · expandable to 22.4 in',
              visualKind: WalkaProductVisualKind.drawerOrganizer,
              productColor: const Color(0xFFF7F4EC),
              surface: const Color(0xFFF3EEDF),
              onTap: _openDrawer,
            ),
          ],
        ),
      ),
    );
  }
}

PreferredSizeWidget _premiumPdpAppBar({
  required VoidCallback onShare,
  required VoidCallback onFavorite,
  required bool isFavorite,
}) {
  return AppBar(
    titleSpacing: 18,
    title: const WalkaWordmark(compact: true, showDescriptor: false),
    actions: <Widget>[
      IconButton(
        onPressed: onShare,
        tooltip: 'Share product',
        icon: const Icon(Icons.ios_share_rounded),
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
      const SizedBox(width: 6),
    ],
  );
}

class _PremiumProductGalleryV110 extends StatefulWidget {
  const _PremiumProductGalleryV110({
    required this.visualKind,
    required this.primaryColor,
    required this.backgroundColor,
    required this.semanticLabel,
    required this.onExpand,
    super.key,
  });

  final WalkaProductVisualKind visualKind;
  final Color primaryColor;
  final Color backgroundColor;
  final String semanticLabel;
  final ValueChanged<int> onExpand;

  @override
  State<_PremiumProductGalleryV110> createState() =>
      _PremiumProductGalleryV110State();
}

class _PremiumProductGalleryV110State
    extends State<_PremiumProductGalleryV110> {
  late final PageController _controller = PageController();
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
          aspectRatio: 1.04,
          child: Material(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(30),
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
                      child: _GallerySceneV110(
                        index: index,
                        visualKind: widget.visualKind,
                        primaryColor: widget.primaryColor,
                        backgroundColor: widget.backgroundColor,
                        semanticLabel: '${widget.semanticLabel} view ${index + 1}',
                      ),
                    );
                  },
                ),
                Positioned(
                  left: 14,
                  top: 14,
                  child: _GalleryLabelV110(index: _index),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.92),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () => widget.onExpand(_index),
                      tooltip: 'View fullscreen',
                      icon: const Icon(Icons.fullscreen_rounded),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.zoom_in_rounded,
                          size: 16,
                          color: WalkaColors.navy,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'TAP TO ZOOM',
                          style: TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (int item) {
            final bool selected = item == _index;
            return Semantics(
              button: true,
              selected: selected,
              label: 'Gallery view ${item + 1}',
              child: InkWell(
                onTap: () {
                  _controller.animateToPage(
                    item,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                  );
                },
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  width: 48,
                  height: 42,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: selected ? 28 : 9,
                      height: 9,
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

class _GallerySceneV110 extends StatelessWidget {
  const _GallerySceneV110({
    required this.index,
    required this.visualKind,
    required this.primaryColor,
    required this.backgroundColor,
    required this.semanticLabel,
  });

  final int index;
  final WalkaProductVisualKind visualKind;
  final Color primaryColor;
  final Color backgroundColor;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Widget visual = Padding(
      padding: EdgeInsets.all(index == 0 ? 26 : 34),
      child: WalkaProductVisual(
        kind: visualKind,
        primaryColor: primaryColor,
        backgroundColor: backgroundColor,
        semanticLabel: semanticLabel,
      ),
    );

    return switch (index) {
      0 => Center(child: visual),
      1 => Transform.rotate(angle: -0.035, child: Center(child: visual)),
      _ => Transform.scale(scale: 0.90, child: Center(child: visual)),
    };
  }
}

class _GalleryLabelV110 extends StatelessWidget {
  const _GalleryLabelV110({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    const List<String> labels = <String>['HERO', 'FORM', 'DETAIL'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        '${labels[index]} · ${index + 1}/3',
        style: const TextStyle(
          color: WalkaColors.navy,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _PremiumCommerceSummaryV110 extends StatelessWidget {
  const _PremiumCommerceSummaryV110({
    required this.eyebrow,
    required this.title,
    required this.facts,
    required this.selectedLabel,
    required this.variantPicker,
  });

  final String eyebrow;
  final String title;
  final String facts;
  final String selectedLabel;
  final Widget variantPicker;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('premium-pdp-commerce-summary'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: WalkaColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: WalkaColors.line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: WalkaColors.navyDark.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(eyebrow, style: WalkaType.eyebrow),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'serif',
              color: WalkaColors.navy,
              fontSize: 30,
              height: 1.06,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(facts, style: WalkaType.body),
          const SizedBox(height: 18),
          Container(height: 1, color: WalkaColors.line),
          const SizedBox(height: 16),
          const Text(
            'SELECT YOUR VARIANT',
            style: TextStyle(
              color: WalkaColors.muted,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            selectedLabel,
            key: const ValueKey<String>('premium-pdp-selected-variant'),
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          variantPicker,
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2E9CF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: <Widget>[
                Icon(Icons.verified_outlined, size: 17, color: WalkaColors.navy),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Official WALKA product · purchase opens on Amazon',
                    style: TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 10,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerVariantPickerV110 extends StatelessWidget {
  const _DrawerVariantPickerV110({required this.gray, required this.onChanged});

  final bool gray;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: <Widget>[
        _FinishChoiceV110(
          key: const ValueKey<String>('premium-drawer-white'),
          label: 'White',
          color: const Color(0xFFF7F4EC),
          selected: !gray,
          onTap: () => onChanged(false),
        ),
        _FinishChoiceV110(
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

class _LunchVariantPickerV110 extends StatelessWidget {
  const _LunchVariantPickerV110({
    required this.selected,
    required this.onChanged,
  });

  final WalkaLunchVariant selected;
  final ValueChanged<WalkaLunchVariant> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: WalkaLunchVariant.values.map((WalkaLunchVariant variant) {
        return _FinishChoiceV110(
          key: ValueKey<String>('premium-lunch-${variant.name}'),
          label: variant.label,
          color: variant.color,
          selected: selected == variant,
          onTap: () => onChanged(variant),
        );
      }).toList(growable: false),
    );
  }
}

class _FinishChoiceV110 extends StatelessWidget {
  const _FinishChoiceV110({
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
    return Semantics(
      button: true,
      selected: selected,
      label: '$label variant',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? WalkaColors.navy : WalkaColors.white,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
              color: selected ? WalkaColors.navy : WalkaColors.line,
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
                  border: Border.all(color: const Color(0x22000000)),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : WalkaColors.navy,
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

class _ApprovedUsagePanelV110 extends StatelessWidget {
  const _ApprovedUsagePanelV110();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('premium-lunch-approved-usage'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2E9CF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.20)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('SPILL-RESISTANT DESIGN', style: WalkaType.eyebrow),
          SizedBox(height: 8),
          Text(
            'Secure Lock | Helps Prevent Spills',
            style: TextStyle(
              color: WalkaColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text('Best suited for dry meals & snacks.', style: WalkaType.body),
          SizedBox(height: 4),
          Text(
            'Not intended for liquids. Best for dry & semi-wet foods.',
            style: WalkaType.body,
          ),
          SizedBox(height: 4),
          Text('Carry upright.', style: WalkaType.body),
        ],
      ),
    );
  }
}

class _PremiumFactGridV110 extends StatelessWidget {
  const _PremiumFactGridV110({required this.facts});

  final List<(IconData, String, String)> facts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool singleColumn = constraints.maxWidth < 340 ||
            MediaQuery.textScalerOf(context).scale(1) > 1.2;
        final double width = singleColumn
            ? constraints.maxWidth
            : (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: facts.map((fact) {
            return SizedBox(
              width: width,
              child: _FactCardV110(
                icon: fact.$1,
                label: fact.$2,
                value: fact.$3,
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}

class _FactCardV110 extends StatelessWidget {
  const _FactCardV110({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: WalkaColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: WalkaColors.gold),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialPdpPanelV110 extends StatelessWidget {
  const _EditorialPdpPanelV110({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: WalkaColors.gold, size: 20),
              const SizedBox(width: 9),
              Expanded(child: Text(eyebrow, style: WalkaType.eyebrow)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: 25,
              height: 1.08,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            style: const TextStyle(
              color: Color(0xFFD4DEE8),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumDisclosureV110 extends StatelessWidget {
  const _PremiumDisclosureV110({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: WalkaColors.line),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          leading: Icon(icon, color: WalkaColors.gold, size: 21),
          title: Text(
            title,
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          children: rows.map((row) {
            return _SpecRowV110(label: row.$1, value: row.$2);
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class _SpecRowV110 extends StatelessWidget {
  const _SpecRowV110({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                color: WalkaColors.muted,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: WalkaColors.navy,
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedCollectionV110 extends StatelessWidget {
  const _RelatedCollectionV110({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.visualKind,
    required this.productColor,
    required this.surface,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final WalkaProductVisualKind visualKind;
  final Color productColor;
  final Color surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          padding: const EdgeInsets.fromLTRB(18, 16, 8, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 6,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(eyebrow, style: WalkaType.eyebrow),
                    const SizedBox(height: 7),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: WalkaColors.navy,
                        fontSize: 22,
                        height: 1.08,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                        height: 1.35,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 118,
                  child: WalkaProductVisual(
                    kind: visualKind,
                    primaryColor: productColor,
                    backgroundColor: surface,
                    compact: true,
                    semanticLabel: title,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveAmazonPurchaseBarV110 extends StatelessWidget {
  const _ResponsiveAmazonPurchaseBarV110({
    required this.selectedLabel,
    required this.onPressed,
  });

  final String selectedLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final double textScale = MediaQuery.textScalerOf(context).scale(1);
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 7, 12, 9),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            key: const ValueKey<String>('premium-pdp-purchase-bar'),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: WalkaColors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: WalkaColors.line),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: WalkaColors.navyDark.withValues(alpha: 0.10),
                  blurRadius: 22,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool stacked = constraints.maxWidth < 330 || textScale > 1.15;
                final Widget selected = _PurchaseSelectionV110(
                  selectedLabel: selectedLabel,
                );
                final Widget action = ElevatedButton.icon(
                  key: const ValueKey<String>('premium-pdp-amazon-cta'),
                  onPressed: onPressed,
                  icon: const Icon(Icons.north_east_rounded, size: 17),
                  label: const Text('BUY ON AMAZON'),
                );

                if (stacked) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 2, 4, 8),
                        child: selected,
                      ),
                      action,
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(flex: 3, child: selected),
                    const SizedBox(width: 10),
                    Expanded(flex: 5, child: action),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PurchaseSelectionV110 extends StatelessWidget {
  const _PurchaseSelectionV110({required this.selectedLabel});

  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'SELECTED',
          style: TextStyle(
            color: WalkaColors.muted,
            fontSize: 8,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          selectedLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
      ],
    );
  }
}

class _PremiumFullscreenGalleryV110 extends StatefulWidget {
  const _PremiumFullscreenGalleryV110({
    required this.initialIndex,
    required this.title,
    required this.visualKind,
    required this.primaryColor,
    required this.backgroundColor,
  });

  final int initialIndex;
  final String title;
  final WalkaProductVisualKind visualKind;
  final Color primaryColor;
  final Color backgroundColor;

  @override
  State<_PremiumFullscreenGalleryV110> createState() =>
      _PremiumFullscreenGalleryV110State();
}

class _PremiumFullscreenGalleryV110State
    extends State<_PremiumFullscreenGalleryV110> {
  late int _index = widget.initialIndex;
  late final PageController _controller = PageController(initialPage: _index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06192A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
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
                      child: Container(
                        margin: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: widget.backgroundColor,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: _GallerySceneV110(
                          index: index,
                          visualKind: widget.visualKind,
                          primaryColor: widget.primaryColor,
                          backgroundColor: widget.backgroundColor,
                          semanticLabel:
                              '${widget.title} fullscreen view ${index + 1}',
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      <String>['HERO VIEW', 'FORM VIEW', 'DETAIL VIEW'][_index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Text(
                    '${_index + 1} / 3',
                    style: const TextStyle(
                      color: WalkaColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPremiumShareSheet(
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
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('SHARE WALKA', style: WalkaType.eyebrow),
              const SizedBox(height: 8),
              Text(title, style: WalkaType.sectionTitle),
              const SizedBox(height: 9),
              const Text(
                'Copy the official Amazon product link and share it anywhere.',
                style: WalkaType.body,
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: uri.toString()));
                  if (!sheetContext.mounted) return;
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Product link copied.')),
                  );
                },
                icon: const Icon(Icons.link_rounded),
                label: const Text('COPY PRODUCT LINK'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
