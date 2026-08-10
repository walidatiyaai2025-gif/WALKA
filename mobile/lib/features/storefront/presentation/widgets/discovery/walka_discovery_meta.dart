import 'package:flutter/material.dart';

import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/features/catalog/catalog_state.dart';
import 'package:walka/features/catalog/domain/walka_catalog.dart';

class WalkaDiscoveryCountBadge extends StatelessWidget {
  const WalkaDiscoveryCountBadge({required this.count, super.key});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: WalkaColors.gold.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count VARIANTS',
        style: const TextStyle(
          color: WalkaColors.navy,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class WalkaDiscoverySourceBadge extends StatelessWidget {
  const WalkaDiscoverySourceBadge({required this.source, super.key});

  final WalkaCatalogSource source;

  @override
  Widget build(BuildContext context) {
    final String label = switch (source) {
      WalkaCatalogSource.remote => 'LIVE CATALOG',
      WalkaCatalogSource.cache => 'SAVED CATALOG',
      WalkaCatalogSource.bundled => 'BUILT-IN CATALOG',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: WalkaColors.muted,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.45,
        ),
      ),
    );
  }
}

class WalkaDiscoveryCatalogStatus extends StatelessWidget {
  const WalkaDiscoveryCatalogStatus({required this.controller, super.key});

  final WalkaCatalogController controller;

  @override
  Widget build(BuildContext context) {
    final String label;
    final IconData icon;
    if (controller.isLoading) {
      label = 'Updating WALKA catalog…';
      icon = Icons.sync_rounded;
    } else if (controller.snapshot.source == WalkaCatalogSource.cache) {
      label = 'Offline · showing the last saved WALKA catalog';
      icon = Icons.cloud_off_outlined;
    } else {
      label = 'Offline · showing the built-in WALKA catalog';
      icon = Icons.inventory_2_outlined;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: WalkaColors.line),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: WalkaColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: WalkaColors.navy,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
