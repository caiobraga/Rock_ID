import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/enums/localized_string.dart';
import 'package:flutter_onboarding/services/localization_service.dart';
import 'package:flutter_onboarding/services/mix_panel_service.dart';
import 'package:flutter_onboarding/ui/pages/page_services/root_page_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaymentService {
  static Future<bool> checkIfPurchased() async {
    try {
      PurchasesConfiguration configuration =
          PurchasesConfiguration(Constants.revenueCatKey);
      await Purchases.configure(configuration);
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.activeSubscriptions.isNotEmpty;
    } catch (e) {
      debugPrint("Error: $e");
      return false;
    }
  }

  Future<bool> configureSDK(
      BuildContext context, bool isFreeTrialEnabled) async {
    final _mixpanel = await MixpanelService.init();
    final localizationService =
        LocalizationService(Localizations.localeOf(context));

    if (await checkIfPurchased()) {
      debugPrint("You are already subscribed");
      await showToast(
          localizationService
              .getString(LocalizedString.youAreAlreadySubscribed),
          context);
      return false;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);
      PurchasesConfiguration configuration =
          PurchasesConfiguration(Constants.revenueCatKey);
      await Purchases.configure(configuration);
      final offerings = await Purchases.getOfferings();

      Package package;

      if (isFreeTrialEnabled) {
        package = offerings.current!.availablePackages.firstWhere(
            (element) => element.identifier == Constants.freeTrialPackage);
      } else {
        package = offerings.current!.availablePackages.firstWhere(
            (element) => element.identifier == Constants.annualPackage);
      }
      await Purchases.purchasePackage(package);
      await RootPageService.instance.evaluateIsPremiumActivated();
      _mixpanel.track("Subscription Purchased");
      return true;
    } catch (e) {
      debugPrint("Error: $e");
      await showToast(
          localizationService.getString(LocalizedString.errorPleaseTryAgain),
          context);
      return false;
    }
  }

  Future<void> showToast(String message, context) async {
    debugPrint("Message: $message");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
