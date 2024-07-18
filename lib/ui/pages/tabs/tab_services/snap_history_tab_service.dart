import 'package:flutter/material.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';

class SnapHistoryTabService {
  SnapHistoryTabService._();

  static SnapHistoryTabService? _instance;

  static SnapHistoryTabService get instance {
    _instance ??= SnapHistoryTabService._();
    return _instance!;
  }

  final ValueNotifier<List<Map<String, dynamic>>> snapHistoryNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<Rock>> snapHistoryRocksNotifier = ValueNotifier([]);

  Future<void> loadSnapHistory() async {
    try {
      //loading snap history
      snapHistoryNotifier.value.clear();
      List<Map<String, dynamic>> snapHistory =
          await DatabaseHelper().snapHistory();
      snapHistoryNotifier.value = List.from(snapHistory);

      //loading snap history rocks
      snapHistoryRocksNotifier.value.clear();
      final allDbRocks = await DatabaseHelper().findAllRocks();
      final List<Rock> allRocks = Rock.rockList;
      List<Rock> allRocksWithImages = [];

      for (Rock rock in allRocks) {
        final dbRock = allDbRocks.firstWhere(
          (element) => element.rockId == rock.rockId,
          orElse: Rock.empty,
        );

        if (dbRock.rockId != 0) {
          rock = dbRock;
        }

        allRocksWithImages.add(rock);
      }

      allRocksWithImages =
          await DatabaseHelper().incrementDefaultRockList(allRocksWithImages);
      snapHistoryRocksNotifier.value = List.from(allRocksWithImages);
    } catch (e) {
      debugPrint('$e');
    }
  }
}
