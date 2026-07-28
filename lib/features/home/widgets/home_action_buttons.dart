import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/widgets/expense_management/expense_add_form.dart';
import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/providers/analytics_provider.dart';
import 'package:money_fit/core/providers/prompt_providers.dart';
import 'package:money_fit/core/services/feedback_prompt_service.dart';
import 'package:money_fit/core/services/prompt_coordinator.dart';
import 'package:money_fit/core/widgets/feedback_system/feedback_prompt_dialog.dart';
import 'package:money_fit/core/services/review_prompt_service.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/core/widgets/today_expense_list.dart';
import 'package:money_fit/features/home/viewmodel/home_data_provider.dart';
import 'package:money_fit/features/home/widgets/home_button.dart';
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
            onPressed: () async {
              final outcome = await showModalBottomSheet<ExpenseSubmitOutcome>(
                isDismissible: false,
                context: context,
                builder: (context) => TodayExpenseListBottomSheet(
                  onClose: () => Navigator.of(context).pop(),
                  isHome: true,
                ),
              );
              if (outcome != ExpenseSubmitOutcome.created || !context.mounted) {
                return;
              }
              await _afterCreatedExpense(context, ref);
            },
          ),
        ),
        Expanded(
          child: HomeButton(
            title: l10n.addExpense,
            subtitle: l10n.addNewExpensePrompt,
            onPressed: () async {
              final outcome = await showModalBottomSheet<ExpenseSubmitOutcome>(
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
                              .read(homeViewModelProvider.notifier)
                              .addExpense(expense);
                        },
                      ),
                    );
                  },
                ),
              );
              if (outcome == ExpenseSubmitOutcome.created && context.mounted) {
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
    await feedback.recordCreatedExpense();
    // The sheet's Future completes only after dismissal; schedule into the
    // parent frame so no prompt is presented over the editor.
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return;
    final decision = feedback.evaluate();
    final analytics = ref.read(analyticsProvider);
    analytics.track(AnalyticsEvent.feedbackPromptOpportunity, {
      'variant': 'proactive_prompt',
      'eligible': decision == FeedbackPromptDecision.eligible,
      if (decision != FeedbackPromptDecision.eligible)
        'suppress_reason': decision.name,
      'policy_version': feedback.config.policyVersion,
      'trigger': 'expense_created',
    });
    if (decision == FeedbackPromptDecision.eligible) {
      final lease = ref
          .read(promptCoordinatorProvider)
          .tryAcquire(
            PromptSurface.productFeedback,
            quietPeriod: feedback.config.quietPeriod,
          );
      if (lease != null) {
        try {
          await feedback.markShown();
          if (!context.mounted) return;
          analytics.track(AnalyticsEvent.feedbackPromptShown, {
            'variant': 'proactive_prompt',
            'policy_version': feedback.config.policyVersion,
          });
          final action = await showDialog<FeedbackPromptAction>(
            context: context,
            barrierDismissible: false,
            builder: (_) => FeedbackPromptDialog(
              repository: ref.read(feedbackRepositoryProvider),
              analytics: analytics,
            ),
          );
          analytics.track(AnalyticsEvent.feedbackPromptResponded, {
            'action': switch (action) {
              FeedbackPromptAction.submitted => 'submit',
              FeedbackPromptAction.later => 'later',
              FeedbackPromptAction.never => 'never',
              FeedbackPromptAction.dismissed || null => 'dismiss',
            },
            'policy_version': feedback.config.policyVersion,
          });
          switch (action) {
            case FeedbackPromptAction.submitted:
              await feedback.submitted();
              break;
            case FeedbackPromptAction.later:
              await feedback.later();
              break;
            case FeedbackPromptAction.never:
              await feedback.never();
              break;
            case FeedbackPromptAction.dismissed || null:
              await feedback.dismiss();
              break;
          }
          return;
        } finally {
          lease.release();
        }
      }
    }
    // Only the control cohort (or a remotely disabled experiment) can use the
    // legacy review flow. A feedback user's snooze/dismiss must not turn into
    // an immediate second engagement prompt.
    final canOfferReview =
        decision == FeedbackPromptDecision.controlCohort ||
        decision == FeedbackPromptDecision.remoteDisabled;
    final reviewShown = canOfferReview
        ? await ReviewPromptService.instance.maybePromptReview(
            context,
            coordinator: ref.read(promptCoordinatorProvider),
            engagementCooldown: Duration(
              days: feedback.config.engagementCooldownDays,
            ),
            quietPeriod: feedback.config.quietPeriod,
          )
        : false;
    if (!reviewShown && context.mounted) {
      await InterstitialAdManager.instance.recordMeaningfulAction(
        'expense_created',
      );
      await InterstitialAdManager.instance.maybeShowInterstitial(
        'expense_created',
        coordinator: ref.read(promptCoordinatorProvider),
      );
    }
  }
}
