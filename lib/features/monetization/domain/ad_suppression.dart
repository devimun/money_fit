enum AdSuppressionReason {
  notConfigured('not_configured'),
  masterDisabled('master_disabled'),
  formatDisabled('format_disabled'),
  consentNotReady('consent_not_ready'),
  newUserGrace('new_user_grace'),
  sessionTooYoung('session_too_young'),
  actionThreshold('action_threshold'),
  cooldown('cooldown'),
  sessionCap('session_cap'),
  rolling24hCap('rolling_24h_cap'),
  fullscreenUiBusy('fullscreen_ui_busy'),
  adNotReady('ad_not_ready'),
  duplicateTrigger('duplicate_trigger');

  const AdSuppressionReason(this.value);

  final String value;
}

class AdEligibility {
  const AdEligibility.allowed() : allowed = true, reason = null;

  const AdEligibility.suppressed(this.reason) : allowed = false;

  final bool allowed;
  final AdSuppressionReason? reason;
}

/// These actions are only reported after the corresponding user operation
/// completed successfully. They never display an ad by themselves.
enum MeaningfulAdAction {
  transactionSaved('transaction_saved'),
  transactionDeleted('transaction_deleted'),
  primaryDestinationChanged('primary_destination_changed'),
  calendarDateOpened('calendar_date_opened'),
  calendarMonthChanged('calendar_month_changed'),
  expenseFilterApplied('expense_filter_applied'),
  statisticsMonthChanged('statistics_month_changed'),
  statisticsTypeChanged('statistics_type_changed'),

  /// Temporary bridge for pre-refactor call sites. New code must use the
  /// specific action after success, never before validation or persistence.
  legacy('legacy');

  const MeaningfulAdAction(this.trigger);

  final String trigger;
}
