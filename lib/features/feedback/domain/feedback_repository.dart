import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';

abstract interface class FeedbackRepository {
  /// Whether the optional remote capability can currently support the UI.
  bool get isAvailable;

  Future<FeedbackSubmitResult> submitFeedback(FeedbackSubmission submission);

  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
    required String locale,
  });
}
