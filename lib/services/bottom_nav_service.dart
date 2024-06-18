import 'dart:async';

import 'package:flutter/material.dart';

class BottomNavService {
  BottomNavService._();

  static BottomNavService? _instance;

  static BottomNavService get instance {
    _instance ??= BottomNavService._();
    return _instance!;
  }

  final ValueNotifier<int> _bottomNavIndexNotifier = ValueNotifier<int>(0);
  final StreamController<String> _rockCollectionClickController =
      StreamController<String>.broadcast();

  int get bottomNavIndex => _bottomNavIndexNotifier.value;
  ValueNotifier<int> get bottomNavIndexNotifier => _bottomNavIndexNotifier;
  Stream<String> get rockCollectionClickStream =>
      _rockCollectionClickController.stream;

  void setIndex(int index) {
    _bottomNavIndexNotifier.value = index;
  }

  void rockCollectionClicked() {
    _rockCollectionClickController.add('rock_collection');
  }

  void dispose() {
    _rockCollectionClickController.close();
  }
}
