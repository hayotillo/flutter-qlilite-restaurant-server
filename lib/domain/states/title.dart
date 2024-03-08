import 'package:flutter/cupertino.dart';

class TitleState extends ChangeNotifier {
  final List<String> _titles = ['Home'];

  void add(String value, {int? index}) {
    if (index == 0) {
      _titles.clear();
    }
    final i = (index ?? 1)-1;
    if (i > 0 && _titles.length > i) {
      _titles[i] = value;
    } else {
      _titles.add(value);
    }
    notifyListeners();
  }

  String get title => _titles.join(' - ');
}