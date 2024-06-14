class BottomNavService {
  static final BottomNavService _instance = BottomNavService._internal();

  int bottomNavIndex = 0;

  factory BottomNavService() {
    return _instance;
  }

  BottomNavService._internal();

  void setIndex(int index) {
    bottomNavIndex = index;
  }
}
