import 'package:flutter/foundation.dart';

import 'walka_shell_destination.dart';

/// Typed shell selection state. Feature code selects named destinations while
/// scaffold widgets decide how that selection is presented.
class WalkaShellController extends ChangeNotifier {
  WalkaShellController({
    WalkaShellDestination initialDestination = WalkaShellDestination.home,
  }) : _destination = initialDestination;

  WalkaShellDestination _destination;

  WalkaShellDestination get destination => _destination;
  int get selectedIndex => _destination.index;

  bool select(WalkaShellDestination destination) {
    if (_destination == destination) return false;
    _destination = destination;
    notifyListeners();
    return true;
  }

  bool selectIndex(int index) => select(WalkaShellDestination.fromIndex(index));
}
