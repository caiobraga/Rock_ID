class BottomNavService {
  BottomNavService._();

  static BottomNavService? _instance;

  static BottomNavService get instance {
    _instance ??= BottomNavService._();
    return _instance!;
  }

  int _bottomNavIndex = 0;

  int get bottomNavIndex => _bottomNavIndex;

  void setIndex(int newIndex) {
    _bottomNavIndex = newIndex;
  }
}
