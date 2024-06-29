
import 'package:in_app_review/in_app_review.dart';

class ReviewService {
  void getReview() async {
    final InAppReview inAppReview = InAppReview.instance;
    bool isReviewAvaliable = await inAppReview.isAvailable();
    if (isReviewAvaliable) {
      inAppReview.requestReview();
    }
  }
}