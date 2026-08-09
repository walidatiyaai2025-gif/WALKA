import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../favorites/favorites_state.dart';
import '../products/product_experience_v10.dart';

class WalkaFavoritesV10 extends StatefulWidget {
  const WalkaFavoritesV10({required this.onExploreCollections, super.key});

  final VoidCallback onExploreCollections;

  @override
  State<WalkaFavoritesV10> createState() => _WalkaFavoritesV10State();
}

class _WalkaFavoritesV10State extends State<WalkaFavoritesV10> {
  Future<void> _remove(
    WalkaFavoritesController controller,
    bool gray,
  ) async {
    final bool saved = await controller.removeDrawer(gray: gray);
    if (!mounted || saved) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Favorite could not be updated.')),
    );
  }

  void _open(bool gray) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalkaDrawerProductDetailV10(initialGray: gray),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final WalkaFavoritesController controller = WalkaFavoritesScope.of(context);
    final List<bool> saved = controller.savedDrawerVariants;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Text(
                'WALKA',
                style: TextStyle(
                  color: WalkaColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.8,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('YOUR WALKA EDIT', style: WalkaType.eyebrow),
                  SizedBox(height: 9),
                  Text('Favorites', style: WalkaType.sectionTitle),
                  SizedBox(height: 9),
                  Text(
                    'Return to saved pieces and open the complete product experience without losing your selected finish.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          if (saved.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: WalkaColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: WalkaColors.navy,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Your edit is ready for something beautiful.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: WalkaColors.navy,
                        fontSize: 25,
                        height: 1.08,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Save a Drawer Organizer finish to keep it here.',
                      textAlign: TextAlign.center,
                      style: WalkaType.body,
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: 230,
                      child: OutlinedButton(
                        onPressed: widget.onExploreCollections,
                        child: const Text('EXPLORE COLLECTIONS'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...<Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                child: Row(
                  children: <Widget>[
                    Text(
                      '${saved.length} SAVED',
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.favorite_rounded,
                      color: WalkaColors.gold,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 42),
              sliver: SliverGrid.builder(
                itemCount: saved.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final bool gray = saved[index];
                  return _FavoriteCardV10(
                    gray: gray,
                    onOpen: () => _open(gray),
                    onRemove: () => _remove(controller, gray),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FavoriteCardV10 extends StatelessWidget {
  const _FavoriteCardV10({
    required this.gray,
    required this.onOpen,
    required this.onRemove,
  });
  final bool gray;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final Color tone = gray ? const Color(0xFFE1E3E6) : const Color(0xFFF6F3EC);
    return Material(
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
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: Container(
                        color: tone,
                        alignment: Alignment.center,
                        child: _FavoriteOrganizerRenderV10(gray: gray),
                      ),
                    ),
                    Positioned(
                      right: 7,
                      top: 7,
                      child: IconButton(
                        onPressed: onRemove,
                        tooltip: 'Remove ${gray ? 'Gray' : 'White'} favorite',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                        ),
                        icon: const Icon(
                          Icons.favorite_rounded,
                          color: WalkaColors.gold,
                          size: 19,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'DRAWER ORGANIZATION',
                      style: TextStyle(
                        color: WalkaColors.gold,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Expandable Drawer Organizer',
                      maxLines: 2,
                      style: TextStyle(
                        color: WalkaColors.navy,
                        fontSize: 12,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: gray ? const Color(0xFF969CA2) : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: WalkaColors.line),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          gray ? 'Gray' : 'White',
                          style: const TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: WalkaColors.gold,
                          size: 16,
                        ),
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

class _FavoriteOrganizerRenderV10 extends StatelessWidget {
  const _FavoriteOrganizerRenderV10({required this.gray});
  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.06,
      child: Container(
        width: 130,
        height: 84,
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: gray ? const Color(0xFF9A9FA5) : const Color(0xFFF9F8F4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x26000000), blurRadius: 14, offset: Offset(0, 8)),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: _FavoriteCellV10(gray: gray)),
                  const SizedBox(height: 4),
                  Expanded(child: _FavoriteCellV10(gray: gray)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  Expanded(child: _FavoriteCellV10(gray: gray)),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(child: _FavoriteCellV10(gray: gray)),
                        const SizedBox(width: 4),
                        Expanded(child: _FavoriteCellV10(gray: gray)),
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

class _FavoriteCellV10 extends StatelessWidget {
  const _FavoriteCellV10({required this.gray});
  final bool gray;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: gray ? const Color(0xFFB5BABF) : const Color(0xFFE9EAE6),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
