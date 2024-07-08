import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:intl/intl.dart';

class HomePageService {
  HomePageService._();

  static HomePageService? _instance;

  static HomePageService get instance {
    _instance ??= HomePageService._();
    return _instance!;
  }

  final _storage = Storage.instance;
  final ValueNotifier<int> totalScannedRocksNotifier = ValueNotifier(0);
  final ValueNotifier<String> totalRockCollectionPriceNotifier =
      ValueNotifier('\$0');

  Future<void> notifyTotalValues() async {
    final rockList = await DatabaseHelper().findAllRocks();
    double totalPrice = 0;
    for (final rock in rockList) {
      totalPrice += rock.cost;
    }
    totalRockCollectionPriceNotifier.value =
        NumberFormat.currency(symbol: '\$', decimalDigits: 0)
            .format(totalPrice);

    final userHistory = await _storage.read(key: 'userHistory');
    totalScannedRocksNotifier.value =
        jsonDecode(userHistory!)['numberOfRocksScanned'];
  }
}
