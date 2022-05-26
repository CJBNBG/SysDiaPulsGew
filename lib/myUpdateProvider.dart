import 'package:flutter/foundation.dart';
import 'package:sysdiapulsgew/pages/EntriesPage/utils.dart';

// ----------------------------------------------------------------------------------------
// Provider für den Bildschirmaufbau
// ----------------------------------------------------------------------------------------
class myUpdateProvider with ChangeNotifier {
  int _counter = 0;

  myUpdateProvider() {
    _counter = 0;
  }

  int get counter => _counter;

  increment() async {
    _counter++;
    await ladeEintraege();
    await ladeEvents();
    print('myUpdateProvider - _counter: $_counter');
    notifyListeners();
  }
}
