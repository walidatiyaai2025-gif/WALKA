import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system/walka_theme.dart';
import '../commerce/amazon_purchase.dart';
import '../favorites/favorites_state.dart';
import '../lunch/lunch_box_v6.dart';

class WalkaDrawerProductDetailV100 extends StatefulWidget {
  const WalkaDrawerProductDetailV100({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  State<WalkaDrawerProductDetailV100> createState() =>
      _WalkaDrawerProductDetailV100State();
}

class _WalkaDrawerProductDetailV100State
    extends State<WalkaDrawerProductDetailV100> {
  late bool _gray = widget.initialGray;
  int _galleryIndex = 0;

  Future<void> _buy() async {
    final bool opened = await openDrawerOrganizerOnAmazon(gray: _gray);
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Amazon could not be opened. Please try again.')),
    );
  }

  Future<void> _share() async {
    await Clipboard.setData(
      ClipboardData(text: amazonDrawerOrganizerUri(gray: _gray).toString()),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product link copied.')),
    );
  }

  Future<void> _toggleFavorite() async {
    final WalkaFavoritesController controller = WalkaFavoritesScope.of(context);
    final bool saved = await controller.toggleDrawer(gray: _gray);
    if (!mounted || saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite could not be updated.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WalkaFavoritesController favorites = WalkaFavoritesScope.of(context);
    final bool isFavorite = favorites.isDrawerFavorite(gray: _gray);
    final Color tone = _gray ? const Color(0xFFE1E4E7) : const Color(0xFFF7F3EA);

    return Scaffold(
      appBar: AppBar(
        title: const _Wordmark(),
        actions: <Widget>[
          IconButton(
            onPressed: _share,
            tooltip: 'Share product',
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            onPressed: _toggleFavorite,
            tooltip: isFavorite ? 'Remove favorite' : 'Add favorite',
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? WalkaColors.gold : WalkaColors.navy,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: _PurchaseBar(
        variant: _gray ? 'GRAY' : 'WHITE',
        onBuy: _buy,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: _GalleryCard(
                index: _galleryIndex,
                tone: tone,
                onChanged: (int index) => setState(() => _galleryIndex = index),
                onExpand: () => _openGallery(
                  context,
                  title: 'Drawer Organizer',
                  initialIndex: _galleryIndex,
                  builder: (int index) => _DrawerArtwork(gray: _gray, state: index),
                ),
                builder: (int index) => _DrawerArtwork(gray: _gray, state: index),
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
                    style: _FinalType.productTitle,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '8 compartments · expandable to 22.4 in · non-slip base',
                    style: WalkaType.body,
                  ),
                  const SizedBox(height: 24),
                  _DrawerVariantPicker(
                    gray: _gray,
                    onChanged: (bool gray) {
                      setState(() {
                        _gray = gray;
                        _galleryIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(height: 28),
                  const _BenefitStrip(
                    items: <(IconData, String)>[
                      (Icons.grid_view_rounded, '8 compartments'),
                      (Icons.open_in_full_rounded, 'Expands to 22.4 in'),
                      (Icons.layers_outlined, 'Plastic'),
                      (Icons.drag_handle_rounded, 'Non-slip base'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const _EditorialBlock(
                    eyebrow: 'DESIGNED FOR DAILY ORDER',
                    title: 'More capacity. Less visual clutter.',
                    body:
                        'A calm expandable layout keeps cutlery and everyday utensils easy to reach while using drawer space more deliberately.',
                  ),
                  const SizedBox(height: 28),
                  const _Disclosure(
                    title: 'Verified specifications',
                    icon: Icons.fact_check_outlined,
                    rows: <(String, String)>[
                      ('Material', 'Plastic'),
                      ('Compartments', '8'),
                      ('Closed size', '13 × 15 × 2 in'),
                      ('Expandable width', 'Up to 22.4 in'),
                      ('Base', 'Non-slip'),
                      ('Colors', 'White · Gray'),
                      ('Product weight', '1.72 lb'),
                      ('Packaging', '13.46 × 15.16 × 2.36 in'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _RelatedCard(
                    eyebrow: 'CONTINUE THE WALKA EDIT',
                    title: 'Lunch, organized.',
                    subtitle: '1200 ml · SUS304 · 4 compartments',
                    icon: Icons.lunch_dining_outlined,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WalkaLunchProductDetailV100(),
                        ),
                      );
                    },
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

class WalkaLunchProductDetailV100 extends StatefulWidget {
  const WalkaLunchProductDetailV100({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  State<WalkaLunchProductDetailV100> createState() =>
      _WalkaLunchProductDetailV100State();
}

class _WalkaLunchProductDetailV100State
    extends State<WalkaLunchProductDetailV100> {
  late WalkaLunchVariant _variant = widget.initialVariant;
  int _galleryIndex = 0;
  bool _favorite = false;

  WalkaAmazonLunchVariant get _amazonVariant => switch (_variant) {
        WalkaLunchVariant.blue => WalkaAmazonLunchVariant.blue,
        WalkaLunchVariant.pink => WalkaAmazonLunchVariant.pink,
        WalkaLunchVariant.green => WalkaAmazonLunchVariant.green,
      };

  Future<void> _buy() async {
    final bool opened = await openLunchBoxOnAmazon(_amazonVariant);
    if (!mounted || opened) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Amazon could not be opened. Please try again.')),
    );
  }

  Future<void> _share() async {
    await Clipboard.setData(
      ClipboardData(text: amazonLunchBoxUri(_amazonVariant).toString()),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product link copied.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _Wordmark(),
        actions: <Widget>[
          IconButton(
            onPressed: _share,
            tooltip: 'Share product',
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            onPressed: () => setState(() => _favorite = !_favorite),
            tooltip: _favorite ? 'Remove favorite' : 'Add favorite',
            icon: Icon(
              _favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _favorite ? WalkaColors.gold : WalkaColors.navy,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      bottomNavigationBar: _PurchaseBar(
        variant: _variant.label.toUpperCase(),
        onBuy: _buy,
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: _GalleryCard(
                  key: ValueKey<WalkaLunchVariant>(_variant),
                  index: _galleryIndex,
                  tone: _variant.surface,
                  onChanged: (int index) => setState(() => _galleryIndex = index),
                  onExpand: () => _openGallery(
                    context,
                    title: 'Lunch Box · ${_variant.label}',
                    initialIndex: _galleryIndex,
                    builder: (int index) => _LunchArtwork(
                      variant: _variant,
                      state: index,
                    ),
                  ),
                  builder: (int index) => _LunchArtwork(
                    variant: _variant,
                    state: index,
                  ),
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
                    style: _FinalType.productTitle,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '1200 ml · 4 compartments · ${_variant.label} · ${_variant.pantone}',
                    style: WalkaType.body,
                  ),
                  const SizedBox(height: 24),
                  _LunchVariantPicker(
                    selected: _variant,
                    onSelected: (WalkaLunchVariant variant) {
                      setState(() {
                        _variant = variant;
                        _galleryIndex = 0;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  const _UsageCard(),
                  const SizedBox(height: 28),
                  const _BenefitStrip(
                    items: <(IconData, String)>[
                      (Icons.grid_view_rounded, '4 compartments'),
                      (Icons.local_drink_outlined, '1200 ml'),
                      (Icons.kitchen_outlined, 'SUS304 tray'),
                      (Icons.shopping_bag_outlined, 'Insulated bag'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const _EditorialBlock(
                    eyebrow: 'BUILT FOR ADULT ROUTINES',
                    title: 'A complete lunch system, refined.',
                    body:
                        'SUS304 where food sits, a practical BPA-free PP outer body, thoughtful accessories and a restrained palette for everyday carry.',
                  ),
                  const SizedBox(height: 28),
                  const _Disclosure(
                    title: 'What is included',
                    icon: Icons.inventory_2_outlined,
                    rows: <(String, String)>[
                      ('Food tray', 'SUS304 stainless steel'),
                      ('Outer body', 'BPA-free PP'),
                      ('Lid', '4 clips + silicone gasket'),
                      ('Carry', 'Insulated bag'),
                      ('Sauce cup', 'Stainless cup + lid'),
                      ('Utensils', 'Spoon + fork'),
                    ],
                  ),
                  const _Disclosure(
                    title: 'Dimensions',
                    icon: Icons.straighten_rounded,
                    rows: <(String, String)>[
                      ('Capacity', '1200 ml'),
                      ('Lunch box', '11.42 × 8.66 × 3.15 in'),
                      ('With bag', '11.81 × 8.86 × 3.54 in'),
                      ('Bag only', '10.63 × 7.48 × 2.76 in'),
                      ('Weight with bag', '1.84 lb'),
                    ],
                  ),
                  const _Disclosure(
                    title: 'Care & microwave',
                    icon: Icons.cleaning_services_outlined,
                    rows: <(String, String)>[
                      ('SUS304 tray', 'Dishwasher safe · top rack'),
                      ('Steel tray microwave', 'Not microwave safe'),
                      ('Lid & gasket', 'Hand wash'),
                      ('PP outer body', 'Microwave safe without steel tray'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _RelatedCard(
                    eyebrow: 'CONTINUE THE WALKA EDIT',
                    title: 'A calmer drawer.',
                    subtitle: '8 compartments · expandable to 22.4 in',
                    icon: Icons.grid_view_outlined,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const WalkaDrawerProductDetailV100(),
                        ),
                      );
                    },
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

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'WALKA',
      style: TextStyle(
        color: WalkaColors.navy,
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 4.3,
      ),
    );
  }
}

abstract final class _FinalType {
  static const TextStyle productTitle = TextStyle(
    fontFamily: 'serif',
    color: WalkaColors.navy,
    fontSize: 31,
    height: 1.06,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
  );
}

class _PurchaseBar extends StatelessWidget {
  const _PurchaseBar({required this.variant, required this.onBuy});

  final String variant;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: WalkaColors.line)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'SELECTED',
                    style: TextStyle(
                      color: WalkaColors.muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    variant,
                    style: const TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 205,
              child: ElevatedButton.icon(
                onPressed: onBuy,
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

class _GalleryCard extends StatefulWidget {
  const _GalleryCard({
    super.key,
    required this.index,
    required this.tone,
    required this.onChanged,
    required this.onExpand,
    required this.builder,
  });

  final int index;
  final Color tone;
  final ValueChanged<int> onChanged;
  final VoidCallback onExpand;
  final Widget Function(int index) builder;

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  late final PageController _controller = PageController(initialPage: widget.index);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: widget.tone,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _controller,
            itemCount: 3,
            onPageChanged: widget.onChanged,
            itemBuilder: (_, int index) => Center(child: widget.builder(index)),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: IconButton.filledTonal(
              onPressed: widget.onExpand,
              tooltip: 'View fullscreen',
              icon: const Icon(Icons.fullscreen_rounded),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(3, (int index) {
                final bool selected = index == widget.index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 24 : 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: selected ? WalkaColors.navy : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

void _openGallery(
  BuildContext context, {
  required String title,
  required int initialIndex,
  required Widget Function(int index) builder,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _FullscreenGallery(
        title: title,
        initialIndex: initialIndex,
        builder: builder,
      ),
    ),
  );
}

class _FullscreenGallery extends StatefulWidget {
  const _FullscreenGallery({
    required this.title,
    required this.initialIndex,
    required this.builder,
  });

  final String title;
  final int initialIndex;
  final Widget Function(int index) builder;

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
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
      backgroundColor: const Color(0xFFF7F7F5),
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: <Widget>[
          PageView.builder(
            controller: _controller,
            itemCount: 3,
            onPageChanged: (int value) => setState(() => _index = value),
            itemBuilder: (_, int index) {
              return InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(child: widget.builder(index)),
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: WalkaColors.navy,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${_index + 1} / 3',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerVariantPicker extends StatelessWidget {
  const _DrawerVariantPicker({required this.gray, required this.onChanged});

  final bool gray;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _VariantButton(
            label: 'WHITE',
            selected: !gray,
            swatch: const Color(0xFFF3F0E8),
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _VariantButton(
            label: 'GRAY',
            selected: gray,
            swatch: const Color(0xFFBFC3C8),
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _LunchVariantPicker extends StatelessWidget {
  const _LunchVariantPicker({required this.selected, required this.onSelected});

  final WalkaLunchVariant selected;
  final ValueChanged<WalkaLunchVariant> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: WalkaLunchVariant.values.map((WalkaLunchVariant variant) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: variant == WalkaLunchVariant.green ? 0 : 8,
            ),
            child: _VariantButton(
              label: variant.label.toUpperCase(),
              selected: selected == variant,
              swatch: variant.color,
              onTap: () => onSelected(variant),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _VariantButton extends StatelessWidget {
  const _VariantButton({
    required this.label,
    required this.selected,
    required this.swatch,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color swatch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? WalkaColors.navy : Colors.white,
        foregroundColor: selected ? Colors.white : WalkaColors.navy,
        side: BorderSide(color: selected ? WalkaColors.navy : WalkaColors.line),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: swatch,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(width: 7),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _BenefitStrip extends StatelessWidget {
  const _BenefitStrip({required this.items});

  final List<(IconData, String)> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map(((IconData, String) item) {
        return Container(
          width: (MediaQuery.sizeOf(context).width - 48) / 2,
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Row(
            children: <Widget>[
              Icon(item.$1, color: WalkaColors.gold, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.$2,
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
      }).toList(),
    );
  }
}

class _EditorialBlock extends StatelessWidget {
  const _EditorialBlock({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(eyebrow, style: WalkaType.eyebrow),
          const SizedBox(height: 9),
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
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _Disclosure extends StatelessWidget {
  const _Disclosure({required this.title, required this.icon, required this.rows});

  final String title;
  final IconData icon;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(bottom: 12),
      leading: Icon(icon, color: WalkaColors.gold),
      title: Text(
        title,
        style: const TextStyle(
          color: WalkaColors.navy,
          fontWeight: FontWeight.w800,
        ),
      ),
      children: rows.map(((String, String) row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  row.$1,
                  style: const TextStyle(color: WalkaColors.muted, fontSize: 12),
                ),
              ),
              const SizedBox(width: 16),
              Flexible(
                child: Text(
                  row.$2,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard();

  @override
  Widget build(BuildContext context) {
    const List<String> lines = <String>[
      'Secure Lock | Helps Prevent Spills',
      'Best for dry & semi-wet foods',
      'Not intended for liquids',
      'Carry upright',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('USE GUIDANCE', style: WalkaType.eyebrow),
          const SizedBox(height: 10),
          ...lines.map((String line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.check_circle, color: WalkaColors.navy, size: 17),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        line,
                        style: const TextStyle(
                          color: WalkaColors.navy,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WalkaColors.surface,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: WalkaColors.navy, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      eyebrow,
                      style: const TextStyle(
                        color: WalkaColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        color: WalkaColors.navy,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: WalkaColors.muted, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: WalkaColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerArtwork extends StatelessWidget {
  const _DrawerArtwork({required this.gray, required this.state});

  final bool gray;
  final int state;

  @override
  Widget build(BuildContext context) {
    final Color body = gray ? const Color(0xFFBFC4C9) : const Color(0xFFF1EEE6);
    return Transform.rotate(
      angle: state == 1 ? -0.08 : state == 2 ? 0.08 : -0.02,
      child: Container(
        width: state == 2 ? 285 : 260,
        height: state == 2 ? 175 : 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: body,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 14)),
          ],
        ),
        child: GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          children: List<Widget>.generate(8, (int index) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _LunchArtwork extends StatelessWidget {
  const _LunchArtwork({required this.variant, required this.state});

  final WalkaLunchVariant variant;
  final int state;

  @override
  Widget build(BuildContext context) {
    if (state == 2) {
      return Container(
        width: 210,
        height: 250,
        decoration: BoxDecoration(
          color: variant.color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 14)),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'WALKA',
          style: TextStyle(
            color: WalkaColors.navy,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
      );
    }

    return Transform.rotate(
      angle: state == 1 ? -0.07 : 0.04,
      child: Container(
        width: 275,
        height: 185,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: variant.color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 14)),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFD5D8D9),
            borderRadius: BorderRadius.circular(17),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: <Widget>[
                    Expanded(child: _LunchCell()),
                    Expanded(child: _LunchCell()),
                    Expanded(child: _LunchCell()),
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

class _LunchCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 6, 8, 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
