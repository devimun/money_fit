import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/platform/analytics_event.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';
import 'package:money_fit/features/feedback/presentation/contact_us_dialog.dart';
import 'package:money_fit/features/feedback/presentation/feedback_prompt_dialog.dart';
import 'package:money_fit/features/feedback/presentation/review/negative_feedback_dialog.dart';
import 'package:money_fit/l10n/app_localizations.dart';

void main() {
  testWidgets('feedback keeps its draft and retries after a failed send', (
    tester,
  ) async {
    final repository = _RetryingFeedbackRepository();
    final analytics = _RecordingAnalyticsTracker();
    await tester.pumpWidget(
      _testApp(
        FeedbackPromptDialog(
          repository: repository,
          submission: _submission,
          analytics: analytics,
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'Keep this feedback for a retry.',
    );
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(repository.feedbackAttempts, 1);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Keep this feedback for a retry.',
    );
    expect(
      find.text(
        'We couldn’t send it. Your text is still here—please try again.',
      ),
      findsOneWidget,
    );
    expect(analytics.events, hasLength(1));
    expect(
      analytics.events.single.name,
      AnalyticsEvent.feedbackSubmissionFailed.canonicalName,
    );
    expect(analytics.events.single.parameters, {
      'source': 'proactive_prompt',
      'error_category': 'unavailable',
      'attempt_count_bucket': 'first',
    });

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(repository.feedbackAttempts, 2);
    expect(
      analytics.events.last.name,
      AnalyticsEvent.feedbackSubmitted.canonicalName,
    );
    expect(analytics.events.last.parameters, {
      'source': 'proactive_prompt',
      'length_bucket': '11_100',
      'attempt_count_bucket': 'retry',
    });
  });

  testWidgets(
    'contact keeps entered values and can retry after a failed send',
    (tester) async {
      final repository = _RetryingFeedbackRepository();
      final analytics = _RecordingAnalyticsTracker();
      await tester.pumpWidget(
        _testApp(ContactUsDialog(repository: repository, analytics: analytics)),
      );

      await tester.tap(
        find.byType(DropdownButtonFormField<ContactInquiryType>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bug Report').last);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'person@example.com',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'The app did not save my update.',
      );

      final submit = find.byType(ElevatedButton);
      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pump();

      expect(repository.contactAttempts, 1);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(0))
            .controller!
            .text,
        'person@example.com',
      );
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(1))
            .controller!
            .text,
        'The app did not save my update.',
      );
      expect(find.text('Failed to submit your inquiry.'), findsOneWidget);
      expect(analytics.events, hasLength(1));
      expect(
        analytics.events.single.name,
        AnalyticsEvent.inquirySubmitted.canonicalName,
      );
      expect(analytics.events.single.parameters, {
        'inquiry_type': 'bug_report',
        'result': 'failure',
      });

      await tester.ensureVisible(submit);
      await tester.tap(submit);
      await tester.pumpAndSettle();

      expect(repository.contactAttempts, 2);
      expect(
        analytics.events.last.name,
        AnalyticsEvent.inquirySubmitted.canonicalName,
      );
      expect(analytics.events.last.parameters, {
        'inquiry_type': 'bug_report',
        'result': 'success',
      });
    },
  );

  testWidgets('negative feedback uses localized errors and preserves retries', (
    tester,
  ) async {
    final repository = _RetryingFeedbackRepository();
    await tester.pumpWidget(
      _testApp(
        NegativeFeedbackDialog(
          submission: _submission,
          submit: repository.submitFeedback,
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(find.text('Please enter at least 3 characters.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Keep this feedback.');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(repository.feedbackAttempts, 1);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Keep this feedback.',
    );
    expect(
      find.text(
        'We couldn’t send it. Your text is still here—please try again.',
      ),
      findsOneWidget,
    );
  });
}

const _submission = FeedbackSubmission(
  detail: '',
  source: FeedbackSource.proactivePrompt,
  clientSubmissionId: '00000000-0000-4000-8000-000000000001',
  locale: 'en',
);

Widget _testApp(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

class _RetryingFeedbackRepository implements FeedbackRepository {
  var feedbackAttempts = 0;
  var contactAttempts = 0;

  @override
  bool get isAvailable => true;

  @override
  Future<FeedbackSubmitResult> submitFeedback(FeedbackSubmission submission) {
    feedbackAttempts += 1;
    return Future.value(
      feedbackAttempts == 1
          ? const FeedbackSubmitFailure(FeedbackSubmissionFailure.unavailable)
          : const FeedbackSubmitSuccess(),
    );
  }

  @override
  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
    required String locale,
  }) async {
    contactAttempts += 1;
    if (contactAttempts == 1) throw StateError('Supabase unavailable');
  }
}

class _RecordingAnalyticsTracker implements AnalyticsTracker {
  final events = <({String name, Map<String, Object> parameters})>[];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> reset() async {}

  @override
  Future<void> setAmplitudeCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> track(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> trackScreenView({
    required String screenName,
    String? previousScreenName,
    required String navigationType,
  }) async {}
}
