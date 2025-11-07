import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:money_fit/core/functions/functions.dart';
import 'package:money_fit/core/widgets/review_system/review_dialog_factory.dart';
import 'package:money_fit/core/widgets/review_system/experience_binary_dialog.dart';
import 'package:money_fit/core/widgets/review_system/positive_confirm_dialog.dart';
import 'package:money_fit/core/widgets/review_system/negative_feedback_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    await prefs.setString(_kLastPromptAt, DateTime.now().toIso8601String());
    final count = prefs.getInt(_kPromptCount) ?? 0;
    await prefs.setInt(_kPromptCount, count + 1);
  }

  Future<void> maybePromptReview(BuildContext context) async {
    await ensureFirstRunTimestamp();
    if (!await isEligible) return;
    if (_requestedThisSession) return;
    _requestedThisSession = true;

    // 1단계: 이분화 질문
    final bin = await ReviewDialogFactory.showExperienceBinaryDialog(context);
    if (bin == null) return;
    await _markPrompted();

    if (bin == BinaryExperience.good) {
      // 긍정 분기: 확인 모달
      final pa = await ReviewDialogFactory.showPositiveConfirmDialog(context);
      if (pa == null) return;
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
      return;
    }

    // 부정 분기: 자유 입력 모달
    final neg = await ReviewDialogFactory.showNegativeFeedbackDialog(context);
    if (neg == null) return;
    switch (neg.action) {
      case NegativeAction.send:
        await submitNegativeFeedback(neg.detail);
        // 감사 안내
        if (context.mounted) {
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
  }

  /// 스누즈 설정 (다음에 하기)
  Future<void> _setSnoozeUntil(DateTime dateTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSnoozeUntil, dateTime.toIso8601String());
  }

  /// 부정적인 피드백 제출
  Future<void> submitNegativeFeedback(String? detail) async {
    try {
      final client = Supabase.instance.client;
      final uid = Supabase.instance.client.auth.currentUser?.id;
      await client.from('app_feedback').insert({
        if (uid != null) 'uid': uid,
        'detail': detail ?? '',
        'platform': Platform.isIOS
            ? 'ios'
            : (Platform.isAndroid ? 'android' : 'other'),
      });
    } catch (_) {}
  }
}
