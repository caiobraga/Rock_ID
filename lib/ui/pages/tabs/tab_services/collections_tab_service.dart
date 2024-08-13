import 'package:flutter/material.dart';
import 'package:flutter_onboarding/db/db.dart';
import 'package:flutter_onboarding/models/rocks.dart';

class CollectionsTabService {
  CollectionsTabService._();

  static CollectionsTabService? _instance;

  static CollectionsTabService get instance {
    _instance ??= CollectionsTabService._();
    return _instance!;
  }

  final ValueNotifier<List<Rock>> collectionRocksNotifier = ValueNotifier([]);

  Future<void> loadCollectionRocks() async {
    try {
      collectionRocksNotifier.value.clear();
      List<Rock> collectionRocks = (await DatabaseHelper().findAllRocks())
          .where((element) => element.isAddedToCollection)
          .toList();
      collectionRocksNotifier.value = List.from(collectionRocks);
    } catch (e) {
      debugPrint('$e');
    }
  }
}
