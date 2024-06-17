import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';

import '../main.dart';

class ShowSnackbarService {
  void showSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppCollors.darkestRed,
      ),
    );
  }
}