import 'package:flutter/material.dart';

import '../../../../design_system/components/layout/walka_responsive_grid.dart';
import '../../../../design_system/walka_theme.dart';

class WalkaPdpFact {
  const WalkaPdpFact(this.icon, this.label);

  final IconData icon;
  final String label;
}

class WalkaPdpFactsList extends StatelessWidget {
  const WalkaPdpFactsList({required this.items, super.key});

  final List<WalkaPdpFact> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('WHY WALKA', style: WalkaType.eyebrow),
        const SizedBox(height: 12),
        WalkaResponsiveGrid(
          minItemWidth: 132,
          maxColumns: 4,
          gap: 10,
          runGap: 10,
          children: items
              .map(
                (WalkaPdpFact item) => Container(
                  constraints: const BoxConstraints(minHeight: 86),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: WalkaColors.line),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(item.icon, color: WalkaColors.gold, size: 21),
                      const SizedBox(height: 9),
                      Text(
                        item.label,
                        style: const TextStyle(
                          color: WalkaColors.navy,
                          fontSize: 10.5,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class WalkaPdpSpecificationTable extends StatelessWidget {
  const WalkaPdpSpecificationTable({
    required this.title,
    required this.rows,
    super.key,
  });

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final bool narrow = MediaQuery.sizeOf(context).width < 350;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              color: WalkaColors.navy,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (final (String label, String value) in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: narrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(label, style: _labelStyle),
                        const SizedBox(height: 3),
                        Text(value, style: _valueStyle),
                      ],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(child: Text(label, style: _labelStyle)),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: Text(
                            value,
                            textAlign: TextAlign.right,
                            style: _valueStyle,
                          ),
                        ),
                      ],
                    ),
            ),
        ],
      ),
    );
  }

  static const TextStyle _labelStyle = TextStyle(
    color: WalkaColors.muted,
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle _valueStyle = TextStyle(
    color: WalkaColors.navy,
    fontSize: 10.5,
    height: 1.35,
    fontWeight: FontWeight.w800,
  );
}

class WalkaPdpUsagePanel extends StatelessWidget {
  const WalkaPdpUsagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('reference-approved-lunch-usage'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEDF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'ADULT LUNCH · UPRIGHT CARRY',
            style: TextStyle(
              color: WalkaColors.gold,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Best suited for dry meals & snacks.',
            style: TextStyle(
              color: WalkaColors.navy,
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 3),
          Text(
            'Not intended for liquids. Best for dry & semi-wet foods. Carry upright.',
            style: TextStyle(
              color: WalkaColors.navy,
              fontSize: 11,
              height: 1.4,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class WalkaPdpAmazonTrust extends StatelessWidget {
  const WalkaPdpAmazonTrust({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('walka-pdp-amazon-trust'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WalkaColors.gold.withValues(alpha: 0.20)),
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.verified_outlined, color: WalkaColors.gold),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'WALKA is discovered here. Purchase continues on the selected official Amazon listing.',
              style: TextStyle(
                color: WalkaColors.navy,
                fontSize: 10.5,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
