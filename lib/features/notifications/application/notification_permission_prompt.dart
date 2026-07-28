import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/notifications/application/notification_controller.dart';

/// Owns the one proactive notification-permission opportunity for a home
/// session. It intentionally does not queue a suppressed prompt: showing a
/// permission request after a user has moved on would be more disruptive than
/// skipping that optional onboarding opportunity.
class NotificationPermissionPromptController {
  NotificationPermissionPromptController(
    this._promptCoordinator, {
    Duration Function()? quietPeriod,
  }) : _quietPeriod = quietPeriod ?? _noQuietPeriod;

  final PromptCoordinator _promptCoordinator;
  final Duration Function() _quietPeriod;
  bool _attempted = false;

  bool get hasAttempted => _attempted;

  /// Presents the app dialog and any follow-up permission request while one
  /// notification lease is held. Both a dialog failure and a denied system
  /// request are optional-engagement outcomes, so they never block local UI.
  Future<bool> showOnce(Future<void> Function() present) async {
    if (_attempted) return false;
    _attempted = true;
    final lease = _promptCoordinator.tryAcquire(
      PromptSurface.notificationPermission,
      quietPeriod: _quietPeriod(),
    );
    if (lease == null) return false;

    try {
      await present();
      return true;
    } catch (_) {
      return false;
    } finally {
      lease.release();
    }
  }
}

Duration _noQuietPeriod() => Duration.zero;

/// Serializes a user-initiated Settings permission request with the same
/// fullscreen surfaces as proactive notification onboarding. Unlike
/// [NotificationPermissionPromptController], a completed Settings request is
/// not permanently consumed: a user may explicitly try again later.
///
/// The caller supplies both the OS permission request and the denied fallback
/// dialog. Keeping both awaits inside this controller keeps one lease alive
/// until the fallback is dismissed (and any requested settings handoff has
/// completed). Failures are intentionally optional and leave the setting off.
class NotificationPermissionSettingsRequestController {
  NotificationPermissionSettingsRequestController(
    this._promptCoordinator, {
    Duration Function()? quietPeriod,
  }) : _quietPeriod = quietPeriod ?? _noQuietPeriod;

  final PromptCoordinator _promptCoordinator;
  final Duration Function() _quietPeriod;
  bool _inFlight = false;

  Future<bool> request({
    required Future<NotificationPermissionResult> Function() requestPermission,
    required Future<void> Function(NotificationPermissionResult permission)
    presentDeniedFallback,
  }) async {
    if (_inFlight) return false;

    final lease = _promptCoordinator.tryAcquire(
      PromptSurface.notificationPermission,
      quietPeriod: _quietPeriod(),
    );
    if (lease == null) return false;

    _inFlight = true;
    try {
      final permission = await requestPermission();
      if (permission != NotificationPermissionResult.granted) {
        await presentDeniedFallback(permission);
      }
      return true;
    } catch (_) {
      // Permission APIs and the settings handoff are optional. A failure must
      // not retain the shared lease or turn a settings toggle into a crash.
      return false;
    } finally {
      _inFlight = false;
      lease.release();
    }
  }
}
