import 'package:flutter/material.dart';
import 'package:flutter_onboarding/services/payment_service.dart';

class RootPageService {
  RootPageService._();

  static RootPageService? _instance;
  static RootPageService get instance {
    _instance ??= RootPageService._();
    return _instance!;
  }

  ValueNotifier<bool> isPremiumActivatedNotifier = ValueNotifier(false);

  Future<void> evaluateIsPremiumActivated() async {
    isPremiumActivatedNotifier.value = await PaymentService.checkIfPurchased();
  }
}
