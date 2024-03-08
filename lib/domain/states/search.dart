import 'package:flutter/cupertino.dart';

class SearchState extends ChangeNotifier {
  static final Map<String, Function(String)> _callbacks = {};

  void setCallback(String name, Function(String) callback) {
    _callbacks.putIfAbsent(name, ()=>callback);
    notifyListeners();
  }

  Function(String) getCallback(String name) {
    return _callbacks[name] ?? (s){};
  }
}