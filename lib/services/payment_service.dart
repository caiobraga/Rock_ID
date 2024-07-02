import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../constants.dart';

class PaymentService{
  Future<bool> _checkIfPurchased() async {
    bool isPurchased = false;
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      isPurchased = customerInfo.entitlements.active.isNotEmpty;
    });
    return isPurchased;
  }

//AppLocalizations.of(context)!.paymentsAreChargedToThe,
  Future<void> _configureSDK() async {
    if (await _checkIfPurchased()) {
      await showToast(AppLocalizations.of(context)!.youAreAlreadySubscribed);
      return;
    }
    try {
      await Purchases.setLogLevel(LogLevel.debug);
      PurchasesConfiguration configuration = PurchasesConfiguration(Constants.revenueCatKey);
      await Purchases.configure(configuration);

      PaywallResult payWallResult = await RevenueCatUI.presentPaywallIfNeeded('monthly subscription');

      if (payWallResult == PaywallResult.purchased || payWallResult == PaywallResult.restored) {

      } else if (payWallResult == PaywallResult.cancelled) {
        await showToast(AppLocalizations.of(context)!.purchaseCancelledPleaseTryAgain);
      } else if (payWallResult == PaywallResult.notPresented) {
        await showToast(AppLocalizations.of(context)!.paywallNotPresented);
      } else if (payWallResult == PaywallResult.error) {
        await showToast(AppLocalizations.of(context)!.errorPleaseTryAgain);
      }
    } catch (e) {
      await showToast(AppLocalizations.of(context)!.errorPleaseTryAgain);
    }
  }
}