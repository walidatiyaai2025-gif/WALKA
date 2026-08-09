import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/walka_theme.dart';
import '../commerce/amazon_purchase.dart';
import '../favorites/favorites_state.dart';
import '../lunch/lunch_box_v6.dart';

enum _ProductFamily { drawer, lunch }

class WalkaDrawerProductDetailV10 extends StatefulWidget {
  const WalkaDrawerProductDetailV10({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  State<WalkaDrawerProductDetailV10> createState() =>
      _WalkaDrawerProductDetailV10State();
}

class _WalkaDrawerProductDetailV10State
    extends State<WalkaDrawerProductDetailV10> {
  late bool _gray = widget.initialGray;
  int _galleryIndex = 0;

  Future<void> _toggleFavorite(WalkaFavoritesController controller) async {
    final bool saved = await controller.toggleDrawer(gray: _gray);
    if (!mounted || saved) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite could not be updated.')),
    );
  }

  Future<void> _buy() async {
    final bool launched = await openDrawerOrganizerOnAmazon(gray: _gray);
    if (!mounted || launched) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Amazon could not be opened. Please try again.'),
      ),
    );
  }

  void _openGallery(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullscreenGalleryV10(
          family: _ProductFamily.drawer,
          initialIndex: index,
          gray: _gray,
        ),
      ),
    );
  }

  Future<void> _share() {
    final Uri uri = amazonDrawerOrganizerUri(gray: _gray);
    return _showShareSheet(
      context,
      title: 'WALKA Drawer Organizer · ${_gray ? 'Gray' : 'White'}',
      uri: uri,
    );
  }

  void _openLunch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WalkaLunchProductDetailV10(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WalkaFavoritesController favorites = WalkaFavoritesScope.of(context);
    final bool isFavorite = favorites.isDrawerFavorite(gray: _gray);
    final Color tone = _gray
        ? const Color(0xFFE0E2E5)
        : const Color(0xFFF7F4ED);

    return Scaffold(
      appBar: AppBar(
        title: const _WordmarkV10(),
        actions: <Widget>[
          IconButton(
            onPressed: _share,
            tooltip: 'Share product',
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            onPressed: () => _toggleFavorite(favorites),
            tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                key: ValueKey<bool>(isFavorite),
                color: isFavorite ? WalkaColors.gold : WalkaColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: _StickyPurchaseBar(
        variant: _gray ? 'GRAY' : 'WHITE',
        onPressed: _buy,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: _GalleryCardV10(
                family: _ProductFamily.drawer,
                index: _galleryIndex,
                tone: tone,
                gray: _gray,
                onChanged: (int index) => setState(() => _galleryIndex = index),
                onExpand: () => _openGallery(_galleryIndex),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 38),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('DRAWER ORGANIZATION', style: WalkaType.eyebrow),
                  const SizedBox(height: 9),
                  const Text(
                    'WALKA Drawer Organizer',
                    style: _ProductTypeV10.title,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '8 compartments · Expandable 13″–22.4″ · Non-slip base',
                    style: WalkaType.body,
                  ),
                  const SizedBox(height: 24),
                  _DrawerVariantPickerV10(
                    gray: _gray,
                    onChanged: (bool gray) {
                      setState(() {
                        _gray = gray;
                        _galleryIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(height: 28),
                  const _BenefitStripV10(
                    items: <(IconData, String)>[
                      (Icons.grid_view_rounded, '8 compartments'),
                      (Icons.open_in_full_rounded, '13″–22.4″'),
                      (Icons.layers_outlined, 'Large capacity'),
                      (Icons.pan_tool_alt_outlined, 'Non-slip base'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const _EditorialSectionV10(
                    eyebrow: 'MADE FOR DAILY ORDER',
                    title: 'More capacity. Less visual clutter.',
                    body:
                        'A considered expandable layout creates a clear home for cutlery, utensils and everyday drawer essentials while keeping everything easy to reach.',
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _DrawerLifestylePanelV10(
                      key: ValueKey<bool>(_gray),
                      gray: _gray,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const _ProductDisclosureV10(
                    title: 'Dimensions & capacity',
                    icon: Icons.straighten_rounded,
                    children: <Widget>[
                      _SpecRowV10(label: 'Closed size', value: '13 × 15 × 2 in'),
                      _SpecRowV10(label: 'Expandable width', value: 'Up to 22.4 in'),
                      _SpecRowV10(label: 'Compartments', value: '8'),
                      _SpecRowV10(label: 'Colors', value: 'White · Gray'),
                    ],
                  ),
                  const _ProductDisclosureV10(
                    title: 'Materials & care',
                    icon: Icons.auto_awesome_outlined,
                    children: <Widget>[
                      _SpecRowV10(label: 'Material', value: 'Durable plastic'),
                      _SpecRowV10(label: 'Base', value: 'Non-slip'),
                      _SpecRowV10(label: 'Care', value: 'Wipe clean'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _RelatedProductV10(
                    family: _ProductFamily.lunch,
                    eyebrow: 'CONTINUE THE WALKA EDIT',
                    title: 'Lunch, organized.',
                    subtitle: '1200 ml · SUS304 · 4 compartments',
                    onTap: _openLunch,
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

class WalkaLunchProductDetailV10 extends StatefulWidget {
  const WalkaLunchProductDetailV10({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  State<WalkaLunchProductDetailV10> createState() =>
      _WalkaLunchProductDetailV10State();
}

class _WalkaLunchProductDetailV10State
    extends State<WalkaLunchProductDetailV10> {
  late WalkaLunchVariant _variant = widget.initialVariant;
  int _galleryIndex = 0;
  bool _favorite = false;

  WalkaAmazonLunchVariant get _amazonVariant => switch (_variant) {
        WalkaLunchVariant.blue => WalkaAmazonLunchVariant.blue,
        WalkaLunchVariant.pink => WalkaAmazonLunchVariant.pink,
        WalkaLunchVariant.green => WalkaAmazonLunchVariant.green,
      };

  Future<void> _buy() async {
    final bool launched = await openLunchBoxOnAmazon(_amazonVariant);
    if (!mounted || launched) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Amazon could not be opened. Please try again.'),
      ),
    );
  }

  Future<void> _share() {
    return _showShareSheet(
      context,
      title: 'WALKA Large Bento Lunch Box · ${_variant.label}',
      uri: amazonLunchBoxUri(_amazonVariant),
    );
  }

  void _openGallery(int index) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullscreenGalleryV10(
          family: _ProductFamily.lunch,
          initialIndex: index,
          lunchVariant: _variant,
        ),
      ),
    );
  }

  void _openDrawer() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WalkaDrawerProductDetailV10(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _WordmarkV10(),
        actions: <Widget>[
          IconButton(
            onPressed: _share,
            tooltip: 'Share product',
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            onPressed: () => setState(() => _favorite = !_favorite),
            tooltip: _favorite ? 'Remove favorite' : 'Add favorite',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                key: ValueKey<bool>(_favorite),
                color: _favorite ? WalkaColors.gold : WalkaColors.navy,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: _StickyPurchaseBar(
        variant: _variant.label.toUpperCase(),
        onPressed: _buy,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: _GalleryCardV10(
                  key: ValueKey<WalkaLunchVariant>(_variant),
                  family: _ProductFamily.lunch,
                  index: _galleryIndex,
                  tone: _variant.surface,
                  lunchVariant: _variant,
                  onChanged: (int index) => setState(() => _galleryIndex = index),
                  onExpand: () => _openGallery(_galleryIndex),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 38),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('LUNCH COLLECTION', style: WalkaType.eyebrow),
                  const SizedBox(height: 9),
                  const Text(
                    'Large Stainless Steel Bento Lunch Box',
                    style: _ProductTypeV10.title,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '1200 ml · 4 compartments · insulated bag, utensils & sauce cup included',
                    style: WalkaType.body,
                  ),
                  const SizedBox(height: 24),
                  _LunchVariantPickerV10(
                    selected: _variant,
                    onSelected: (WalkaLunchVariant variant) {
                      setState(() {
                        _variant = variant;
                        _galleryIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const _UsageNoteV10(),
                  const SizedBox(height: 28),
                  const _BenefitStripV10(
                    items: <(IconData, String)>[
                      (Icons.grid_view_rounded, '4 compartments'),
                      (Icons.local_drink_outlined, '1200 ml'),
                      (Icons.kitchen_outlined, 'SUS304 tray'),
                      (Icons.shopping_bag_outlined, 'Insulated bag'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const _EditorialSectionV10(
                    eyebrow: 'BUILT FOR ADULT ROUTINES',
                    title: 'A complete lunch system, refined.',
                    body:
                        'Stainless steel where food sits, practical accessories for the day, and a calm palette designed to move from kitchen to workday.',
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: _LunchLifestylePanelV10(
                      key: ValueKey<WalkaLunchVariant>(_variant),
                      variant: _variant,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const _ProductDisclosureV10(
                    title: 'What is included',
                    icon: Icons.inventory_2_outlined,
                    children: <Widget>[
                      _SpecRowV10(label: 'Bento box', value: 'PP outer + SUS304 tray'),
                      _SpecRowV10(label: 'Sauce cup', value: 'Round stainless cup + lid'),
                      _SpecRowV10(label: 'Utensils', value: 'Spoon + fork'),
                      _SpecRowV10(label: 'Carry', value: 'Insulated bag'),
                    ],
                  ),
                  const _ProductDisclosureV10(
                    title: 'Dimensions & materials',
                    icon: Icons.straighten_rounded,
                    children: <Widget>[
                      _SpecRowV10(label: 'Capacity', value: '1200 ml'),
                      _SpecRowV10(label: 'Lunch box', value: '11.42 × 8.66 × 3.15 in'),
                      _SpecRowV10(label: 'With bag', value: '11.81 × 8.86 × 3.54 in'),
                      _SpecRowV10(label: 'Weight with bag', value: '1.84 lb'),
                    ],
                  ),
                  const _ProductDisclosureV10(
                    title: 'Care & use',
                    icon: Icons.cleaning_services_outlined,
                    children: <Widget>[
                      _SpecRowV10(label: 'Steel tray', value: 'Dishwasher · top rack'),
                      _SpecRowV10(label: 'Lid & gasket', value: 'Dishwasher · top rack'),
                      _SpecRowV10(label: 'Microwave', value: 'PP outer only · remove steel tray & lid'),
                      _SpecRowV10(label: 'Carry', value: 'Keep upright'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  _RelatedProductV10(
                    family: _ProductFamily.drawer,
                    eyebrow: 'CONTINUE THE WALKA EDIT',
                    title: 'A calmer drawer.',
                    subtitle: '8 compartments · expandable to 22.4″',
                    onTap: _openDrawer,
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

Future<void> _showShareSheet(
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
                  if (!sheetContext.mounted) {
                    return;
                  }
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

class _StickyPurchaseBar extends StatelessWidget {
  const _StickyPurchaseBar({required this.variant, required this.onPressed});

  final String variant;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: WalkaColors.line),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 18,
              offset: Offset(0, -4),
            ),
          ],
        ),
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
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    variant,
                    style: const TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 210,
              child: ElevatedButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.north_east_rounded, size: 17),
                label: const Text('BUY ON AMAZON'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryCardV10 extends StatelessWidget {
  const _GalleryCardV10({
    super.key,
    required this.family,
    required this.index,
    required this.tone,
    required this.onChanged,
    required this.onExpand,
    this.gray = false,
    this.lunchVariant = WalkaLunchVariant.blue,
  });

  final _ProductFamily family;
  final int index;
  final Color tone;
  final ValueChanged<int> onChanged;
  final VoidCallback onExpand;
  final bool gray;
  final WalkaLunchVariant lunchVariant;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.03,
          child: Material(
            color: tone,
            borderRadius: BorderRadius.circular(28),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onExpand,
              child: Stack(
                children: <Widget>[
                  Center(
                    child: Hero(
                      tag: _heroTag,
                      child: _ProductRenderV10(
                        family: family,
                        scene: index,
                        gray: gray,
                        lunchVariant: lunchVariant,
                        size: 285,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    top: 16,
                    child: _GalleryBadgeV10(index: index),
                  ),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.88),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: onExpand,
                        tooltip: 'View fullscreen',
                        icon: const Icon(Icons.fullscreen_rounded),
                      ),
                    ),
                  ),
                  const Positioned(
                    right: 17,
                    bottom: 15,
                    child: Row(
                      children: <Widget>[
                        Icon(Icons.zoom_in_rounded, size: 16, color: WalkaColors.navy),
                        SizedBox(width: 5),
                        Text(
                          'TAP TO EXPAND',
                          style: TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
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
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (int item) {
            final bool selected = item == index;
            return Semantics(
              button: true,
              selected: selected,
              label: 'Gallery view ${item + 1}',
              child: InkWell(
                onTap: () => onChanged(item),
                borderRadius: BorderRadius.circular(99),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 30 : 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: selected ? WalkaColors.navy : WalkaColors.line,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String get _heroTag => family == _ProductFamily.drawer
      ? 'drawer-${gray ? 'gray' : 'white'}-$index'
      : 'lunch-${lunchVariant.label}-$index';
}

class _FullscreenGalleryV10 extends StatefulWidget {
  const _FullscreenGalleryV10({
    required this.family,
    required this.initialIndex,
    this.gray = false,
    this.lunchVariant = WalkaLunchVariant.blue,
  });

  final _ProductFamily family;
  final int initialIndex;
  final bool gray;
  final WalkaLunchVariant lunchVariant;

  @override
  State<_FullscreenGalleryV10> createState() => _FullscreenGalleryV10State();
}

class _FullscreenGalleryV10State extends State<_FullscreenGalleryV10> {
  late int _index = widget.initialIndex;
  late final PageController _controller = PageController(initialPage: _index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.family == _ProductFamily.drawer
        ? 'Drawer Organizer'
        : '${widget.lunchVariant.label} Lunch Box';
    return Scaffold(
      backgroundColor: const Color(0xFF071829),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(
          title,
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
                onPageChanged: (int index) => setState(() => _index = index),
                itemBuilder: (BuildContext context, int index) {
                  return InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 2.8,
                    child: Center(
                      child: Hero(
                        tag: widget.family == _ProductFamily.drawer
                            ? 'drawer-${widget.gray ? 'gray' : 'white'}-$index'
                            : 'lunch-${widget.lunchVariant.label}-$index',
                        child: _ProductRenderV10(
                          family: widget.family,
                          scene: index,
                          gray: widget.gray,
                          lunchVariant: widget.lunchVariant,
                          size: 330,
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
                      <String>['HERO VIEW', 'OPEN / EXPANDED', 'DETAIL VIEW'][_index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  Text(
                    '${_index + 1} / 3',
                    style: const TextStyle(
                      color: WalkaColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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

class _GalleryBadgeV10 extends StatelessWidget {
  const _GalleryBadgeV10({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        <String>['HERO VIEW', 'OPEN / EXPANDED', 'DETAIL'][index],
        style: const TextStyle(
          color: WalkaColors.navy,
          fontSize: 8,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ProductRenderV10 extends StatelessWidget {
  const _ProductRenderV10({
    required this.family,
    required this.scene,
    required this.gray,
    required this.lunchVariant,
    required this.size,
  });

  final _ProductFamily family;
  final int scene;
  final bool gray;
  final WalkaLunchVariant lunchVariant;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (family == _ProductFamily.drawer) {
      return _DrawerRenderV10(size: size, gray: gray, scene: scene);
    }
    return _LunchRenderV10(size: size, variant: lunchVariant, scene: scene);
  }
}

class _DrawerRenderV10 extends StatelessWidget {
  const _DrawerRenderV10({
    required this.size,
    required this.gray,
    required this.scene,
  });

  final double size;
  final bool gray;
  final int scene;

  @override
  Widget build(BuildContext context) {
    final double width = scene == 1 ? size : size * 0.88;
    final Color frame = gray ? const Color(0xFF989EA4) : const Color(0xFFF9F8F4);
    final Color cell = gray ? const Color(0xFFB4B9BE) : const Color(0xFFE9EAE6);
    return Transform.rotate(
      angle: scene == 2 ? -0.08 : -0.03,
      child: Container(
        width: width,
        height: width * 0.64,
        padding: EdgeInsets.all(width * 0.04),
        decoration: BoxDecoration(
          color: frame,
          borderRadius: BorderRadius.circular(width * 0.06),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x32000000), blurRadius: 24, offset: Offset(0, 12)),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: _RenderCellV10(color: cell)),
                  SizedBox(height: width * 0.025),
                  Expanded(child: _RenderCellV10(color: cell)),
                ],
              ),
            ),
            SizedBox(width: width * 0.025),
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Expanded(child: _RenderCellV10(color: cell)),
                  SizedBox(height: width * 0.025),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(child: _RenderCellV10(color: cell)),
                        SizedBox(width: width * 0.025),
                        Expanded(child: _RenderCellV10(color: cell)),
                      ],
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

class _LunchRenderV10 extends StatelessWidget {
  const _LunchRenderV10({
    required this.size,
    required this.variant,
    required this.scene,
  });

  final double size;
  final WalkaLunchVariant variant;
  final int scene;

  @override
  Widget build(BuildContext context) {
    if (scene == 1) {
      return SizedBox(
        width: size,
        height: size * 0.72,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Transform.rotate(
                angle: -0.06,
                child: _LunchLidV10(width: size * 0.72, variant: variant),
              ),
            ),
            _LunchOpenTrayV10(width: size * 0.9, variant: variant),
          ],
        ),
      );
    }
    if (scene == 2) {
      return SizedBox(
        width: size,
        height: size * 0.7,
        child: Stack(
          children: <Widget>[
            Positioned(
              right: 4,
              bottom: 0,
              child: Container(
                width: size * 0.62,
                height: size * 0.42,
                decoration: BoxDecoration(
                  color: WalkaColors.navyDark,
                  borderRadius: BorderRadius.circular(size * 0.06),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(color: Color(0x32000000), blurRadius: 20, offset: Offset(0, 10)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  'WALKA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size * 0.055,
                    fontWeight: FontWeight.w900,
                    letterSpacing: size * 0.015,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 12,
              child: _LunchClosedV10(width: size * 0.65, variant: variant),
            ),
          ],
        ),
      );
    }
    return _LunchClosedV10(width: size * 0.88, variant: variant);
  }
}

class _LunchClosedV10 extends StatelessWidget {
  const _LunchClosedV10({required this.width, required this.variant});
  final double width;
  final WalkaLunchVariant variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.55,
      decoration: BoxDecoration(
        color: variant.color,
        borderRadius: BorderRadius.circular(width * 0.075),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x32000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        'WALKA',
        style: TextStyle(
          color: WalkaColors.navy.withValues(alpha: 0.62),
          fontSize: width * 0.06,
          fontWeight: FontWeight.w900,
          letterSpacing: width * 0.013,
        ),
      ),
    );
  }
}

class _LunchLidV10 extends StatelessWidget {
  const _LunchLidV10({required this.width, required this.variant});
  final double width;
  final WalkaLunchVariant variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.32,
      decoration: BoxDecoration(
        color: variant.color,
        borderRadius: BorderRadius.circular(width * 0.06),
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _LunchOpenTrayV10 extends StatelessWidget {
  const _LunchOpenTrayV10({required this.width, required this.variant});
  final double width;
  final WalkaLunchVariant variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 0.48,
      padding: EdgeInsets.all(width * 0.035),
      decoration: BoxDecoration(
        color: variant.color,
        borderRadius: BorderRadius.circular(width * 0.07),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Color(0x32000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Column(
              children: <Widget>[
                Expanded(child: _SteelCellV10()),
                SizedBox(height: width * 0.018),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Expanded(child: _SteelCellV10()),
                      SizedBox(width: width * 0.018),
                      Expanded(child: _SteelCellV10()),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: width * 0.018),
          Expanded(
            flex: 3,
            child: Column(
              children: <Widget>[
                Expanded(child: _SteelCellV10()),
                SizedBox(height: width * 0.018),
                Container(
                  width: width * 0.13,
                  height: width * 0.13,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD5DADD),
                    shape: BoxShape.circle,
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

class _SteelCellV10 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFFF8F9F9), Color(0xFFD4D9DC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}

class _RenderCellV10 extends StatelessWidget {
  const _RenderCellV10({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _DrawerVariantPickerV10 extends StatelessWidget {
  const _DrawerVariantPickerV10({required this.gray, required this.onChanged});
  final bool gray;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text('COLOR', style: _ProductTypeV10.label),
            const Spacer(),
            Text(gray ? 'Gray' : 'White', style: _ProductTypeV10.value),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _VariantChoiceV10(
                selected: !gray,
                label: 'White',
                swatch: Colors.white,
                onTap: () => onChanged(false),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _VariantChoiceV10(
                selected: gray,
                label: 'Gray',
                swatch: const Color(0xFF969CA2),
                onTap: () => onChanged(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LunchVariantPickerV10 extends StatelessWidget {
  const _LunchVariantPickerV10({required this.selected, required this.onSelected});
  final WalkaLunchVariant selected;
  final ValueChanged<WalkaLunchVariant> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            const Text('COLOR', style: _ProductTypeV10.label),
            const Spacer(),
            Text('${selected.label} · ${selected.pantone}', style: _ProductTypeV10.value),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: WalkaLunchVariant.values.map((variant) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: variant == WalkaLunchVariant.green ? 0 : 8,
                ),
                child: _VariantChoiceV10(
                  selected: selected == variant,
                  label: variant.label,
                  swatch: variant.color,
                  onTap: () => onSelected(variant),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _VariantChoiceV10 extends StatelessWidget {
  const _VariantChoiceV10({
    required this.selected,
    required this.label,
    required this.swatch,
    required this.onTap,
  });
  final bool selected;
  final String label;
  final Color swatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label variant',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: selected ? WalkaColors.navy : Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selected ? WalkaColors.navy : WalkaColors.line,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: swatch,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : WalkaColors.navy,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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

class _BenefitStripV10 extends StatelessWidget {
  const _BenefitStripV10({required this.items});
  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 102,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (BuildContext context, int index) {
          final (IconData icon, String label) = items[index];
          return Container(
            width: 122,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: WalkaColors.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, color: WalkaColors.gold, size: 21),
                const Spacer(),
                Text(
                  label,
                  maxLines: 2,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 10,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _UsageNoteV10 extends StatelessWidget {
  const _UsageNoteV10();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.4)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.shield_outlined, color: WalkaColors.gold),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'SECURE LOCK · HELPS PREVENT SPILLS',
                  style: TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Best for dry & semi-wet foods. Not intended for liquids. Carry upright.',
                  style: TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
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

class _EditorialSectionV10 extends StatelessWidget {
  const _EditorialSectionV10({
    required this.eyebrow,
    required this.title,
    required this.body,
  });
  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(eyebrow, style: WalkaType.eyebrow),
        const SizedBox(height: 8),
        Text(title, style: WalkaType.sectionTitle),
        const SizedBox(height: 10),
        Text(body, style: WalkaType.body),
      ],
    );
  }
}

class _DrawerLifestylePanelV10 extends StatelessWidget {
  const _DrawerLifestylePanelV10({super.key, required this.gray});
  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: gray ? const Color(0xFFDBDEE1) : const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -20,
            bottom: -8,
            child: _DrawerRenderV10(size: 230, gray: gray, scene: 1),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: 150,
              child: Text(
                'Expandable order for the drawer you use every day.',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: WalkaColors.navy,
                  fontSize: 22,
                  height: 1.08,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LunchLifestylePanelV10 extends StatelessWidget {
  const _LunchLifestylePanelV10({super.key, required this.variant});
  final WalkaLunchVariant variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: variant.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            right: -8,
            bottom: -4,
            child: _LunchRenderV10(size: 230, variant: variant, scene: 2),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: SizedBox(
              width: 155,
              child: Text(
                'One coordinated set from meal prep to the workday.',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: WalkaColors.navy,
                  fontSize: 22,
                  height: 1.08,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductDisclosureV10 extends StatelessWidget {
  const _ProductDisclosureV10({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(icon, color: WalkaColors.gold),
        title: Text(
          title,
          style: const TextStyle(
            color: WalkaColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: children,
      ),
    );
  }
}

class _SpecRowV10 extends StatelessWidget {
  const _SpecRowV10({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: WalkaColors.muted, fontSize: 11),
            ),
          ),
          const SizedBox(width: 18),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: WalkaColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedProductV10 extends StatelessWidget {
  const _RelatedProductV10({
    required this.family,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final _ProductFamily family;
  final String eyebrow;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.navy,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 220,
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -12,
                bottom: -4,
                child: family == _ProductFamily.drawer
                    ? const _DrawerRenderV10(size: 170, gray: false, scene: 0)
                    : const _LunchRenderV10(
                        size: 175,
                        variant: WalkaLunchVariant.blue,
                        scene: 0,
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(eyebrow, style: WalkaType.eyebrow),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 180,
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          color: Colors.white,
                          fontSize: 25,
                          height: 1.06,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: 190,
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFFC8D4DF),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Row(
                      children: <Widget>[
                        Text(
                          'VIEW PRODUCT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, color: WalkaColors.gold, size: 17),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WordmarkV10 extends StatelessWidget {
  const _WordmarkV10();
  @override
  Widget build(BuildContext context) {
    return const Text(
      'WALKA',
      style: TextStyle(
        color: WalkaColors.navy,
        fontSize: 16,
        fontWeight: FontWeight.w900,
        letterSpacing: 3.3,
      ),
    );
  }
}

abstract final class _ProductTypeV10 {
  static const TextStyle title = TextStyle(
    fontFamily: 'serif',
    color: WalkaColors.navy,
    fontSize: 31,
    height: 1.07,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.35,
  );
  static const TextStyle label = TextStyle(
    color: WalkaColors.navy,
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.1,
  );
  static const TextStyle value = TextStyle(
    color: WalkaColors.muted,
    fontSize: 10,
    fontWeight: FontWeight.w700,
  );
}
