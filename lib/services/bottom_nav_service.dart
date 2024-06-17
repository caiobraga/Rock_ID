import 'package:flutter/material.dart';

class BottomNavService extends ChangeNotifier {
  static final BottomNavService _instance = BottomNavService._internal();

  int _bottomNavIndex = 0;

  BottomNavService._internal();

  factory BottomNavService() {
    return _instance;
  }

  int get bottomNavIndex => _bottomNavIndex;

  void setIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }
}
