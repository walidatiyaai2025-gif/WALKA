import 'package:flutter/material.dart';

import '../../../../design_system/walka_shell.dart';
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
            children: <Widget>[
              gallery,
              const SizedBox(height: 18),
              WalkaPdpIdentity(
                eyebrow: model.eyebrow,
                title: model.title,
                facts: model.factsLine,
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 16),
              variantSelector,
              if (model.showLunchUsage) ...const <Widget>[
                SizedBox(height: 18),
                WalkaPdpUsagePanel(),
              ],
              const SizedBox(height: 24),
              WalkaPdpFactsList(items: model.facts),
              const SizedBox(height: 24),
              WalkaPdpEditorialPanel(
                title: editorialTitle,
                body: editorialBody,
              ),
              const SizedBox(height: 14),
              for (int i = 0; i < model.specificationGroups.length; i++) ...<Widget>[
                WalkaPdpSpecificationTable(
                  title: model.specificationGroups[i].title,
                  rows: model.specificationGroups[i].rows,
                ),
                if (i != model.specificationGroups.length - 1)
                  const SizedBox(height: 10),
              ],
              const SizedBox(height: 14),
              const WalkaPdpAmazonTrust(),
            ],
          ),
        ),
      ),
    );
  }
}
