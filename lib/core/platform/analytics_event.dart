enum AnalyticsEvent {
  screenViewed('Screen Viewed', 'screen_viewed'),
  transactionCreated('Transaction Created', 'create_transaction'),
  transactionUpdated('Transaction Updated', 'transaction_updated'),
  transactionDeleted('Transaction Deleted', 'transaction_deleted'),
  expenseFilterApplied('Expense Filter Applied', 'expense_filter_applied'),
  statisticsViewChanged('Statistics View Changed', 'statistics_view_changed'),
  calendarPeriodChanged('Calendar Period Changed', 'calendar_period_changed'),
  notificationPreferenceChanged(
    'Notification Preference Changed',
    'notification_preference_changed',
  ),
  languageChanged('Language Changed', 'language_changed'),
  budgetSet('Budget Set', 'first_budget_setting'),
  dataReset('Data Reset', 'data_reset'),
  inquirySubmitted('Inquiry Submitted', 'inquiry_submitted'),
  feedbackPromptOpportunity(
    'Feedback Prompt Opportunity',
    'feedback_prompt_opportunity',
  ),
  feedbackPromptShown('Feedback Prompt Shown', 'feedback_prompt_shown'),
  feedbackPromptResponded(
    'Feedback Prompt Responded',
    'feedback_prompt_responded',
  ),
  feedbackSubmitted('Feedback Submitted', 'feedback_submitted'),
  feedbackSubmissionFailed(
    'Feedback Submission Failed',
    'feedback_submission_failed',
  ),
  adActionRecorded('Ad Action Recorded', 'ad_action_recorded'),
  adOpportunity('Ad Opportunity', 'ad_opportunity'),
  adRequest('Ad Request', 'ad_request'),
  adLoadCompleted('Ad Load Completed', 'ad_load_completed'),
  adDisplayed('Ad Displayed', 'ad_displayed'),
  adImpression('Ad Impression', 'ad_impression'),
  adClicked('Ad Clicked', 'ad_clicked'),
  adDismissed('Ad Dismissed', 'ad_dismissed'),
  adDisplayFailed('Ad Display Failed', 'ad_display_failed'),
  adRevenueTracked('Ad Revenue Tracked', 'ad_revenue_tracked'),
  adConfigInvalid('Ad Config Invalid', 'ad_config_invalid');

  const AnalyticsEvent(this.canonicalName, this.firebaseName);

  final String canonicalName;
  final String firebaseName;

  static AnalyticsEvent? fromTrackingName(String name) {
    for (final event in values) {
      if (event.canonicalName == name || event.firebaseName == name) {
        return event;
      }
    }
    return null;
  }
}

const analyticsSchemaVersion = 1;
