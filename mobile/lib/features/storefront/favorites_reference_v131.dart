import 'package:flutter/material.dart';

import '../../design_system/walka_product_visual.dart';
import '../../design_system/walka_shell.dart';
import '../../design_system/walka_theme.dart';
import '../favorites/favorites_state.dart';
import '../products/product_experience_v100.dart';

/// DESIGN-007B.4 Android-reference Favorites surface.
///
/// The visual hierarchy follows the approved Android Favorites reference while
/// preserving the released device-local Favorites contract. The current data
/// model intentionally supports Drawer Organizer White/Gray only; Lunch favorite
/// persistence, prices, ratings and in-app cart behavior are not invented here.
class WalkaFavoritesReferenceV131 extends StatefulWidget {
  const WalkaFavoritesReferenceV131({required this.onExplore, super.key});

  final VoidCallback onExplore;

  @override
  State<WalkaFavoritesReferenceV131> createState() =>
      _WalkaFavoritesReferenceV131State();
}

class _WalkaFavoritesReferenceV131State
    extends State<WalkaFavoritesReferenceV131> {
  bool _editMode = false;
  bool _drawerFilter = false;

  @override
  Widget build(BuildContext context) {
    final WalkaFavoritesController controller = WalkaFavoritesScope.of(context);
    final List<bool> variants = controller.savedDrawerVariants;
    final double gutter = WalkaShellMetrics.horizontalGutter(context);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        key: const PageStorageKey<String>('walka-reference-favorites-scroll'),
        slivers: <Widget>[
          const SliverToBoxAdapter(child: _ReferenceFavoritesTopBar()),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _ReferenceFavoritesTitle(
                count: variants.length,
                editMode: _editMode,
                onEdit: variants.isEmpty
                    ? null
                    : () => setState(() => _editMode = !_editMode),
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 22, gutter, 0),
            sliver: SliverToBoxAdapter(
              child: _ReferenceFavoritesFilters(
                count: variants.length,
                drawerSelected: _drawerFilter,
                onAll: () => setState(() => _drawerFilter = false),
                onDrawer: () => setState(() => _drawerFilter = true),
              ),
            ),
          ),
          if (variants.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 14, gutter, 0),
              sliver: const SliverToBoxAdapter(child: _ReferenceSortRow()),
            ),
          if (variants.isEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
              sliver: SliverToBoxAdapter(
                child: _ReferenceEmptyFavorites(onExplore: widget.onExplore),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
              sliver: SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool oneColumn = constraints.maxWidth < 340;
                    final double spacing = 12;
                    final double cardWidth = oneColumn
                        ? constraints.maxWidth
                        : (constraints.maxWidth - spacing) / 2;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: 14,
                      children: variants
                          .map(
                            (bool gray) => SizedBox(
                              width: cardWidth,
                              child: _ReferenceSavedDrawerCard(
                                gray: gray,
                                editMode: _editMode,
                                onOpen: () => _openProduct(context, gray),
                                onRemove: () => _removeFavorite(
                                  context,
                                  controller,
                                  gray,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    );
                  },
                ),
              ),
            ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 20, gutter, 42),
            sliver: const SliverToBoxAdapter(child: _ReferenceFavoritesTrust()),
          ),
        ],
      ),
    );
  }

  void _openProduct(BuildContext context, bool gray) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaDrawerProductDetailV100(initialGray: gray),
      ),
    );
  }

  Future<void> _removeFavorite(
    BuildContext context,
    WalkaFavoritesController controller,
    bool gray,
  ) async {
    final bool saved = await controller.removeDrawer(gray: gray);
    if (!context.mounted || saved) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite could not be updated.')),
    );
  }
}

class _ReferenceFavoritesTopBar extends StatelessWidget {
  const _ReferenceFavoritesTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-favorites-topbar'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: WalkaColors.line, width: 0.7)),
      ),
      child: const Row(
        children: <Widget>[
          SizedBox(width: 48, height: 48),
          Expanded(
            child: Center(
              child: Text(
                'WALKA',
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontFamily: 'serif',
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.favorite_rounded, color: WalkaColors.gold),
          ),
        ],
      ),
    );
  }
}

class _ReferenceFavoritesTitle extends StatelessWidget {
  const _ReferenceFavoritesTitle({
    required this.count,
    required this.editMode,
    required this.onEdit,
  });

  final int count;
  final bool editMode;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'My Favorites',
                key: ValueKey<String>('reference-favorites-title'),
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontFamily: 'serif',
                  fontSize: 33,
                  height: 1.04,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '$count ${count == 1 ? 'item' : 'items'} saved',
                key: const ValueKey<String>('reference-favorites-count'),
                style: const TextStyle(
                  color: WalkaColors.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          key: const ValueKey<String>('reference-favorites-edit'),
          onPressed: onEdit,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(70, 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: Text(editMode ? 'DONE' : 'EDIT'),
        ),
      ],
    );
  }
}

class _ReferenceFavoritesFilters extends StatelessWidget {
  const _ReferenceFavoritesFilters({
    required this.count,
    required this.drawerSelected,
    required this.onAll,
    required this.onDrawer,
  });

