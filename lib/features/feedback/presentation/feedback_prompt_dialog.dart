import 'dart:async';

import 'package:flutter/material.dart';
import 'package:money_fit/core/platform/analytics_event.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';
import 'package:money_fit/l10n/app_localizations.dart';

enum FeedbackPromptAction { later, never, dismissed, submitted }

/// Establishes a coordinated proactive-feedback route before consuming a
/// prompt show.
///
/// The optional remote capability may be unavailable even after a successful
/// local expense save. In that case, or when route establishment throws or
/// returns null, the lease is released without starting its quiet period and
/// no persisted prompt state is written.
Future<FeedbackPromptAction?>? presentFeedbackPromptWhenAvailable({
  required FeedbackRepository repository,
  required PromptCoordinator promptCoordinator,
  required Duration quietPeriod,
  required Future<FeedbackPromptAction?>? Function() establishPresentation,
  required Future<void> Function() markShown,
  Future<void> Function()? onPresentationShown,
}) {
  if (!repository.isAvailable) return null;
  final lease = promptCoordinator.tryAcquire(
    PromptSurface.productFeedback,
    quietPeriod: quietPeriod,
  );
  if (lease == null) return null;

  try {
    final completion = establishPresentation();
    if (completion == null) {
      lease.release(applyQuietPeriod: false);
      return null;
    }
    return _markShownAfterPresentation(
      completion,
      markShown,
      onPresentationShown,
    ).whenComplete(() => lease.release());
  } catch (_) {
    lease.release(applyQuietPeriod: false);
    rethrow;
  }
}

Future<FeedbackPromptAction?> _markShownAfterPresentation(
  Future<FeedbackPromptAction?> completion,
  Future<void> Function() markShown,
  Future<void> Function()? onPresentationShown,
) async {
  try {
    await markShown();
  } catch (_) {
    // Persisting optional engagement state cannot disrupt the open route.
  }
  try {
    await onPresentationShown?.call();
  } catch (_) {
    // Observability cannot affect a presentation that is already open.
  }
  return completion;
}

/// Keeps a draft visible on failed sends and reuses one client submission ID
/// for each retry, making the UI safe against a timeout after server success.
class FeedbackPromptDialog extends StatefulWidget {
  const FeedbackPromptDialog({
    required this.repository,
    required this.submission,
    this.analytics = const NoopAnalyticsTracker(),
    super.key,
  });

  final FeedbackRepository repository;
  final FeedbackSubmission submission;
  final AnalyticsTracker analytics;

  @override
  State<FeedbackPromptDialog> createState() => _FeedbackPromptDialogState();
}

class _FeedbackPromptDialogState extends State<FeedbackPromptDialog> {
  final _controller = TextEditingController();
  bool _submitting = false;
  String? _error;
  var _submitAttempts = 0;

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

  Future<void> _dismiss() async {
    if (_submitting || !await _confirmDiscard() || !mounted) return;
    Navigator.of(context).pop(FeedbackPromptAction.dismissed);
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    final detail = _controller.text.trim();
    if (detail.isEmpty) {
      setState(() => _error = l10n.feedback_prompt_empty_error);
      return;
    }
    if (detail.length < 3) {
      setState(() => _error = l10n.feedback_prompt_too_short_error);
      return;
    }
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    _submitAttempts += 1;
    final result = await widget.repository.submitFeedback(
      widget.submission.copyWith(detail: detail),
    );
    if (result is FeedbackSubmitSuccess) {
      unawaited(
        _track(AnalyticsEvent.feedbackSubmitted, {
          'source': widget.submission.source.wire,
          'length_bucket': _lengthBucket(detail.length),
          'attempt_count_bucket': _attemptCountBucket,
        }),
      );
      if (!mounted) return;
      Navigator.of(context).pop(FeedbackPromptAction.submitted);
      return;
    }
    final failure = result as FeedbackSubmitFailure;
    unawaited(
      _track(AnalyticsEvent.feedbackSubmissionFailed, {
        'source': widget.submission.source.wire,
        'error_category': _errorCategory(failure.reason),
        'attempt_count_bucket': _attemptCountBucket,
      }),
    );
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = failure.reason == FeedbackSubmissionFailure.rateLimited
          ? l10n.feedback_prompt_rate_limited
          : l10n.feedback_prompt_submit_error;
    });
  }

  String get _attemptCountBucket => _submitAttempts == 1 ? 'first' : 'retry';

  String _lengthBucket(int length) {
    if (length <= 10) return '3_10';
    if (length <= 100) return '11_100';
    return '101_1000';
  }

  String _errorCategory(FeedbackSubmissionFailure failure) => switch (failure) {
    FeedbackSubmissionFailure.validation => 'validation',
    FeedbackSubmissionFailure.unavailable => 'unavailable',
    FeedbackSubmissionFailure.authentication => 'authentication',
    FeedbackSubmissionFailure.rateLimited => 'rate_limited',
    FeedbackSubmissionFailure.network => 'network',
    FeedbackSubmissionFailure.server => 'server',
  };

  Future<void> _track(
    AnalyticsEvent event,
    Map<String, Object> parameters,
  ) async {
    try {
      await widget.analytics.track(event.canonicalName, parameters: parameters);
    } catch (_) {
      // Delivery telemetry must never alter a completed feedback command.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _dismiss();
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
                    Text(
                      l10n.feedback_prompt_title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: _submitting ? null : _dismiss,
                        icon: const Icon(Icons.close),
                      ),
                    ),
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
                      onChanged: (_) => setState(() => _error = null),
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
