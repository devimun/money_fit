abstract interface class FeedbackRepository {
  Future<void> submitReviewFeedback(String detail);

  Future<void> submitContactInquiry({
    required String inquiryType,
    required String email,
    required String details,
  });
}
