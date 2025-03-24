import 'package:flutter/cupertino.dart';

class Obsdata with ChangeNotifier {
  String _obsid = 'val';

  Map _data = {};

  String get obsid => _obsid;

  Map get data => _data;

  set obsid(String val) {
    _obsid = val;
    notifyListeners();
  }

  set data(Map val) {
    _data = val;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
  }
}
