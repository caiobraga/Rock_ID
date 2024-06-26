import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

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
      final File file = File(pickedFile.path);
      if (await _validateImage(file)) {
        return file;
      } else {
        _showErrorDialog(context, 'Image is too large.');
      }
    }
    return null;
  }

  Future<File?> pickImageFromGallery(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      if (await _validateImage(file)) {
        return file;
      } else {
        _showErrorDialog(context, 'Image is too large.');
      }
    }
    return null;
  }

  Future<bool> _validateImage(File file) async {
    final Uint8List bytes = await file.readAsBytes();
    if (bytes.length > maxFileSizeInBytes) {
      return false;
    }

    final img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      return false;
    }

    if (image.width > maxWidth || image.height > maxHeight) {
      return false;
    }

    return true;
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
