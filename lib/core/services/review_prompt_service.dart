import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/widgets/review_system/review_dialog_factory.dart';
import 'package:money_fit/core/widgets/review_system/experience_binary_dialog.dart';
import 'package:money_fit/core/widgets/review_system/positive_confirm_dialog.dart';
import 'package:money_fit/core/widgets/review_system/negative_feedback_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_fit/core/services/prompt_coordinator.dart';
import 'package:money_fit/core/models/feedback_submission.dart';
import 'package:money_fit/core/repositories/feedback_repository.dart';
import 'package:uuid/uuid.dart';

class ReviewPromptService {
  ReviewPromptService._();
  static final instance = ReviewPromptService._();

  static const String _kFirstRunAt = 'review_first_run_at';
  static const String _kOptedOut = 'review_opted_out';
  static const String _kLastPromptAt = 'review_last_prompt_at';
  static const String _kPromptCount = 'review_prompt_count';
  static const String _kSnoozeUntil = 'review_snooze_until';

  Duration minInstallAge = const Duration(days: 2);
  bool _requestedThisSession = false;

  Future<void> ensureFirstRunTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.containsKey(_kFirstRunAt))) {
      await prefs.setString(_kFirstRunAt, DateTime.now().toIso8601String());
    }
  }

  Future<bool> get isOptedOut async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kOptedOut) ?? false;
  }

  Future<void> setOptedOut(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOptedOut, value);
  }

  Future<bool> get isEligible async {
    final prefs = await SharedPreferences.getInstance();
    if (await isOptedOut) return false;

    final firstRunStr = prefs.getString(_kFirstRunAt);
    if (firstRunStr == null) return false;

    final firstRun = DateTime.tryParse(firstRunStr);
    if (firstRun == null) return false;

    // 2일 경과 체크
    if (DateTime.now().difference(firstRun) < minInstallAge) return false;

    // 스누즈(다음에 하기) 체크: 설정되어 있고 아직 기간 내면 노출 금지
    final snoozeStr = prefs.getString(_kSnoozeUntil);
    if (snoozeStr != null) {
      final snoozeUntil = DateTime.tryParse(snoozeStr);
      if (snoozeUntil != null && DateTime.now().isBefore(snoozeUntil)) {
        return false;
      }
    }

    return true;
  }

  Future<void> _markPrompted() async {
    final prefs = await SharedPreferences.getInstance();
    final promptedAt = DateTime.now().toUtc().toIso8601String();
    await prefs.setString(_kLastPromptAt, promptedAt);
    // FeedbackPromptService reads this shared timestamp so a review prompt
    // cannot be followed by the proactive feedback dialog within 30 days.
    await prefs.setString('engagement_prompt_last_shown_at', promptedAt);
    final count = prefs.getInt(_kPromptCount) ?? 0;
    await prefs.setInt(_kPromptCount, count + 1);
  }

  Future<bool> maybePromptReview(
    BuildContext context, {
    PromptCoordinator? coordinator,
  }) async {
    await ensureFirstRunTimestamp();
    if (!await isEligible) return false;
    if (_requestedThisSession) return false;
    final lease = coordinator?.tryAcquire(PromptSurface.review);
    if (coordinator != null && lease == null) return false;
    _requestedThisSession = true;
    var shown = false;
    try {
      // 1단계: 이분화 질문
      if (!context.mounted) return false;
      final bin = await ReviewDialogFactory.showExperienceBinaryDialog(context);
      shown = true;
      if (bin == null) {
        await _markPrompted();
        return true;
      }
      await _markPrompted();

      if (bin == BinaryExperience.good) {
        // 긍정 분기: 확인 모달
        if (!context.mounted) return shown;
        final pa = await ReviewDialogFactory.showPositiveConfirmDialog(context);
        if (pa == null) return shown;
        switch (pa) {
          case PositiveAction.reviewNow:
            try {
              await setOptedOut(true);
              launchReviewURL();
            } catch (e) {
              log(e.toString());
            }
            break;
          case PositiveAction.later:
            await _setSnoozeUntil(DateTime.now().add(const Duration(days: 7)));
            break;
          case PositiveAction.never:
            await setOptedOut(true);
            break;
        }
        return shown;
      }

      // 부정 분기: 자유 입력 모달
      if (!context.mounted) return shown;
      final neg = await ReviewDialogFactory.showNegativeFeedbackDialog(context);
      if (neg == null) return shown;
      switch (neg.action) {
        case NegativeAction.send:
          final sent = await submitNegativeFeedback(neg.detail);
          // 감사 안내
          if (sent && context.mounted) {
            await ReviewDialogFactory.showThanksDialog(context);
          }
          break;
        case NegativeAction.later:
          await _setSnoozeUntil(DateTime.now().add(const Duration(days: 7)));
          break;
        case NegativeAction.never:
          await setOptedOut(true);
          break;
      }
      return shown;
    } finally {
      lease?.release();
    }
  }

  /// 스누즈 설정 (다음에 하기)
  Future<void> _setSnoozeUntil(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSnoozeUntil, dateTime.toIso8601String());
  }

  /// 부정적인 피드백 제출
  Future<bool> submitNegativeFeedback(String? detail) async {
    final result = await FeedbackRepository().submit(
      FeedbackSubmission(
        detail: detail ?? '',
        source: FeedbackSource.reviewNegative,
        clientSubmissionId: const Uuid().v4(),
        locale: Platform.localeName.split('_').first,
      ),
    );
    return result is FeedbackSubmitSuccess;
  }
}
