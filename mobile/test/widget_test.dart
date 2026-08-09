import 'package:flutter_test/flutter_test.dart';
import 'package:walka/design_system/walka_theme.dart';
import 'package:walka/main.dart';
import 'package:walka/screens/walka_screens.dart';

void main() {
  test('WALKA foundation exposes the application entry point', () {
    expect(const WalkaApp(), isA<WalkaApp>());
    expect(const SplashScreen(), isA<SplashScreen>());
    expect(const WalkaShell(), isA<WalkaShell>());
  });

  test('WALKA design system keeps the approved brand colors', () {
    expect(WalkaColors.navy.toARGB32(), 0xFF003366);
    expect(WalkaColors.gold.toARGB32(), 0xFFD4AF37);
    expect(buildWalkaTheme().useMaterial3, isTrue);
  });
}
