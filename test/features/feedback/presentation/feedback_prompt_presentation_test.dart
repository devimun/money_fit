import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/feedback/data/capability_aware_feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';
import 'package:money_fit/features/feedback/presentation/feedback_prompt_dialog.dart';

void main() {
  test('unavailable remote feedback does not establish or consume a show', () {
    var presentations = 0;
    var markShownCalls = 0;

    final result = presentFeedbackPromptWhenAvailable(
      repository: const UnavailableFeedbackRepository(),
      promptCoordinator: PromptCoordinator(),
      quietPeriod: const Duration(minutes: 10),
      establishPresentation: () {
        presentations += 1;
        return Future.value(FeedbackPromptAction.dismissed);
      },
      markShown: () async => markShownCalls += 1,
    );

    expect(result, isNull);
    expect(presentations, 0);
    expect(markShownCalls, 0);
  });

  test('only records a show after presentation route establishment', () async {
    final completion = Completer<FeedbackPromptAction?>();
    var markShownCalls = 0;
    var presentationShownCalls = 0;

    final result = presentFeedbackPromptWhenAvailable(
      repository: const _AvailableFeedbackRepository(),
      promptCoordinator: PromptCoordinator(),
      quietPeriod: const Duration(minutes: 10),
      establishPresentation: () => completion.future,
      markShown: () async => markShownCalls += 1,
      onPresentationShown: () async => presentationShownCalls += 1,
    );

    expect(markShownCalls, 1);
    completion.complete(FeedbackPromptAction.later);
    expect(result, isNotNull);
    expect(await result!, FeedbackPromptAction.later);
    expect(presentationShownCalls, 1);
  });

  test('a failed route establishment does not consume a show', () {
    var markShownCalls = 0;

    expect(
      () => presentFeedbackPromptWhenAvailable(
        repository: const _AvailableFeedbackRepository(),
        promptCoordinator: PromptCoordinator(),
        quietPeriod: const Duration(minutes: 10),
        establishPresentation: () => throw StateError('No navigator'),
        markShown: () async => markShownCalls += 1,
      ),
      throwsStateError,
    );
    expect(markShownCalls, 0);
  });

  test(
    'an unavailable, null, or throwing route leaves feedback immediately retryable',
    () async {
      final scenarios =
          <
            ({
              FeedbackRepository repository,
              bool throwsOnEstablish,
              Future<FeedbackPromptAction?>? Function() establish,
            })
          >[
            (
              repository: const UnavailableFeedbackRepository(),
              throwsOnEstablish: false,
              establish: () => Future.value(FeedbackPromptAction.dismissed),
            ),
            (
              repository: const _AvailableFeedbackRepository(),
              throwsOnEstablish: false,
              establish: () => null,
            ),
            (
              repository: const _AvailableFeedbackRepository(),
              throwsOnEstablish: true,
              establish: () => throw StateError('No navigator'),
            ),
          ];

      for (final scenario in scenarios) {
        final coordinator = PromptCoordinator();
        var markShownCalls = 0;

        if (scenario.throwsOnEstablish) {
          expect(
            () => presentFeedbackPromptWhenAvailable(
              repository: scenario.repository,
              promptCoordinator: coordinator,
              quietPeriod: const Duration(minutes: 10),
              establishPresentation: scenario.establish,
              markShown: () async => markShownCalls += 1,
            ),
            throwsStateError,
          );
        } else {
          expect(
            presentFeedbackPromptWhenAvailable(
              repository: scenario.repository,
              promptCoordinator: coordinator,
              quietPeriod: const Duration(minutes: 10),
              establishPresentation: scenario.establish,
              markShown: () async => markShownCalls += 1,
            ),
            isNull,
          );
        }

        expect(markShownCalls, 0);

        final retry = presentFeedbackPromptWhenAvailable(
          repository: const _AvailableFeedbackRepository(),
          promptCoordinator: coordinator,
          quietPeriod: const Duration(minutes: 10),
          establishPresentation: () =>
              Future.value(FeedbackPromptAction.dismissed),
          markShown: () async => markShownCalls += 1,
        );

        expect(retry, isNotNull);
        expect(await retry!, FeedbackPromptAction.dismissed);
        expect(markShownCalls, 1);
      }
    },
  );
}

class _AvailableFeedbackRepository implements FeedbackRepository {
  const _AvailableFeedbackRepository();

  @override
  bool get isAvailable => true;

  @override
  Future<FeedbackSubmitResult> submitFeedback(FeedbackSubmission submission) =>
      Future.value(const FeedbackSubmitSuccess());

  @override
  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
    required String locale,
  }) async {}
}
