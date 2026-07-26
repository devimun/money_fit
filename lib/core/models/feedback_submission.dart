enum FeedbackSource { reviewNegative, proactivePrompt }

extension FeedbackSourceWire on FeedbackSource {
  String get wire => switch (this) {
    FeedbackSource.reviewNegative => 'review_negative',
    FeedbackSource.proactivePrompt => 'proactive_prompt',
  };
}

class FeedbackSubmission {
  const FeedbackSubmission({
    required this.detail,
    required this.source,
    required this.clientSubmissionId,
    required this.locale,
  });
  final String detail;
  final FeedbackSource source;
  final String clientSubmissionId;
  final String locale;
}
