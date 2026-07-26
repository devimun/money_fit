import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/feedback/application/review_prompt_dependencies.dart';
import 'package:money_fit/features/feedback/application/review_prompt_flow.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';

void main() {
  final now = DateTime.utc(2026, 7, 26, 12);

  test('does not present a review on the first run', () async {
    final presenter = _FakePresenter();
    final flow = _flow(now: now, presenter: presenter);

    await flow.maybePromptReview();

    expect(presenter.experienceRequests, 0);
  });

  test(
    'launches the store and opts out after a positive review action',
    () async {
      final preferences = _FakePreferences(
        firstRunAt: now.subtract(const Duration(days: 3)),
      );
      final presenter = _FakePresenter(
        experience: BinaryExperience.good,
        positiveAction: PositiveAction.reviewNow,
      );
      final launcher = _FakeStoreLauncher();
      final flow = _flow(
        now: now,
        preferences: preferences,
        presenter: presenter,
        launcher: launcher,
      );

      await flow.maybePromptReview();

      expect(launcher.launches, 1);
      expect(preferences.optedOut, isTrue);
      expect(preferences.promptedAt, now);
    },
  );

  test(
    'submits negative feedback through the repository and thanks the user',
    () async {
      final preferences = _FakePreferences(
        firstRunAt: now.subtract(const Duration(days: 3)),
      );
      final presenter = _FakePresenter(
        experience: BinaryExperience.bad,
        negativeResult: const NegativeResult(
          NegativeAction.send,
          'Needs export',
        ),
      );
      final feedback = _FakeFeedbackRepository();
      final flow = _flow(
        now: now,
        preferences: preferences,
        presenter: presenter,
        feedback: feedback,
      );

      await flow.maybePromptReview();

      expect(feedback.reviewDetails, ['Needs export']);
      expect(presenter.thanksShown, 1);
    },
  );

  test(
    'contact inquiry codes are stable independently of localized labels',
    () {
      expect(ContactInquiryType.bugReport.backendCode, 'bug_report');
      expect(
        ContactInquiryType.featureSuggestion.backendCode,
        'feature_suggestion',
      );
      expect(ContactInquiryType.generalInquiry.backendCode, 'general_inquiry');
      expect(ContactInquiryType.other.backendCode, 'other');
    },
  );
}

ReviewPromptFlow _flow({
  required DateTime now,
  _FakePreferences? preferences,
  _FakePresenter? presenter,
  _FakeStoreLauncher? launcher,
  _FakeFeedbackRepository? feedback,
}) => ReviewPromptFlow(
  feedback: feedback ?? _FakeFeedbackRepository(),
  preferences: preferences ?? _FakePreferences(),
  presenter: presenter ?? _FakePresenter(),
  reviewStoreLauncher: launcher ?? _FakeStoreLauncher(),
  now: () => now,
);

class _FakePreferences implements ReviewPromptPreferences {
  _FakePreferences({this.firstRunAt});

  DateTime? firstRunAt;
  bool optedOut = false;
  DateTime? snoozeUntil;
  DateTime? promptedAt;

  @override
  Future<DateTime?> readFirstRunAt() async => firstRunAt;
  @override
  Future<bool> readOptedOut() async => optedOut;
  @override
  Future<DateTime?> readSnoozeUntil() async => snoozeUntil;
  @override
  Future<void> writeFirstRunAt(DateTime value) async => firstRunAt = value;
  @override
  Future<void> writeOptedOut(bool value) async => optedOut = value;
  @override
  Future<void> writeSnoozeUntil(DateTime value) async => snoozeUntil = value;
  @override
  Future<void> markPrompted(DateTime value) async => promptedAt = value;
}

class _FakePresenter implements ReviewPromptPresenter {
  _FakePresenter({this.experience, this.positiveAction, this.negativeResult});

  final BinaryExperience? experience;
  final PositiveAction? positiveAction;
  final NegativeResult? negativeResult;
  int experienceRequests = 0;
  int thanksShown = 0;

  @override
  Future<BinaryExperience?> askExperience() async {
    experienceRequests++;
    return experience;
  }

  @override
  Future<PositiveAction?> askForReview() async => positiveAction;
  @override
  Future<NegativeResult?> collectNegativeFeedback() async => negativeResult;
  @override
  Future<void> showThanks() async => thanksShown++;
}

class _FakeStoreLauncher implements ReviewStoreLauncher {
  int launches = 0;
  @override
  Future<void> launch() async => launches++;
}

class _FakeFeedbackRepository implements FeedbackRepository {
  final reviewDetails = <String>[];
  @override
  Future<void> submitReviewFeedback(String detail) async =>
      reviewDetails.add(detail);
  @override
  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
  }) async {}
}
