/// A synchronous mutex for app-owned full-screen experiences.
///
/// Callers must retain the returned lease until the UI has actually been
/// dismissed (not merely until `show()` returns).
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
  void release();
}

class PromptCoordinator {
  PromptCoordinator({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;
  PromptSurface? _active;
  DateTime? _lastReleasedAt;

  PromptSurface? get activeSurface => _active;

  PromptLease? tryAcquire(
    PromptSurface surface, {
    Duration quietPeriod = Duration.zero,
  }) {
    if (_active != null) return null;
    final lastReleasedAt = _lastReleasedAt;
    final now = _now();
    if (lastReleasedAt != null &&
        now.isBefore(lastReleasedAt.add(quietPeriod))) {
      return null;
    }
    _active = surface;
    return _Lease(this, surface);
  }

  void _release(PromptSurface surface) {
    if (_active == surface) {
      _active = null;
      _lastReleasedAt = _now();
    }
  }
}

class _Lease implements PromptLease {
  _Lease(this._owner, this.surface);

  final PromptCoordinator _owner;
  @override
  final PromptSurface surface;
  bool _released = false;

  @override
  void release() {
    if (_released) return;
    _released = true;
    _owner._release(surface);
  }
}
