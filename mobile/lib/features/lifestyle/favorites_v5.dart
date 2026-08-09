import 'package:flutter/material.dart';

import '../../design_system/walka_theme.dart';
import '../storefront/storefront_v2.dart';

class WalkaFavoritesV5 extends StatefulWidget {
  const WalkaFavoritesV5({required this.onExploreCollections, super.key});

  final VoidCallback onExploreCollections;

  @override
  State<WalkaFavoritesV5> createState() => _WalkaFavoritesV5State();
}

class _WalkaFavoritesV5State extends State<WalkaFavoritesV5> {
  final Set<bool> _savedVariants = <bool>{false, true};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 14, 0),
              child: Row(
                children: <Widget>[
                  Text(
                    'WALKA',
                    style: TextStyle(
                      color: WalkaColors.navy,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 5.2,
                    ),
                  ),
                  Spacer(),
                  SizedBox(width: 48, height: 48),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('YOUR WALKA EDIT', style: WalkaType.eyebrow),
                  SizedBox(height: 9),
                  Text('Favorites', style: WalkaType.sectionTitle),
                  SizedBox(height: 9),
                  Text(
                    'Keep the pieces you want to return to in one calm, curated place.',
                    style: WalkaType.body,
                  ),
                ],
              ),
            ),
          ),
          if (_savedVariants.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 94,
                      height: 94,
                      decoration: const BoxDecoration(
                        color: WalkaColors.surface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: WalkaColors.navy,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your edit is ready for something beautiful.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: WalkaColors.navy,
                        fontSize: 25,
                        height: 1.1,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 11),
                    const Text(
                      'Save WALKA pieces to keep your favorites together.',
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Row(
                  children: <Widget>[
                    Text(
                      '${_savedVariants.length} SAVED',
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
                      size: 17,
                      color: WalkaColors.gold,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.builder(
                itemCount: _savedVariants.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final bool gray = _savedVariants.elementAt(index);
                  return Semantics(
                    button: true,
                    label:
                        'WALKA expandable drawer organizer, ${gray ? 'gray' : 'white'}',
                    child: _AccessibleFavoriteCard(
                      gray: gray,
                      onOpen: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => WalkaProductDetailV2(
                              initialGray: gray,
                            ),
                          ),
                        );
                      },
                      onRemove: () => setState(
                        () => _savedVariants.remove(gray),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 34)),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 42),
                child: _LocalStateNote(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccessibleFavoriteCard extends StatelessWidget {
  const _AccessibleFavoriteCard({
    required this.gray,
    required this.onOpen,
    required this.onRemove,
  });

  final bool gray;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final Color background = gray
        ? const Color(0xFFE0E3E6)
        : const Color(0xFFF5F2EA);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: WalkaColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: background,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(19),
                        ),
                      ),
                      child: Center(
                        child: ExcludeSemantics(
                          child: _FavoriteOrganizer(width: 118, gray: gray),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Semantics(
                        button: true,
                        label: 'Remove ${gray ? 'gray' : 'white'} organizer from favorites',
                        child: IconButton(
                          onPressed: onRemove,
                          tooltip: 'Remove favorite',
                          icon: const Icon(Icons.favorite_rounded, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: 0.94),
                            foregroundColor: WalkaColors.navy,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Expandable Drawer Organizer',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: WalkaColors.navy,
                        fontSize: 16,
                        height: 1.08,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${gray ? 'Gray' : 'White'} · 8 compartments',
                      style: const TextStyle(
                        color: WalkaColors.muted,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 11),
                    const Row(
                      children: <Widget>[
                        Text(
                          'VIEW PRODUCT',
                          style: TextStyle(
                            color: WalkaColors.navy,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: WalkaColors.gold,
                          size: 14,
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

class _LocalStateNote extends StatelessWidget {
  const _LocalStateNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E7C9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.bookmark_outline_rounded, color: WalkaColors.navy),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Favorites remain local preview state in Phase 1. Persistence will be connected in a later functional phase.',
              style: TextStyle(
                color: Color(0xFF435167),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteOrganizer extends StatelessWidget {
  const _FavoriteOrganizer({required this.width, required this.gray});

  final double width;
  final bool gray;

  @override
  Widget build(BuildContext context) {
    final Color shell = gray
        ? const Color(0xFF989DA4)
        : const Color(0xFFF8F7F2);
    final Color inner = gray
        ? const Color(0xFFB0B5BB)
        : Colors.white;

    return Transform.rotate(
      angle: -0.035,
      child: Container(
        width: width,
        height: width * 0.66,
        padding: EdgeInsets.all(width * 0.045),
        decoration: BoxDecoration(
          color: shell,
          borderRadius: BorderRadius.circular(width * 0.08),
          border: Border.all(
            color: gray ? const Color(0xFF7D838A) : const Color(0xFFDCD8CE),
          ),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x240F172A),
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(flex: 2, child: _Compartment(color: inner)),
            SizedBox(width: width * 0.024),
            Expanded(
              child: Column(
                children: <Widget>[
                  Expanded(child: _Compartment(color: inner)),
                  SizedBox(height: width * 0.02),
                  Expanded(child: _Compartment(color: inner)),
                  SizedBox(height: width * 0.02),
                  Expanded(child: _Compartment(color: inner)),
                ],
              ),
            ),
            SizedBox(width: width * 0.024),
            Expanded(flex: 2, child: _Compartment(color: inner)),
          ],
        ),
      ),
    );
  }
}

class _Compartment extends StatelessWidget {
  const _Compartment({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
    );
  }
}
