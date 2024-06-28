import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'camera_tip_modal.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final int maxWidth = 1920;
  final int maxHeight = 1080;
  final int maxFileSizeInBytes = 5 * 1024 * 1024; // 5 MB

  Future<File?> pickImageFromCamera(BuildContext context) async {
    await CameraTipModalService().show(context);
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File tempImage = File(pickedFile.path);
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String appDirPath = appDir.path;
      final String fileName = basename(pickedFile.path);
      final String savedImagePath = join(appDirPath, fileName);

      final File savedImage = await tempImage.copy(savedImagePath);
      return savedImage;
    }
    return null;
  }

  Future<File?> pickImageFromGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File tempImage = File(pickedFile.path);
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String appDirPath = appDir.path;
      final String fileName = basename(pickedFile.path);
      final String savedImagePath = join(appDirPath, fileName);

      final File savedImage = await tempImage.copy(savedImagePath);
      return savedImage;
    }
    return null;
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.blackColor,
          surfaceTintColor: Colors.transparent,
          title: const Text(
            'Error',
            style: TextStyle(color: Constants.lightestRed),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Constants.white),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              style: TextButton.styleFrom(
                foregroundColor: Constants.darkGrey,
                backgroundColor: Constants.primaryColor,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
