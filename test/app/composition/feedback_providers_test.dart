import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/composition/feedback_providers.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';

void main() {
  test(
    'feedback provider does not access Supabase before optional startup',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      const submission = FeedbackSubmission(
        detail: 'Please add CSV export.',
        source: FeedbackSource.proactivePrompt,
        clientSubmissionId: '00000000-0000-4000-8000-000000000001',
        locale: 'en',
      );

      final result = await container
          .read(feedbackRepositoryProvider)
          .submitFeedback(submission);

      expect(result, isA<FeedbackSubmitFailure>());
      expect(
        (result as FeedbackSubmitFailure).reason,
        FeedbackSubmissionFailure.unavailable,
      );
    },
  );
}
