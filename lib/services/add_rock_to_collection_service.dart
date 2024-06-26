import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/models/rock_image.dart';
import 'package:flutter_onboarding/models/rocks.dart';

import '../db/db.dart';

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
  final ValueNotifier<Uint8List?> imageNotifier = ValueNotifier(null);

  void setRockData(Rock rock) {
    numberController.text = rock.number;
    nameController.text = rock.rockName;
    dateController.text = rock.dateAcquired;
    costController.text = rock.cost.toString();
    lengthController.text = rock.length.toString();
    widthController.text = rock.width.toString();
    heightController.text = rock.height.toString();
    notesController.text == rock.notes;
  }

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
    final List<RockImage> rockImages = [];

    Rock newRock = rock.copyWith(
      rockName: name,
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
    );

    if (imageNotifier.value != null) {
      final newRockImage = RockImage(
        id: 0,
        rockId: rock.rockId,
        image: imageNotifier.value,
      );

      rockImages.add(newRockImage);

      newRock = newRock.copyWith(rockImages: rockImages);
    }

    try {
      await DatabaseHelper().insertRock(newRock);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
