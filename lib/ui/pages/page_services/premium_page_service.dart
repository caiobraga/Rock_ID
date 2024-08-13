import 'package:flutter/material.dart';

class PremiumPageService {
  PremiumPageService._();

  static PremiumPageService? _instance;

  static PremiumPageService get instance {
    _instance ??= PremiumPageService._();
    return _instance!;
  }

  final ValueNotifier<bool> isFreeTrialEnabledNotifier = ValueNotifier(true);

  void setFreeTrial(bool value) {
    isFreeTrialEnabledNotifier.value = value;
  }
}
