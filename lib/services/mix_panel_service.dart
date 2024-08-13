import 'package:flutter_onboarding/constants.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelService {
  static Mixpanel? _instance;

  static Future<Mixpanel> init() async {
    if (_instance == null) {
      _instance = await Mixpanel.init(Constants.mixPanelKey,
          optOutTrackingDefault: false, trackAutomaticEvents: true);
      _instance?.setLoggingEnabled(true);
    }
    return _instance!;
  }
}
