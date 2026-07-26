enum AnalyticsEvent {
  screenViewed('Screen Viewed'),
  transactionCreated('Transaction Created'),
  transactionUpdated('Transaction Updated'),
  transactionDeleted('Transaction Deleted'),
  expenseFilterApplied('Expense Filter Applied'),
  statisticsViewChanged('Statistics View Changed'),
  calendarPeriodChanged('Calendar Period Changed'),
  notificationPreferenceChanged('Notification Preference Changed'),
  languageChanged('Language Changed'),
  budgetSet('Budget Set'),
  dataReset('Data Reset'),
  inquirySubmitted('Inquiry Submitted'),
  feedbackPromptOpportunity('Feedback Prompt Opportunity'),
  feedbackPromptShown('Feedback Prompt Shown'),
  feedbackPromptResponded('Feedback Prompt Responded'),
  feedbackSubmitted('Feedback Submitted'),
  feedbackSubmissionFailed('Feedback Submission Failed'),
  adActionRecorded('Ad Action Recorded'),
  adOpportunity('Ad Opportunity'),
  adRequest('Ad Request'),
  adLoadCompleted('Ad Load Completed'),
  adDisplayed('Ad Displayed'),
  adImpression('Ad Impression'),
  adClicked('Ad Clicked'),
  adDismissed('Ad Dismissed'),
  adDisplayFailed('Ad Display Failed'),
  adRevenueTracked('Ad Revenue Tracked'),
  adConfigInvalid('Ad Config Invalid');

  const AnalyticsEvent(this.name);
  final String name;
}

const analyticsSchemaVersion = 1;
