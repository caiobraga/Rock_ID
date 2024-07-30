import 'dart:ui';

import 'package:flutter_onboarding/enums/localized_string.dart';

class LocalizationService {
  final Locale locale;

  LocalizationService(this.locale);

  static final Map<String, Map<LocalizedString, String>> _localizedValues = {
    'en': {
      LocalizedString.youAreAlreadySubscribed: 'You are already subscribed',
      LocalizedString.purchaseCancelledPleaseTryAgain: 'Purchase cancelled, please try again',
      LocalizedString.paywallNotPresented: 'Paywall not presented',
      LocalizedString.errorPleaseTryAgain: 'Error, please try again',
      LocalizedString.purchaseSuccessful: 'Purchase successful',
    },
  };

  String getString(LocalizedString key) {
    return _localizedValues[locale.languageCode]![key]!;
  }
}
