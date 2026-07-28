import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/feedback/data/capability_aware_feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';

void main() {
  const submission = FeedbackSubmission(
    detail: 'Please add CSV export.',
    source: FeedbackSource.proactivePrompt,
    clientSubmissionId: '00000000-0000-4000-8000-000000000001',
    locale: 'en',
  );

  test(
    'returns a retryable local failure while the capability is unavailable',
    () async {
      final repository = CapabilityAwareFeedbackRepository(
        currentRepository: () => null,
      );

      final result = await repository.submitFeedback(submission);

      expect(result, isA<FeedbackSubmitFailure>());
      expect(
        (result as FeedbackSubmitFailure).reason,
        FeedbackSubmissionFailure.unavailable,
      );
      await expectLater(
        repository.submitContactInquiry(
          inquiryType: ContactInquiryType.generalInquiry,
          email: '',
          details: 'Please help.',
          locale: 'en',
        ),
        throwsA(isA<FeedbackRepositoryUnavailable>()),
      );
    },
  );

  test('uses the remote implementation when it becomes available', () async {
    final remote = _RecordingRepository();
    FeedbackRepository? current;
    final repository = CapabilityAwareFeedbackRepository(
      currentRepository: () => current,
    );

    expect(
      (await repository.submitFeedback(submission) as FeedbackSubmitFailure)
          .reason,
      FeedbackSubmissionFailure.unavailable,
    );

    current = remote;
    expect(
      await repository.submitFeedback(submission),
      isA<FeedbackSubmitSuccess>(),
    );
    expect(remote.feedbackAttempts, 1);
  });
}

class _RecordingRepository implements FeedbackRepository {
  var feedbackAttempts = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<FeedbackSubmitResult> submitFeedback(FeedbackSubmission submission) {
    feedbackAttempts += 1;
    return Future.value(const FeedbackSubmitSuccess());
  }

  @override
  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
    required String locale,
  }) async {}
}
