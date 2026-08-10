import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaHomeTrustStrip extends StatelessWidget {
  const WalkaHomeTrustStrip({
    required this.itemCount,
    required this.release,
    super.key,
  });

  final int itemCount;
  final String release;

  @override
  Widget build(BuildContext context) {
    final List<_TrustData> data = <_TrustData>[
      _TrustData(
        Icons.inventory_2_outlined,
        '$itemCount variants',
        'Current WALKA catalog',
      ),
      const _TrustData(
        Icons.open_in_new_rounded,
        'Official Amazon',
        'Purchase handoff',
      ),
      _TrustData(
        Icons.verified_user_outlined,
        'Catalog $release',
        'Verified product facts',
      ),
    ];

    return Container(
      key: const ValueKey<String>('home-reference-trust-strip'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: WalkaColors.line),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: WalkaColors.navy.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool singleColumn = constraints.maxWidth < 330 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.15;
          final double width = singleColumn
              ? constraints.maxWidth
              : (constraints.maxWidth - 8) / 3;
          return Wrap(
            spacing: singleColumn ? 0 : 4,
            runSpacing: 12,
            children: data
                .map(
                  (_TrustData item) => SizedBox(
                    width: width,
                    child: _TrustTile(data: item),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _TrustData {
  const _TrustData(this.icon, this.label, this.detail);

  final IconData icon;
  final String label;
  final String detail;
}

class _TrustTile extends StatelessWidget {
  const _TrustTile({required this.data});

  final _TrustData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WalkaColors.gold.withValues(alpha: 0.14),
            ),
            child: Icon(data.icon, color: WalkaColors.gold, size: 18),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  data.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: WalkaColors.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: WalkaColors.muted,
                    fontSize: 8.5,
                    height: 1.2,
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
