import 'package:flutter/material.dart';
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
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
