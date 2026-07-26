import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_fit/core/analytics/analytics_event.dart';
import 'package:money_fit/core/analytics/analytics_service.dart';
import 'package:money_fit/core/models/feedback_submission.dart';
import 'package:money_fit/core/repositories/feedback_repository.dart';
import 'package:money_fit/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

enum FeedbackPromptAction { later, never, dismissed, submitted }

class FeedbackPromptDialog extends StatefulWidget {
  const FeedbackPromptDialog({
    super.key,
    required this.repository,
    this.analytics = const NoopAnalyticsService(),
  });
  final FeedbackRepository repository;
  final AnalyticsService analytics;
  @override
  State<FeedbackPromptDialog> createState() => _FeedbackPromptDialogState();
}

class _FeedbackPromptDialogState extends State<FeedbackPromptDialog> {
  final _controller = TextEditingController();
  final _submissionId = const Uuid().v4();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (_controller.text.trim().isEmpty) return true;
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(l10n.feedback_prompt_discard_confirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.confirm),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = l10n.feedback_prompt_empty_error);
      return;
    }
    if (text.length < 3) {
      setState(() => _error = l10n.feedback_prompt_too_short_error);
      return;
    }
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    final result = await widget.repository.submit(
      FeedbackSubmission(
        detail: text,
        source: FeedbackSource.proactivePrompt,
        clientSubmissionId: _submissionId,
        locale: Localizations.localeOf(context).languageCode,
      ),
    );
    if (!mounted) return;
    if (result is FeedbackSubmitSuccess) {
      unawaited(
        widget.analytics.track(AnalyticsEvent.feedbackSubmitted, {
          'source': 'proactive_prompt',
          'length_bucket': _lengthBucket(text.length),
          'attempt_count_bucket': 'first',
        }),
      );
      Navigator.of(context).pop(FeedbackPromptAction.submitted);
    } else {
      final failure = result as FeedbackSubmitFailure;
      unawaited(
        widget.analytics.track(AnalyticsEvent.feedbackSubmissionFailed, {
          'source': 'proactive_prompt',
          'error_category': failure.reason.name,
          'attempt_count_bucket': 'first',
        }),
      );
      setState(() {
        _submitting = false;
        _error = failure.reason == FeedbackFailure.rateLimited
            ? l10n.feedback_prompt_rate_limited
            : l10n.feedback_prompt_submit_error;
      });
    }
  }

  String _lengthBucket(int length) {
    if (length <= 10) return '3_10';
    if (length <= 100) return '11_100';
    return '101_1000';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: _controller.text.trim().isEmpty && !_submitting,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || _submitting) return;
        final shouldDiscard = await _confirmDiscard();
        if (!mounted || !shouldDiscard) return;
        Navigator.of(this.context).pop(FeedbackPromptAction.dismissed);
      },
      child: Dialog(
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * .85,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.feedback_prompt_title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.feedback_prompt_body),
                    const SizedBox(height: 12),
                    Text(
                      l10n.feedback_prompt_privacy_hint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _controller,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: 1000,
                      textInputAction: TextInputAction.newline,
                      onChanged: (_) {
                        if (_error != null) setState(() => _error = null);
                      },
                      decoration: InputDecoration(
                        hintText: l10n.feedback_prompt_hint,
                        errorText: _error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.feedback_prompt_send),
                    ),
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.pop(
                              context,
                              FeedbackPromptAction.later,
                            ),
                      child: Text(l10n.feedback_prompt_later),
                    ),
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.pop(
                              context,
                              FeedbackPromptAction.never,
                            ),
                      child: Text(l10n.feedback_prompt_never),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
