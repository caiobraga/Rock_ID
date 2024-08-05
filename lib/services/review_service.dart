import 'package:flutter/material.dart';
import 'package:flutter_onboarding/services/mix_panel_service.dart';
import 'package:in_app_review/in_app_review.dart';

class ReviewService {
  ReviewService._();

  static ReviewService? _instance;
  static ReviewService get instance {
    _instance ??= ReviewService._();
    return _instance!;
  }

  Future<void> getReview() async {
    try {
      final InAppReview inAppReview = InAppReview.instance;
      bool isReviewAvaliable = await inAppReview.isAvailable();
      if (isReviewAvaliable) {
        inAppReview.requestReview();
        await _trackValuationTool();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _trackValuationTool() async {
    final _mixpanel = await MixpanelService.init();
    _mixpanel.track("Valuation Tool");
  }
}
