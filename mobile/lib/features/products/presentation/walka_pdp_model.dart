import 'package:flutter/material.dart';

import '../../../design_system/walka_product_visual.dart';
import '../../catalog/domain/walka_catalog.dart';
import '../../lunch/lunch_box_v6.dart';
import 'widgets/walka_pdp_details.dart';

class WalkaPdpPresentationModel {
  const WalkaPdpPresentationModel({
    required this.variantId,
    required this.kind,
    required this.primaryColor,
    required this.surface,
    required this.semanticLabel,
    required this.eyebrow,
    required this.title,
    required this.factsLine,
    required this.selectedLabel,
    required this.facts,
    required this.specificationGroups,
    this.showLunchUsage = false,
  });

  final String variantId;
  final WalkaProductVisualKind kind;
  final Color primaryColor;
  final Color surface;
  final String semanticLabel;
  final String eyebrow;
  final String title;
  final String factsLine;
  final String selectedLabel;
  final List<WalkaPdpFact> facts;
  final List<WalkaPdpSpecificationGroup> specificationGroups;
  final bool showLunchUsage;

  factory WalkaPdpPresentationModel.drawer({required bool gray}) {
    final String finish = gray ? 'Gray' : 'White';
    return WalkaPdpPresentationModel(
      variantId: 'drawer-organizer:${gray ? 'gray' : 'white'}',
      kind: WalkaProductVisualKind.drawerOrganizer,
      primaryColor:
          gray ? const Color(0xFFD3D7D9) : const Color(0xFFF7F4EC),
      surface: gray ? const Color(0xFFE9ECEE) : const Color(0xFFF4EEDF),
      semanticLabel: 'WALKA Drawer Organizer $finish gallery',
      eyebrow: 'DRAWER ORGANIZATION',
      title: 'WALKA Drawer Organizer',
      factsLine: '8 compartments · 13 × 15 × 2 in · expandable to 22.4 in',
      selectedLabel: '$finish finish',
      facts: const <WalkaPdpFact>[
        WalkaPdpFact(Icons.grid_view_rounded, '8 compartments'),
        WalkaPdpFact(Icons.open_in_full_rounded, 'Expands to 22.4 in'),
        WalkaPdpFact(Icons.pan_tool_alt_outlined, 'Non-slip base'),
        WalkaPdpFact(Icons.layers_outlined, 'Durable plastic'),
      ],
      specificationGroups: const <WalkaPdpSpecificationGroup>[
        WalkaPdpSpecificationGroup(
          title: 'Product details',
          rows: <(String, String)>[
            ('Closed size', '13 × 15 × 2 in'),
            ('Expandable width', '13 to 22.4 in'),
            ('Compartments', '8'),
            ('Base', 'Non-slip'),
            ('Approved finishes', 'White · Gray'),
          ],
        ),
      ],
    );
  }

  factory WalkaPdpPresentationModel.lunch(WalkaLunchVariant variant) {
    return WalkaPdpPresentationModel(
      variantId: 'lunch-box:${variant.name}',
      kind: WalkaProductVisualKind.lunchBox,
      primaryColor: variant.color,
      surface: variant.surface,
      semanticLabel: 'WALKA ${variant.label} Lunch Box gallery',
      eyebrow: 'LUNCH COLLECTION',
      title: 'Large Stainless Steel Bento Lunch Box',
      factsLine: '1200 ml · 4 compartments · SUS304 stainless steel tray',
      selectedLabel: '${variant.label} · ${variant.pantone}',
      showLunchUsage: true,
      facts: const <WalkaPdpFact>[
        WalkaPdpFact(Icons.local_drink_outlined, '1200 ml capacity'),
        WalkaPdpFact(Icons.grid_view_rounded, '4 compartments'),
        WalkaPdpFact(Icons.kitchen_outlined, 'SUS304 food tray'),
        WalkaPdpFact(Icons.shopping_bag_outlined, 'Bag + utensils included'),
      ],
      specificationGroups: const <WalkaPdpSpecificationGroup>[
        WalkaPdpSpecificationGroup(
          title: 'What is included',
          rows: <(String, String)>[
            ('Bento box', 'PP outer + SUS304 tray'),
            ('Sauce cup', 'Stainless cup with lid'),
            ('Utensils', 'Spoon + fork'),
            ('Carry', 'Carry bag'),
          ],
        ),
        WalkaPdpSpecificationGroup(
          title: 'Dimensions',
          rows: <(String, String)>[
            ('Lunch box', '11.42 × 8.66 × 3.15 in'),
            ('With bag', '11.81 × 8.86 × 3.54 in'),
            ('Bag only', '10.63 × 7.48 × 2.76 in'),
            ('Weight with bag', '1.84 lb'),
          ],
        ),
        WalkaPdpSpecificationGroup(
          title: 'Care & use',
          rows: <(String, String)>[
            ('SUS304 tray', 'Dishwasher safe · not microwave safe'),
            ('Lid & gasket', 'Top-rack dishwasher · not microwave safe'),
            ('Microwave', 'PP outer only · remove tray, lid & gasket'),
            ('Carry', 'Keep upright'),
          ],
        ),
      ],
    );
  }
}

class WalkaPdpEditorialCopy {
  const WalkaPdpEditorialCopy({required this.title, required this.body});

  final String title;
  final String body;

  factory WalkaPdpEditorialCopy.fromCatalogProduct(
    WalkaCatalogProduct? product, {
    required String fallbackTitle,
    required String fallbackBody,
  }) {
    final String? governedTitle =
        product != null && product.highlights.isNotEmpty
            ? product.highlights.first.trim()
            : null;
    final String? governedBody = product?.shortDescription?.trim();

    return WalkaPdpEditorialCopy(
      title: governedTitle == null || governedTitle.isEmpty
          ? fallbackTitle
          : governedTitle,
      body: governedBody == null || governedBody.isEmpty
          ? fallbackBody
          : governedBody,
    );
  }
}

class WalkaPdpSpecificationGroup {
  const WalkaPdpSpecificationGroup({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;
}
