import 'package:flutter/foundation.dart';

class GameSettingProvider extends ChangeNotifier {
  int _sb = 100;
  int _ante = 0;
  int _minBuyin = 100;
  int _maxBuyin = 200;
  int _timebank = 30;

  int get sb => _sb;
  int get ante => _ante;
  int get minBuyin => _minBuyin;
  int get maxBuyin => _maxBuyin;
  int get timebank => _timebank;

  void updateSb(String value) {
    _sb = int.tryParse(value) ?? _sb;
    notifyListeners();
  }

  void updateAnte(String value) {
    _ante = int.tryParse(value) ?? _ante;
    notifyListeners();
  }

  void updateMinBuyin(String value) {
    _minBuyin = int.tryParse(value) ?? _minBuyin;
    notifyListeners();
  }

  void updateMaxBuyin(String value) {
    _maxBuyin = int.tryParse(value) ?? _maxBuyin;
    notifyListeners();
  }

  void updateTimebank(String value) {
    _timebank = int.tryParse(value) ?? _timebank;
    notifyListeners();
  }
}
