import 'package:flutter/material.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';

class LovedTabService {
  LovedTabService._();

  static LovedTabService? _instance;

  static LovedTabService get instance {
    _instance ??= LovedTabService._();
    return _instance!;
  }

  final ValueNotifier<List<Rock>> lovedRocksNotifier = ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> lovedRocksMapNotifier =
      ValueNotifier([]);

  Future<void> loadLovedRocks() async {
    try {
      lovedRocksNotifier.value.clear();
      final allDbRocks = await DatabaseHelper().findAllRocks();
      List<Map<String, dynamic>> wishlistRocksMap =
          await DatabaseHelper().wishlist();
      lovedRocksMapNotifier.value.clear();
      lovedRocksMapNotifier.value.addAll(wishlistRocksMap);
      for (final wishlistRock in wishlistRocksMap) {
        Rock? rock = await Rock.rockListFirstWhere(wishlistRock['rockId']);
        final dbRock = allDbRocks.firstWhere(
          (element) => element.rockId == rock?.rockId,
          orElse: Rock.empty,
        );

        if (dbRock.rockId != 0) {
          rock = dbRock;
        }
        if (rock != null) {
          lovedRocksNotifier.value.add(rock);
        }
      }

      lovedRocksNotifier.value = List.from(lovedRocksNotifier.value);
      lovedRocksMapNotifier.value = List.from(lovedRocksMapNotifier.value);
    } catch (e) {
      debugPrint('$e');
    }
  }
}
