import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';

class WalkaHomeBenefitBand extends StatelessWidget {
  const WalkaHomeBenefitBand({super.key});

  static const List<_BenefitData> _benefits = <_BenefitData>[
    _BenefitData(
      Icons.verified_outlined,
      'Premium Quality',
      'Thoughtful materials and construction.',
    ),
    _BenefitData(
      Icons.eco_outlined,
      'BPA Free',
      'Food-contact materials made for daily use.',
    ),
    _BenefitData(
      Icons.cleaning_services_outlined,
      'Easy to Care For',
      'Clear product-specific care guidance.',
    ),
    _BenefitData(
      Icons.lock_outline_rounded,
      'Secure Lock',
      'Helps prevent spills. Carry upright.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('home-reference-benefits'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      decoration: BoxDecoration(
        color: WalkaColors.navy,
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: WalkaColors.navy.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool twoColumns = constraints.maxWidth < 360 ||
              MediaQuery.textScalerOf(context).scale(1) > 1.15;
          final double width = twoColumns
              ? (constraints.maxWidth - 8) / 2
              : (constraints.maxWidth - 12) / 4;
          return Wrap(
            spacing: twoColumns ? 8 : 4,
            runSpacing: 16,
            children: _benefits
                .map(
                  (_BenefitData data) => SizedBox(
                    width: width,
                    child: _BenefitTile(data: data),
                  ),
                )
                .toList(growable: false),
          );
        },
      ),
    );
  }
}

class _BenefitData {
  const _BenefitData(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.data});

  final _BenefitData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(data.icon, color: WalkaColors.gold, size: 25),
          const SizedBox(height: 8),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              height: 1.15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFFD2DDE7),
              fontSize: 8.5,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
