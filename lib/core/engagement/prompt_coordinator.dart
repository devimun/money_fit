/// A process-local mutex for full-screen experiences owned by the app.
///
/// A caller retains its [PromptLease] until the associated dialog, review
/// sheet, or other full-screen surface is actually dismissed. This prevents a
/// feedback/review flow from being followed immediately by another prompt.
enum PromptSurface {
  notificationPermission,
  review,
  productFeedback,
  interstitialAd,
  appOpenAd,
  update,
}

abstract interface class PromptLease {
  PromptSurface get surface;

  /// Releases this surface, optionally starting the next-acquisition quiet
  /// period. Use [applyQuietPeriod] only after the surface was established.
  void release({bool applyQuietPeriod = true});
}

class PromptCoordinator {
  PromptCoordinator({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  PromptSurface? _activeSurface;
  DateTime? _lastReleasedAt;
  int _generation = 0;

  PromptSurface? get activeSurface => _activeSurface;

  /// Clears the process-local lease and quiet-period state after a full reset.
  void reset() {
    _generation += 1;
    _activeSurface = null;
    _lastReleasedAt = null;
  }

  PromptLease? tryAcquire(
    PromptSurface surface, {
    Duration quietPeriod = Duration.zero,
  }) {
    if (_activeSurface != null) return null;
    final now = _now();
    final lastReleasedAt = _lastReleasedAt;
    if (lastReleasedAt != null &&
        now.isBefore(lastReleasedAt.add(quietPeriod))) {
      return null;
    }
    _activeSurface = surface;
    return _CoordinatorLease(this, surface, _generation);
  }

  void _release(
    PromptSurface surface,
    int generation, {
    required bool applyQuietPeriod,
  }) {
    if (_generation != generation || _activeSurface != surface) return;
    _activeSurface = null;
    if (applyQuietPeriod) _lastReleasedAt = _now();
  }
}

class _CoordinatorLease implements PromptLease {
  _CoordinatorLease(this._coordinator, this.surface, this._generation);

  final PromptCoordinator _coordinator;
  final int _generation;

  @override
  final PromptSurface surface;

  bool _released = false;

  @override
  void release({bool applyQuietPeriod = true}) {
    if (_released) return;
    _released = true;
    _coordinator._release(
      surface,
      _generation,
      applyQuietPeriod: applyQuietPeriod,
    );
  }
}
