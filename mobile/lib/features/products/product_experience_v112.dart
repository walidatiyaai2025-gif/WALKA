import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../commerce/amazon_purchase.dart';
import '../favorites/favorites_state.dart';
import '../lunch/lunch_box_v6.dart';
import 'presentation/walka_pdp_model.dart';
import 'presentation/widgets/walka_pdp_amazon_bar.dart';
import 'presentation/widgets/walka_pdp_app_bar.dart';
import 'presentation/widgets/walka_pdp_body.dart';
import 'presentation/widgets/walka_pdp_fullscreen_gallery.dart';
import 'presentation/widgets/walka_pdp_gallery.dart';
import 'presentation/widgets/walka_pdp_variant_selector.dart';

class WalkaDrawerProductDetailV112 extends StatefulWidget {
  const WalkaDrawerProductDetailV112({super.key, this.initialGray = false});

  final bool initialGray;

  @override
  State<WalkaDrawerProductDetailV112> createState() =>
      _WalkaDrawerProductDetailV112State();
}

class _WalkaDrawerProductDetailV112State
    extends State<WalkaDrawerProductDetailV112> {
  late bool _gray = widget.initialGray;

  WalkaPdpPresentationModel get _model =>
      WalkaPdpPresentationModel.drawer(gray: _gray);

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

  Future<void> _share() => showWalkaPdpShareSheet(
        context,
        title: 'WALKA Drawer Organizer · ${_gray ? 'Gray' : 'White'}',
        uri: amazonDrawerOrganizerUri(gray: _gray),
      );

  void _openGallery(int index) {
    final WalkaPdpPresentationModel model = _model;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => WalkaPdpFullscreenGallery(
          initialIndex: index,
          title: 'Drawer Organizer',
          variantId: model.variantId,
          kind: model.kind,
          primaryColor: model.primaryColor,
          surface: model.surface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WalkaFavoritesController favorites = WalkaFavoritesScope.of(context);
    final bool isFavorite = favorites.isDrawerFavorite(gray: _gray);
    final WalkaPdpPresentationModel model = _model;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: WalkaPdpAppBar(
        onShare: _share,
        onFavorite: () => _toggleFavorite(favorites),
        isFavorite: isFavorite,
      ),
      bottomNavigationBar: WalkaPdpAmazonBar(
        selectedLabel: _gray ? 'GRAY' : 'WHITE',
        onPressed: _buy,
      ),
      body: WalkaPdpBody(
        scrollKey: const PageStorageKey<String>('design-007b3-drawer-pdp-scroll'),
        model: model,
        gallery: WalkaPdpGallery(
          key: ValueKey<String>('drawer-gallery-${_gray ? 'gray' : 'white'}'),
          variantId: model.variantId,
          kind: model.kind,
          primaryColor: model.primaryColor,
          surface: model.surface,
          semanticLabel: model.semanticLabel,
          onExpand: _openGallery,
        ),
        variantSelector: WalkaPdpVariantSelector<bool>(
          selected: _gray,
          selectedLabel: model.selectedLabel,
          options: const <WalkaPdpVariantOption<bool>>[
            WalkaPdpVariantOption<bool>(
              value: false,
              label: 'White',
              color: Color(0xFFF7F4EC),
              key: ValueKey<String>('premium-drawer-white'),
            ),
            WalkaPdpVariantOption<bool>(
              value: true,
              label: 'Gray',
              color: Color(0xFFD3D7D9),
              key: ValueKey<String>('premium-drawer-gray'),
            ),
          ],
          onChanged: (bool gray) => setState(() => _gray = gray),
        ),
        editorialTitle: 'Organize the drawer. Keep the counter calm.',
        editorialBody:
            'An expandable eight-compartment layout gives everyday utensils a defined place while keeping the visual language clean and minimal.',
      ),
    );
  }
}

class WalkaLunchProductDetailV112 extends StatefulWidget {
  const WalkaLunchProductDetailV112({
    super.key,
    this.initialVariant = WalkaLunchVariant.blue,
  });

  final WalkaLunchVariant initialVariant;

  @override
  State<WalkaLunchProductDetailV112> createState() =>
      _WalkaLunchProductDetailV112State();
}

class _WalkaLunchProductDetailV112State
    extends State<WalkaLunchProductDetailV112> {
  late WalkaLunchVariant _variant = widget.initialVariant;
  bool _favorite = false;

  WalkaPdpPresentationModel get _model =>
      WalkaPdpPresentationModel.lunch(_variant);

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

  Future<void> _share() => showWalkaPdpShareSheet(
        context,
        title: 'WALKA Large Bento Lunch Box · ${_variant.label}',
        uri: amazonLunchBoxUri(_amazonVariant),
      );

  void _openGallery(int index) {
    final WalkaPdpPresentationModel model = _model;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => WalkaPdpFullscreenGallery(
          initialIndex: index,
          title: '${_variant.label} Lunch Box',
          variantId: model.variantId,
          kind: model.kind,
          primaryColor: model.primaryColor,
          surface: model.surface,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WalkaPdpPresentationModel model = _model;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      appBar: WalkaPdpAppBar(
        onShare: _share,
        onFavorite: () => setState(() => _favorite = !_favorite),
        isFavorite: _favorite,
      ),
      bottomNavigationBar: WalkaPdpAmazonBar(
        selectedLabel: _variant.label.toUpperCase(),
        onPressed: _buy,
      ),
      body: WalkaPdpBody(
        scrollKey: const PageStorageKey<String>('design-007b3-lunch-pdp-scroll'),
        model: model,
        gallery: WalkaPdpGallery(
          key: ValueKey<WalkaLunchVariant>(_variant),
          variantId: model.variantId,
          kind: model.kind,
          primaryColor: model.primaryColor,
          surface: model.surface,
          semanticLabel: model.semanticLabel,
          onExpand: _openGallery,
        ),
        variantSelector: WalkaPdpVariantSelector<WalkaLunchVariant>(
          selected: _variant,
          selectedLabel: model.selectedLabel,
          options: WalkaLunchVariant.values
              .map(
                (WalkaLunchVariant variant) => WalkaPdpVariantOption<WalkaLunchVariant>(
                  value: variant,
                  label: variant.label,
                  color: variant.color,
                  key: ValueKey<String>('premium-lunch-${variant.name}'),
                ),
              )
              .toList(growable: false),
          onChanged: (WalkaLunchVariant variant) =>
              setState(() => _variant = variant),
        ),
        editorialTitle: 'A complete lunch system for the workday.',
        editorialBody:
            'The food-grade stainless tray, PP outer box, sauce cup, utensils and carry bag form one coordinated adult lunch set.',
      ),
    );
  }
}

Future<void> showWalkaPdpShareSheet(
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
              const Text('SHARE WALKA'),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(uri.toString()),
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
