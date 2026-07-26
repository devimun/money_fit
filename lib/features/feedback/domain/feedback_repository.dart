import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';

abstract interface class FeedbackRepository {
  Future<void> submitReviewFeedback(String detail);

  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
  });
}
