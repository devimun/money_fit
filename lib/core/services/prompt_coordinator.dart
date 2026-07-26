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
  PromptSurface? _active;

  PromptSurface? get activeSurface => _active;

  PromptLease? tryAcquire(PromptSurface surface) {
    if (_active != null) return null;
    _active = surface;
    return _Lease(this, surface);
  }

  void _release(PromptSurface surface) {
    if (_active == surface) _active = null;
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
