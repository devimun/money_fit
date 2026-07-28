import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/feedback_providers.dart';
import 'package:money_fit/app/composition/engagement_providers.dart';
import 'package:money_fit/app/composition/monetization_providers.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/core/platform/analytics_event.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/features/feedback/application/feedback_prompt_service.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';
import 'package:money_fit/features/feedback/presentation/feedback_prompt_dialog.dart';
import 'package:money_fit/features/ledger/presentation/editor/expense_add_form.dart';
import 'package:money_fit/features/ledger/presentation/editor/today_expense_list.dart';
import 'package:money_fit/features/ledger/application/legacy/expenses_provider.dart';
import 'package:money_fit/features/home/application/home_projection.dart';
import 'package:money_fit/features/home/widgets/home_button.dart';
import 'package:money_fit/features/monetization/domain/ad_suppression.dart';
import 'package:money_fit/l10n/app_localizations.dart';

class HomeActionButtons extends ConsumerWidget {
  final HomeState homeState;
  final String userId;

  const HomeActionButtons({
    super.key,
    required this.homeState,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: HomeButton(
            title: l10n.viewTodaySpending,
            subtitle: l10n.totalSpendingCount(
              homeState.todayExpenseList.length,
            ),
            onPressed: () {
              showModalBottomSheet(
                isDismissible: false,
                context: context,
                builder: (context) => TodayExpenseListBottomSheet(
                  onClose: () => Navigator.of(context).pop(),
                  isHome: true,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: HomeButton(
            title: l10n.addExpense,
            subtitle: l10n.addNewExpensePrompt,
            onPressed: () async {
              final created = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => LayoutBuilder(
                  builder: (context, constraints) {
                    final height = constraints.maxHeight;

                    return SizedBox(
                      height: height * 0.9,
                      child: ExpenseAddForm(
                        uid: userId,
                        onSubmit: (expense) async {
                          // 지출 등록 후 상태 업데이트
                          await ref
                              .read(coreExpensesProvider.notifier)
                              .addExpense(expense);
                        },
                      ),
                    );
                  },
                ),
              );
              if (created == true && context.mounted) {
                await _afterCreatedExpense(context, ref);
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _afterCreatedExpense(BuildContext context, WidgetRef ref) async {
    final feedback = ref.read(feedbackPromptServiceProvider);
    await _runBestEffort(feedback.initializeSession);
    await _runBestEffort(feedback.recordMeaningfulAction);
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return;

    FeedbackPromptDecision? decision;
    try {
      decision = await feedback.evaluate();
    } catch (_) {
      // A prompt-policy read is optional after the expense has been saved.
    }
    final analytics = ref.read(analyticsTrackerProvider);
    if (decision != null) {
      unawaited(
        _trackBestEffort(analytics, AnalyticsEvent.feedbackPromptOpportunity, {
          'variant': 'proactive_prompt',
          'eligible': decision == FeedbackPromptDecision.eligible,
          if (decision != FeedbackPromptDecision.eligible)
            'suppress_reason': decision.name,
          'policy_version': feedback.config.policyVersion,
          'trigger': 'expense_created',
        }),
      );
    }
    if (decision == FeedbackPromptDecision.eligible) {
      final repository = ref.read(feedbackRepositoryProvider);
      if (repository.isAvailable) {
        try {
          if (!context.mounted) return;
          final submission = FeedbackSubmission(
            detail: '',
            source: FeedbackSource.proactivePrompt,
            clientSubmissionId: ref.read(idGeneratorProvider).next(),
            locale: Localizations.localeOf(context).toString(),
          );
          final dialog = presentFeedbackPromptWhenAvailable(
            repository: repository,
            promptCoordinator: ref.read(promptCoordinatorProvider),
            quietPeriod: feedback.config.quietPeriod,
            establishPresentation: () => showDialog<FeedbackPromptAction>(
              context: context,
              barrierDismissible: false,
              builder: (_) => FeedbackPromptDialog(
                repository: repository,
                submission: submission,
                analytics: analytics,
              ),
            ),
            markShown: feedback.markShown,
            onPresentationShown: () => _trackBestEffort(
              analytics,
              AnalyticsEvent.feedbackPromptShown,
              {
                'variant': 'proactive_prompt',
                'policy_version': feedback.config.policyVersion,
              },
            ),
          );
          if (dialog == null) return;
          final action = await dialog;
          unawaited(
            _trackBestEffort(
              analytics,
              AnalyticsEvent.feedbackPromptResponded,
              {
                'action': switch (action) {
                  FeedbackPromptAction.submitted => 'submit',
                  FeedbackPromptAction.later => 'later',
                  FeedbackPromptAction.never => 'never',
                  FeedbackPromptAction.dismissed || null => 'dismiss',
                },
                'policy_version': feedback.config.policyVersion,
              },
            ),
          );
          switch (action) {
            case FeedbackPromptAction.submitted:
              await feedback.submitted();
            case FeedbackPromptAction.later:
              await feedback.later();
            case FeedbackPromptAction.never:
              await feedback.never();
            case FeedbackPromptAction.dismissed || null:
              await feedback.dismiss();
          }
        } catch (_) {
          // A feedback surface must not turn a successful local save into a
          // failed UI action.
        }
      }
    } else {
      // A feedback-specific suppression must never immediately turn into a
      // review request. The legacy review flow is confined to non-feedback
      // experiment variants.
      if (decision == FeedbackPromptDecision.controlCohort ||
          decision == FeedbackPromptDecision.remoteDisabled) {
        await _runBestEffort(() => ref.read(reviewPromptProvider)(context));
      }
    }
    unawaited(
      ref.read(monetizationSafePointProvider)(
        MeaningfulAdAction.transactionSaved,
      ),
    );
  }

  Future<void> _trackBestEffort(
    AnalyticsTracker analytics,
    AnalyticsEvent event,
    Map<String, Object> parameters,
  ) async {
    try {
      await analytics.track(event.canonicalName, parameters: parameters);
    } catch (_) {
      // Analytics must not change the outcome of a persisted expense command.
    }
  }

  Future<void> _runBestEffort(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // An optional engagement surface cannot alter a persisted expense.
    }
  }
}
