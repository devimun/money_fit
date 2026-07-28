abstract interface class FeedbackPromptStateStore {
  Future<void> initializeSession();

  Future<DateTime?> readFirstRunAt();
  Future<int> readSessionCount();
  Future<int> readMeaningfulActionCount();
  Future<int> readActiveDayCount();
  Future<int> readStableCohortBucket();
  Future<bool> readOptedOut();
  Future<DateTime?> readSnoozeUntil();
  Future<DateTime?> readEngagementPromptAt();
  Future<bool> readShownThisSession();
  Future<bool> readShownToday();
  Future<List<DateTime>> readShowHistory();

  Future<void> recordMeaningfulAction();
  Future<void> markShown();
  Future<void> snooze(Duration duration);
  Future<void> optOut();
  Future<void> markSubmitted();
}
