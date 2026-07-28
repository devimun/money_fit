/// Persisted state that is independent of an advertising SDK.
class AdFrequencyState {
  const AdFrequencyState({
    this.sessionStartedAt,
    this.sessionNumber = 0,
    this.fullscreenShownThisSession = 0,
    this.pendingMeaningfulActions = 0,
    this.lastFullscreenShownAt,
    this.fullscreenHistory = const <DateTime>[],
    this.lastTriggerAt = const <String, DateTime>{},
  });

  final DateTime? sessionStartedAt;
  final int sessionNumber;
  final int fullscreenShownThisSession;
  final int pendingMeaningfulActions;
  final DateTime? lastFullscreenShownAt;
  final List<DateTime> fullscreenHistory;
  final Map<String, DateTime> lastTriggerAt;

  AdFrequencyState copyWith({
    DateTime? sessionStartedAt,
    int? sessionNumber,
    int? fullscreenShownThisSession,
    int? pendingMeaningfulActions,
    DateTime? lastFullscreenShownAt,
    List<DateTime>? fullscreenHistory,
    Map<String, DateTime>? lastTriggerAt,
    bool clearLastFullscreenShownAt = false,
  }) {
    return AdFrequencyState(
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      sessionNumber: sessionNumber ?? this.sessionNumber,
      fullscreenShownThisSession:
          fullscreenShownThisSession ?? this.fullscreenShownThisSession,
      pendingMeaningfulActions:
          pendingMeaningfulActions ?? this.pendingMeaningfulActions,
      lastFullscreenShownAt: clearLastFullscreenShownAt
          ? null
          : lastFullscreenShownAt ?? this.lastFullscreenShownAt,
      fullscreenHistory: fullscreenHistory ?? this.fullscreenHistory,
      lastTriggerAt: lastTriggerAt ?? this.lastTriggerAt,
    );
  }
}

abstract interface class AdFrequencyStateStore {
  Future<AdFrequencyState> read();

  Future<void> write(AdFrequencyState state);

  Future<void> clear();
}
