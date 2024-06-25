import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/collection_image.dart';
import 'package:flutter_onboarding/models/rocks.dart';

import '../db/db.dart';
import '../models/collection.dart';

class AddRockToCollectionService {
  AddRockToCollectionService._();

  static AddRockToCollectionService? _instance;

  static AddRockToCollectionService get instance {
    _instance ??= AddRockToCollectionService._();
    return _instance!;
  }

  final TextEditingController numberController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final ValueNotifier<List<File>> photosNotifier = ValueNotifier([]);
  final ValueNotifier<String> unitOfMeasurementNotifier = ValueNotifier('inch');

  void toggleUnitOfMeasurement() {
    if (unitOfMeasurementNotifier.value == 'inch') {
      unitOfMeasurementNotifier.value = 'cm';
      return;
    }

    unitOfMeasurementNotifier.value = 'inch';
  }

  Future<void> addRockToCollection(Rock rock) async {
    final String number = numberController.text;
    final String name = nameController.text;
    final String description = notesController.text;
    final String dateAcquired = dateController.text;
    final double cost = double.tryParse(costController.text) ?? 0.0;
    final String locality = localityController.text;
    final double length = double.tryParse(lengthController.text) ?? 0.0;
    final double width = double.tryParse(widthController.text) ?? 0.0;
    final double height = double.tryParse(heightController.text) ?? 0.0;
    final String notes = notesController.text;
    final String unitOfMeasurement = unitOfMeasurementNotifier.value;
    final List<File> collectionImageFiles = photosNotifier.value;

    if (name.isNotEmpty) {
      try {
        List<CollectionImage> images = [];
        for (var element in collectionImageFiles) {
          images.add(CollectionImage(
            collectionId: 0,
            id: 0,
            image: await element.readAsBytes(),
          ));
        }
        Collection newCollection = Collection(
          collectionId: 0,
          collectionName: name,
          description: description,
          number: number,
          dateAcquired: dateAcquired,
          cost: cost,
          locality: locality,
          length: length,
          width: width,
          height: height,
          notes: notes,
          unitOfMeasurement: unitOfMeasurement,
          collectionImagesFiles: images,
        );

        await DatabaseHelper().insertCollection(newCollection);
      } catch (e) {
        debugPrint('$e');
      }

      return;
    }
  }
}