  final int count;
  final bool drawerSelected;
  final VoidCallback onAll;
  final VoidCallback onDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-favorites-filters'),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: WalkaColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _ReferenceFavoriteFilter(
              icon: Icons.favorite_border_rounded,
              label: 'All Favorites',
              countLabel: '$count',
              selected: !drawerSelected,
              onTap: onAll,
            ),
            const SizedBox(width: 4),
            _ReferenceFavoriteFilter(
              icon: Icons.inventory_2_outlined,
              label: 'Drawer Organizers',
              countLabel: '$count',
              selected: drawerSelected,
              onTap: onDrawer,
            ),
            const SizedBox(width: 4),
            const _ReferenceFavoriteFilter(
              icon: Icons.lunch_dining_outlined,
              label: 'Lunch Boxes',
              countLabel: '—',
              selected: false,
              enabled: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceFavoriteFilter extends StatelessWidget {
  const _ReferenceFavoriteFilter({
    required this.icon,
    required this.label,
    required this.countLabel,
    required this.selected,
    this.enabled = true,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String countLabel;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color foreground = !enabled
        ? WalkaColors.muted
        : selected
            ? WalkaColors.navy
            : WalkaColors.navy;
    return Material(
      color: selected ? const Color(0xFFFFF8EA) : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: selected
              ? const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: WalkaColors.gold, width: 2),
                  ),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 7),
              Container(
                constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: enabled
                      ? WalkaColors.gold.withValues(alpha: 0.16)
                      : const Color(0xFFF1F2F3),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  countLabel,
                  style: TextStyle(
                    color: enabled ? WalkaColors.navy : WalkaColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
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

class _ReferenceSortRow extends StatelessWidget {
  const _ReferenceSortRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-favorites-sort'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: WalkaColors.line),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: <Widget>[
          Text(
            'Sort by:',
            style: TextStyle(
              color: WalkaColors.muted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Saved variants',
              style: TextStyle(
                color: WalkaColors.navy,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Icon(Icons.view_module_outlined, color: WalkaColors.gold, size: 20),
        ],
      ),
    );
  }
}

class _ReferenceEmptyFavorites extends StatelessWidget {
  const _ReferenceEmptyFavorites({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-favorites-empty'),
      padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9ED),
              shape: BoxShape.circle,
              border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.35)),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 34,
              color: WalkaColors.navy,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Save your favorites',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: WalkaColors.navy,
              fontFamily: 'serif',
              fontSize: 23,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          const Text(
            'Save Drawer Organizer variants you love. They stay on this device for quick access anytime.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: WalkaColors.muted,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const ValueKey<String>('reference-favorites-explore'),
              onPressed: onExplore,
              child: const Text('CONTINUE SHOPPING'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceSavedDrawerCard extends StatelessWidget {
  const _ReferenceSavedDrawerCard({
    required this.gray,
    required this.editMode,
    required this.onOpen,
    required this.onRemove,
  });

  final bool gray;
  final bool editMode;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String variant = gray ? 'Gray' : 'White';
    final Color productColor =
        gray ? const Color(0xFFD3D7D9) : const Color(0xFFF7F4EC);
    final Color surface =
        gray ? const Color(0xFFE9ECEE) : const Color(0xFFF4EEDF);

    return Material(
      key: ValueKey<String>('reference-favorite-${gray ? 'gray' : 'white'}'),
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: WalkaColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 154,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ColoredBox(
                        color: surface,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: WalkaProductVisual(
                            kind: WalkaProductVisualKind.drawerOrganizer,
                            primaryColor: productColor,
                            backgroundColor: surface,
                            compact: true,
                            semanticLabel:
                                'WALKA Drawer Organizer $variant favorite',
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.96),
                        shape: const CircleBorder(),
                        child: IconButton(
                          key: ValueKey<String>(
                            'reference-remove-${gray ? 'gray' : 'white'}',
                          ),
                          onPressed: onRemove,
                          tooltip: 'Remove $variant from Favorites',
                          icon: Icon(
                            editMode
                                ? Icons.delete_outline_rounded
                                : Icons.favorite_rounded,
                            color: WalkaColors.navy,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'DRAWER ORGANIZER',
                      style: TextStyle(
                        color: WalkaColors.gold,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.55,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'WALKA Expandable Drawer Organizer',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: WalkaColors.navy,
                        fontFamily: 'serif',
                        fontSize: 17,
                        height: 1.12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: productColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: WalkaColors.navy.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          variant,
                          style: const TextStyle(
                            color: WalkaColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      '8 compartments · expands to 22.4 in',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: onOpen,
                        child: const Text('VIEW PRODUCT'),
                      ),
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

class _ReferenceFavoritesTrust extends StatelessWidget {
  const _ReferenceFavoritesTrust();

  @override
  Widget build(BuildContext context) {
    final List<(IconData, String)> items = <(IconData, String)>[
      (Icons.phone_android_rounded, 'Saved locally'),
      (Icons.verified_outlined, 'Verified details'),
      (Icons.open_in_new_rounded, 'Official Amazon'),
      (Icons.workspace_premium_outlined, 'WALKA quality'),
    ];
    return Container(
      key: const ValueKey<String>('reference-favorites-trust'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WalkaColors.line),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Wrap(
            spacing: 4,
            runSpacing: 14,
            children: items
                .map(
                  ((IconData, String) item) => SizedBox(
                    width: (constraints.maxWidth - 4) / 2,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(item.$1, color: WalkaColors.gold, size: 21),
                        const SizedBox(height: 6),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}
