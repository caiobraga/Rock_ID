import 'package:flutter/material.dart';

import '../main.dart';

class ShowSnackbarService {
  void showSnackBar(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}