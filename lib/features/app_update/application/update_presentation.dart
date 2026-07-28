import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/engagement/prompt_coordinator.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';

/// A recommended update is advisory, but should not immediately follow another
/// full-screen experience in the same app session.
const defaultUpdatePromptQuietPeriod = Duration(seconds: 120);

typedef UpdateStoreLauncher = Future<void> Function(Uri? storeUri);

/// Retains the startup update decision until a usable route can present it.
/// The bootstrap gate continues to own forced-update routing.
class UpdateStatusNotifier extends StateNotifier<UpdateStatus> {
  UpdateStatusNotifier() : super(UpdateStatus.none);

  void set(UpdateStatus status) => state = status;
}

final updateStatusProvider =
    StateNotifierProvider<UpdateStatusNotifier, UpdateStatus>(
      (ref) => UpdateStatusNotifier(),
    );

/// Presents one advisory notification for the current process. A suppressed
/// notification remains eligible for a later explicit provider update, while a
/// successfully shown notification is never duplicated by widget rebuilds.
class RecommendedUpdatePromptController {
  bool _notificationShown = false;
  bool _notificationInFlight = false;

  Future<bool> presentNotificationIfNeeded({
    required UpdateStatus status,
    required PromptCoordinator promptCoordinator,
    required Future<void> Function() establishPresentation,
    Duration quietPeriod = defaultUpdatePromptQuietPeriod,
  }) async {
    if (!status.isUpdateRecommended ||
        _notificationShown ||
        _notificationInFlight) {
      return false;
    }

    _notificationInFlight = true;
    try {
      final shown = await presentUpdateSurfaceWhenAvailable(
        promptCoordinator: promptCoordinator,
        quietPeriod: quietPeriod,
        establishPresentation: establishPresentation,
        // A snackbar is not a retained full-screen surface. Releasing without
        // a quiet period lets its Details action open the sheet immediately.
        applyQuietPeriodOnRelease: false,
      );
      if (shown) _notificationShown = true;
      return shown;
    } finally {
      _notificationInFlight = false;
    }
  }

  Future<bool> presentDetailsWhenAvailable({
    required UpdateStatus status,
    required PromptCoordinator promptCoordinator,
    required Future<void> Function() establishPresentation,
    Duration quietPeriod = defaultUpdatePromptQuietPeriod,
  }) {
    if (!status.isUpdateRecommended) return Future.value(false);
    return presentUpdateSurfaceWhenAvailable(
      promptCoordinator: promptCoordinator,
      quietPeriod: quietPeriod,
      establishPresentation: establishPresentation,
    );
  }
}

final recommendedUpdatePromptControllerProvider =
    Provider<RecommendedUpdatePromptController>(
      (ref) => RecommendedUpdatePromptController(),
    );

/// Holds the update lease only while [establishPresentation] owns a displayed
/// surface. UI failures and prompt contention are advisory and fail open.
Future<bool> presentUpdateSurfaceWhenAvailable({
  required PromptCoordinator promptCoordinator,
  required Future<void> Function() establishPresentation,
  Duration quietPeriod = defaultUpdatePromptQuietPeriod,
  bool applyQuietPeriodOnRelease = true,
}) async {
  final lease = promptCoordinator.tryAcquire(
    PromptSurface.update,
    quietPeriod: quietPeriod,
  );
  if (lease == null) return false;

  var established = false;
  try {
    await establishPresentation();
    established = true;
    return true;
  } catch (_) {
    return false;
  } finally {
    lease.release(applyQuietPeriod: established && applyQuietPeriodOnRelease);
  }
}
