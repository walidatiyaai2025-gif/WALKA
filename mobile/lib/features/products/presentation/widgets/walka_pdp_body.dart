import 'package:flutter/material.dart';

import '../../../../design_system/walka_shell.dart';
import '../../../content/content_state.dart';
import '../../../content/domain/walka_pdp_layout_content.dart';
import '../walka_pdp_model.dart';
import 'walka_pdp_details.dart';
import 'walka_pdp_editorial.dart';
import 'walka_pdp_identity.dart';

class WalkaPdpBody extends StatelessWidget {
  const WalkaPdpBody({
    required this.scrollKey,
    required this.model,
    required this.gallery,
    required this.variantSelector,
    required this.editorialTitle,
    required this.editorialBody,
    super.key,
  });

  final Key scrollKey;
  final WalkaPdpPresentationModel model;
  final Widget gallery;
  final Widget variantSelector;
  final String editorialTitle;
  final String editorialBody;

  @override
  Widget build(BuildContext context) {
    final double gutter = WalkaShellMetrics.horizontalGutter(context);
    final WalkaPdpLayoutContent layout =
        WalkaContentScope.maybeOf(context)?.pdpLayout.content ??
            WalkaPdpLayoutContent.bundled;
    final List<Widget> sections = <Widget>[];
    for (final WalkaPdpSectionConfig section in layout.visibleSections) {
      sections.addAll(_sectionWidgets(section.id));
    }

    return SingleChildScrollView(
      key: scrollKey,
      padding: EdgeInsets.fromLTRB(
        gutter,
        12,
        gutter,
        40 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: sections,
          ),
        ),
      ),
    );
  }

  List<Widget> _sectionWidgets(WalkaPdpSectionId id) {
    return switch (id) {
      WalkaPdpSectionId.gallery => <Widget>[
          gallery,
        ],
      WalkaPdpSectionId.identity => <Widget>[
          const SizedBox(height: 18),
          WalkaPdpIdentity(
            eyebrow: model.eyebrow,
            title: model.title,
            facts: model.factsLine,
          ),
        ],
      WalkaPdpSectionId.variants => <Widget>[
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 16),
          variantSelector,
        ],
      WalkaPdpSectionId.usage => model.showLunchUsage
          ? const <Widget>[
              SizedBox(height: 18),
              WalkaPdpUsagePanel(),
            ]
          : const <Widget>[],
      WalkaPdpSectionId.facts => <Widget>[
          const SizedBox(height: 24),
          WalkaPdpFactsList(items: model.facts),
        ],
      WalkaPdpSectionId.editorial => <Widget>[
          const SizedBox(height: 24),
          WalkaPdpEditorialPanel(
            title: editorialTitle,
            body: editorialBody,
          ),
        ],
      WalkaPdpSectionId.specifications => <Widget>[
          const SizedBox(height: 14),
          for (int i = 0; i < model.specificationGroups.length; i++) ...<Widget>[
            WalkaPdpSpecificationTable(
              title: model.specificationGroups[i].title,
              rows: model.specificationGroups[i].rows,
            ),
            if (i != model.specificationGroups.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      WalkaPdpSectionId.amazonTrust => const <Widget>[
          SizedBox(height: 14),
          WalkaPdpAmazonTrust(),
        ],
    };
  }
}
