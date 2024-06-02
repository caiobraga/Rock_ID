import 'package:flutter/foundation.dart';

class BottomNavService extends ChangeNotifier {
  // Singleton instance
  static final BottomNavService _instance = BottomNavService._internal();

  // Private constructor
  BottomNavService._internal();

  // Factory constructor to return the same instance
  factory BottomNavService() {
    return _instance;
  }

  int _bottomNavIndex = 0;

  int get bottomNavIndex => _bottomNavIndex;

  void setIndex(int newIndex) {
    _bottomNavIndex = newIndex;
    notifyListeners();
  }
}
