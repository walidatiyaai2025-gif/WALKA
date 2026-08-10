import 'package:flutter/material.dart';

import '../../../../../design_system/walka_product_visual.dart';
import '../../../../../design_system/walka_theme.dart';

class WalkaSavedDrawerCard extends StatelessWidget {
  const WalkaSavedDrawerCard({
    required this.gray,
    required this.editMode,
    required this.onOpen,
    required this.onRemove,
    super.key,
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
