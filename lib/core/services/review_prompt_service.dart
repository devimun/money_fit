import 'dart:io';
import 'package:flutter/material.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_review/in_app_review.dart';
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
    final l10n = AppLocalizations.of(context)!;
    await ensureFirstRunTimestamp();
    if (!await isEligible) return;
    if (_requestedThisSession) return;
    _requestedThisSession = true;

    // 1단계: 이분화 질문
    final bin = await showDialog<_BinaryExperience>(
      context: context,
      builder: (ctx) => const _ExperienceBinaryDialog(),
    );
    if (bin == null) return;
    await _markPrompted();

    if (bin == _BinaryExperience.good) {
      // 긍정 분기: 확인 모달
      final pa = await showDialog<_PositiveAction>(
        context: context,
        builder: (ctx) => const _PositiveConfirmDialog(),
      );
      if (pa == null) return;
      switch (pa) {
        case _PositiveAction.reviewNow:
          // ignore: undefined_identifier
          final inApp = InAppReview.instance;
          try {
            if (await inApp.isAvailable()) {
              await inApp.requestReview();
            }
          } catch (_) {}
          break;
        case _PositiveAction.later:
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            _kSnoozeUntil,
            DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          );
          break;
        case _PositiveAction.never:
          await setOptedOut(true);
          break;
      }
      return;
    }

    // 부정 분기: 자유 입력 모달
    final neg = await showDialog<_NegativeResult>(
      context: context,
      builder: (ctx) => const _NegativeFeedbackDialog(),
    );
    if (neg == null) return;
    switch (neg.action) {
      case _NegativeAction.send:
        await _submitNegativeFeedback(neg.detail);
        // 감사 안내
        if (context.mounted) {
          showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              content: Text(l10n.review_thanks_message),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.confirm),
                ),
              ],
            ),
          );
        }
        break;
      case _NegativeAction.later:
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          _kSnoozeUntil,
          DateTime.now().add(const Duration(days: 7)).toIso8601String(),
        );
        break;
      case _NegativeAction.never:
        await setOptedOut(true);
        break;
    }
  }

  Future<void> _submitNegativeFeedback(String? detail) async {
    try {
      final client = Supabase.instance.client;
      await client.from('app_feedback').insert({
        'detail': detail ?? '',
        'platform': Platform.isIOS
            ? 'ios'
            : (Platform.isAndroid ? 'android' : 'other'),
      });
    } catch (_) {}
  }
}

enum _BinaryExperience { good, bad }

enum _PositiveAction { reviewNow, later, never }

enum _NegativeAction { send, later, never }

class _NegativeResult {
  final _NegativeAction action;
  final String? detail;
  const _NegativeResult(this.action, this.detail);
}

class _ExperienceBinaryDialog extends StatelessWidget {
  const _ExperienceBinaryDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.review_modal_binary_title),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_BinaryExperience.good),
          child: Text(l10n.review_modal_button_good),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_BinaryExperience.bad),
          child: Text(l10n.review_modal_button_bad),
        ),
      ],
    );
  }
}

class _PositiveConfirmDialog extends StatelessWidget {
  const _PositiveConfirmDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.review_positive_title),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_PositiveAction.reviewNow),
          child: Text(l10n.review_positive_button_yes),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_PositiveAction.later),
          child: Text(l10n.review_button_later),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_PositiveAction.never),
          child: Text(l10n.review_button_never),
        ),
      ],
    );
  }
}

class _NegativeFeedbackDialog extends StatefulWidget {
  const _NegativeFeedbackDialog();

  @override
  State<_NegativeFeedbackDialog> createState() =>
      _NegativeFeedbackDialogState();
}

class _NegativeFeedbackDialogState extends State<_NegativeFeedbackDialog> {
  final TextEditingController _controller = TextEditingController();
  static const int _maxLen = 300;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      title: Text(l10n.review_negative_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            maxLines: 4,
            maxLength: _maxLen,
            decoration: InputDecoration(hintText: l10n.review_negative_hint),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(_NegativeResult(_NegativeAction.later, null)),
          child: Text(l10n.review_button_later),
        ),
        TextButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(_NegativeResult(_NegativeAction.never, null)),
          child: Text(l10n.review_button_never),
        ),
        FilledButton(
          onPressed: () => Navigator.of(
            context,
          ).pop(_NegativeResult(_NegativeAction.send, _controller.text.trim())),
          child: Text(l10n.review_negative_button_send),
        ),
      ],
    );
  }
}
