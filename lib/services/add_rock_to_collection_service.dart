import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/models/rock_image.dart';
import 'package:flutter_onboarding/models/rocks.dart';
import 'package:intl/intl.dart';

import '../db/db.dart';

class AddRockToCollectionService {
  AddRockToCollectionService._();

  static AddRockToCollectionService? _instance;

  static AddRockToCollectionService get instance {
    _instance ??= AddRockToCollectionService._();
    return _instance!;
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController localityController = TextEditingController();
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final ValueNotifier<String> unitOfMeasurementNotifier = ValueNotifier('inch');
  final ValueNotifier<String?> imageNotifier = ValueNotifier(null);

  void setRockData(Rock rock, File? pickedImage) {
    nameController.text = rock.rockName;
    dateController.text = rock.dateAcquired.isEmpty
        ? DateFormat('yyyy/MM/dd').format(DateTime.now().toLocal()).toString()
        : rock.dateAcquired;
    costController.text = NumberFormat.currency(
      symbol: '',
      decimalDigits: 0,
    ).format(rock.cost);
    lengthController.text = rock.length.toString();
    widthController.text = rock.width.toString();
    heightController.text = rock.height.toString();
    localityController.text = rock.locality;
    notesController.text == rock.notes;
    unitOfMeasurementNotifier.value =
        rock.unitOfMeasurement.isEmpty ? 'inch' : rock.unitOfMeasurement;
    imageNotifier.value = pickedImage?.path;
  }

  void toggleUnitOfMeasurement() {
    if (unitOfMeasurementNotifier.value == 'inch') {
      unitOfMeasurementNotifier.value = 'cm';
      return;
    }

    unitOfMeasurementNotifier.value = 'inch';
  }

  Future<void> addRockToCollection(Rock rock) async {
    final String name = nameController.text;
    final String description = notesController.text;
    final String dateAcquired = dateController.text;
    final double cost = double.tryParse(
          costController.text.replaceAll(RegExp(r'[^\d.]'), ''),
        ) ??
        0.0;
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
      if (rock.rockImages.isNotEmpty &&
          !(await DatabaseHelper()
              .imageExistsLoved(rock.rockImages.first.imagePath!)) &&
          !(await DatabaseHelper()
              .imageExistsSnapHistory(rock.rockImages.first.imagePath!))) {
        final file = File(rock.rockImages.first.imagePath!);
        await file.delete();
      }

      final newRockImage = RockImage(
        id: 0,
        rockId: rock.rockId,
        imagePath: imageNotifier.value,
      );

      rockImages.add(newRockImage);
      newRock = newRock.copyWith(rockImages: rockImages);
    }

    try {
      if (await DatabaseHelper().rockExists(rock)) {
        await DatabaseHelper().editRock(newRock);
        return;
      }

      await DatabaseHelper().insertRock(newRock);

      final numberOfRocksSaved = await DatabaseHelper().getNumberOfRocksSaved();
      final storage = Storage.instance;
      final userHistory = jsonDecode((await storage.read(key: 'userHistory'))!);

      if (numberOfRocksSaved != null) {
        switch (numberOfRocksSaved) {
          case 1:
            if (!userHistory['firstRockSaved']) {
              await _requestReview();
              userHistory['firstRockSaved'] = true;
              await storage.write(
                key: 'userHistory',
                value: jsonEncode(userHistory),
              );
            }
            break;

          case 10:
            if (!userHistory['tenthRockSaved']) {
              userHistory['tenthRockSaved'] = true;
              await _requestReview();
              await storage.write(
                key: 'tenthRockSaved',
                value: userHistory,
              );
            }
            break;

          default:
            break;
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _requestReview() async {
    // final inAppReview = InAppReview.instance;
    // if (await inAppReview.isAvailable()) {
    //   inAppReview.requestReview();
    // }
  }
}
