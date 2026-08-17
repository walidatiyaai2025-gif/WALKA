import 'package:flutter/material.dart';

import 'information_v102.dart';

/// Compatibility layer for intermediate UI-009 code.
///
/// Current content is rendered by V102 from published remote/LKG CMS state.
/// V100 symbols remain only so earlier team screens continue to compile.
class WalkaAccountV100 extends StatelessWidget {
  const WalkaAccountV100({super.key});

  @override
  Widget build(BuildContext context) => const WalkaAccountV102();
}

class WalkaContactV100 extends StatelessWidget {
  const WalkaContactV100({super.key});

  @override
  Widget build(BuildContext context) => const WalkaContactV102();
}

class WalkaFaqV100 extends StatelessWidget {
  const WalkaFaqV100({super.key});

  @override
  Widget build(BuildContext context) => const WalkaFaqV102();
}

enum WalkaLegalType { privacy, terms }

class WalkaLegalV100 extends StatelessWidget {
  const WalkaLegalV100({required this.type, super.key});

  final WalkaLegalType type;

  @override
  Widget build(BuildContext context) {
    return WalkaLegalV102(
      type: type == WalkaLegalType.privacy
          ? WalkaLegalTypeV102.privacy
          : WalkaLegalTypeV102.terms,
    );
  }
}

class WalkaAmazonStoreV100 extends StatelessWidget {
  const WalkaAmazonStoreV100({super.key});

  @override
  Widget build(BuildContext context) => const WalkaAmazonStoreV102();
}

class WalkaSocialV100 extends StatelessWidget {
  const WalkaSocialV100({super.key});

  @override
  Widget build(BuildContext context) => const WalkaSocialV102();
}

class WalkaAppInfoV100 extends StatelessWidget {
  const WalkaAppInfoV100({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Icon(Icons.info_outline_rounded)),
      );
}
