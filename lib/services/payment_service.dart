import 'package:flutter/material.dart';
import 'package:flutter_onboarding/constants.dart';
import 'package:flutter_onboarding/enums/localized_string.dart';
import 'package:flutter_onboarding/services/localization_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaymentService {
  static Future<bool> checkIfPurchased() async {
    bool isPurchased = false;
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      isPurchased = customerInfo.entitlements.active.isNotEmpty;
    });
    return isPurchased;
  }

  Future<void> configureSDK(
      BuildContext context, bool isFreeTrialEnabled) async {
    final localizationService =
        LocalizationService(Localizations.localeOf(context));

    if (await checkIfPurchased()) {
      await showToast(
          localizationService
              .getString(LocalizedString.youAreAlreadySubscribed),
          context);
      return;
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

      // debugPrint('Paywall result: $payWallResult');

      // if (payWallResult == PaywallResult.purchased ||
      //     payWallResult == PaywallResult.restored) {
      // } else if (payWallResult == PaywallResult.cancelled) {
      //   await showToast(localizationService
      //       .getString(LocalizedString.purchaseCancelledPleaseTryAgain), context);
      // } else if (payWallResult == PaywallResult.notPresented) {
      //   await showToast(
      //       localizationService.getString(LocalizedString.paywallNotPresented), context);
      // } else if (payWallResult == PaywallResult.error) {
      //   await showToast(
      //       localizationService.getString(LocalizedString.errorPleaseTryAgain), context);
      // } else {
      //   debugPrint('Result');
      // }
    } catch (e) {
      await showToast(
          localizationService.getString(LocalizedString.errorPleaseTryAgain),
          context);
    }
  }

  Future<void> showToast(String message, context) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }
}
