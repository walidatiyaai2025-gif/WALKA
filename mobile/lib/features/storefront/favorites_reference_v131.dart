import 'package:flutter/material.dart';

import '../../design_system/walka_shell.dart';
import '../favorites/favorites_state.dart';
import '../products/product_experience_v100.dart';
import 'presentation/widgets/favorites/walka_favorites_empty_state.dart';
import 'presentation/widgets/favorites/walka_favorites_filters.dart';
import 'presentation/widgets/favorites/walka_favorites_header.dart';
import 'presentation/widgets/favorites/walka_favorites_sort_row.dart';
import 'presentation/widgets/favorites/walka_favorites_title.dart';
import 'presentation/widgets/favorites/walka_favorites_trust.dart';
import 'presentation/widgets/favorites/walka_saved_drawer_card.dart';

/// DESIGN-007B.4 Android-reference Favorites surface.
///
/// The page now owns state/navigation wiring only. Visual units are extracted
/// under `presentation/widgets/favorites/` while preserving the released
/// device-local Drawer Organizer Favorites contract.
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
          const SliverToBoxAdapter(child: WalkaFavoritesHeader()),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 24, gutter, 0),
            sliver: SliverToBoxAdapter(
              child: WalkaFavoritesTitle(
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
              child: WalkaFavoritesFilters(
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
              sliver: const SliverToBoxAdapter(child: WalkaFavoritesSortRow()),
            ),
          if (variants.isEmpty)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 18, gutter, 0),
              sliver: SliverToBoxAdapter(
                child: WalkaFavoritesEmptyState(onExplore: widget.onExplore),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 16, gutter, 0),
              sliver: SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    final bool oneColumn = constraints.maxWidth < 340;
                    const double spacing = 12;
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
                              child: WalkaSavedDrawerCard(
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
            sliver: const SliverToBoxAdapter(child: WalkaFavoritesTrust()),
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
