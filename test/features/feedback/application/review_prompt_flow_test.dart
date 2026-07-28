import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/feedback/application/review_prompt_dependencies.dart';
import 'package:money_fit/features/feedback/application/review_prompt_flow.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';

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

  test('persisted engagement cooldown remains 30 days by default', () async {
    final presenter = _FakePresenter();
    final flow = _flow(
      now: now,
      preferences: _FakePreferences(
        firstRunAt: now.subtract(const Duration(days: 3)),
        engagementPromptAt: now.subtract(const Duration(minutes: 5)),
      ),
      presenter: presenter,
    );

    expect(await flow.isEligible, isFalse);
    await flow.maybePromptReview();
    expect(presenter.experienceRequests, 0);
  });

  test('review uses the short fullscreen quiet period independently', () async {
    var current = now;
    final coordinator = PromptCoordinator(now: () => current);
    final activeFeedback = coordinator.tryAcquire(
      PromptSurface.productFeedback,
    )!;
    activeFeedback.release();
    final presenter = _FakePresenter();
    final flow = _flow(
      clock: () => current,
      preferences: _FakePreferences(
        firstRunAt: current.subtract(const Duration(days: 3)),
      ),
      presenter: presenter,
      promptCoordinator: coordinator,
      quietPeriod: const Duration(seconds: 120),
    );

    await flow.maybePromptReview();
    expect(presenter.experienceRequests, 0);

    current = current.add(const Duration(seconds: 120));
    await flow.maybePromptReview();
    expect(presenter.experienceRequests, 1);
  });

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
  DateTime? now,
  DateTime Function()? clock,
  _FakePreferences? preferences,
  _FakePresenter? presenter,
  _FakeStoreLauncher? launcher,
  _FakeFeedbackRepository? feedback,
  PromptCoordinator? promptCoordinator,
  Duration? engagementCooldown,
  Duration? quietPeriod,
}) => ReviewPromptFlow(
  feedback: feedback ?? _FakeFeedbackRepository(),
  preferences: preferences ?? _FakePreferences(),
  presenter: presenter ?? _FakePresenter(),
  reviewStoreLauncher: launcher ?? _FakeStoreLauncher(),
  reviewSubmission: () => const FeedbackSubmission(
    detail: '',
    source: FeedbackSource.reviewNegative,
    clientSubmissionId: '00000000-0000-4000-8000-000000000001',
    locale: 'en',
  ),
  promptCoordinator: promptCoordinator,
  engagementCooldown: engagementCooldown ?? const Duration(days: 30),
  quietPeriod: quietPeriod ?? const Duration(seconds: 120),
  now: clock ?? () => now!,
);

class _FakePreferences implements ReviewPromptPreferences {
  _FakePreferences({this.firstRunAt, this.engagementPromptAt});

  DateTime? firstRunAt;
  bool optedOut = false;
  DateTime? snoozeUntil;
  DateTime? promptedAt;
  DateTime? engagementPromptAt;

  @override
  Future<DateTime?> readFirstRunAt() async => firstRunAt;
  @override
  Future<bool> readOptedOut() async => optedOut;
  @override
  Future<DateTime?> readSnoozeUntil() async => snoozeUntil;
  @override
  Future<DateTime?> readEngagementPromptAt() async => engagementPromptAt;
  @override
  Future<void> writeFirstRunAt(DateTime value) async => firstRunAt = value;
  @override
  Future<void> writeOptedOut(bool value) async => optedOut = value;
  @override
  Future<void> writeSnoozeUntil(DateTime value) async => snoozeUntil = value;
  @override
  Future<void> markPrompted(DateTime value) async {
    promptedAt = value;
    engagementPromptAt = value;
  }
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
  Future<NegativeResult?> collectNegativeFeedback({
    required FeedbackSubmission submission,
    required Future<FeedbackSubmitResult> Function(FeedbackSubmission) submit,
  }) async {
    final result = negativeResult;
    if (result?.action == NegativeAction.send) {
      final submissionResult = await submit(
        submission.copyWith(detail: result!.detail ?? ''),
      );
      if (submissionResult is FeedbackSubmitFailure) return null;
    }
    return result;
  }

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
  bool get isAvailable => true;

  @override
  Future<FeedbackSubmitResult> submitFeedback(
    FeedbackSubmission submission,
  ) async {
    reviewDetails.add(submission.detail);
    return const FeedbackSubmitSuccess();
  }

  @override
  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
    required String locale,
  }) async {}
}
