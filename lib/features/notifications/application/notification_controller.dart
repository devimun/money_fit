import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/app/composition/repository_providers.dart';
import 'package:money_fit/app/composition/platform_providers.dart';
import 'package:money_fit/features/notifications/application/notification_scheduler.dart';
import 'package:money_fit/features/notifications/data/flutter_notification_scheduler.dart';
import 'package:money_fit/features/session/application/session_context.dart';
import 'package:permission_handler/permission_handler.dart';

enum NotificationPermissionResult { granted, denied, permanentlyDenied }

abstract interface class PermissionGateway {
  Future<NotificationPermissionResult> requestNotifications();
  Future<void> openSettings();
}

class PlatformPermissionGateway implements PermissionGateway {
  const PlatformPermissionGateway();

  @override
  Future<NotificationPermissionResult> requestNotifications() async {
    final result = await Permission.notification.request();
    if (result.isGranted) return NotificationPermissionResult.granted;
    return result.isPermanentlyDenied
        ? NotificationPermissionResult.permanentlyDenied
        : NotificationPermissionResult.denied;
  }

  @override
  Future<void> openSettings() => openAppSettings();
}

class NotificationText {
  const NotificationText({
    required this.title,
    required this.morning,
    required this.afternoon,
    required this.night,
  });

  final String title;
  final String morning;
  final String afternoon;
  final String night;
}

final notificationSchedulerProvider = Provider<NotificationScheduler>(
  (ref) => FlutterNotificationScheduler(),
);

/// Kept as a transition alias while app-level startup and reset composition
/// moves to the feature-owned scheduler name.
final notificationServiceProvider = notificationSchedulerProvider;

final permissionGatewayProvider = Provider<PermissionGateway>(
  (ref) => const PlatformPermissionGateway(),
);

class NotificationController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final ownerId = await ref.watch(currentOwnerIdProvider.future);
    final user = await ref.watch(userRepositoryProvider).getUser(ownerId);
    if (user == null) throw StateError('Missing local session user.');
    return user.notificationsEnabled;
  }

  Future<NotificationPermissionResult> enable(NotificationText text) async {
    final permission = await ref
        .read(permissionGatewayProvider)
        .requestNotifications();
    if (permission != NotificationPermissionResult.granted) return permission;

    final gateway = ref.read(notificationSchedulerProvider);
    await gateway.scheduleDaily(
      title: text.title,
      morning: text.morning,
      afternoon: text.afternoon,
      night: text.night,
    );
    await _persist(true);
    return permission;
  }

  Future<void> disable() async {
    await ref.read(notificationSchedulerProvider).cancelAll();
    await _persist(false);
  }

  Future<void> openPermissionSettings() {
    return ref.read(permissionGatewayProvider).openSettings();
  }

  Future<void> _persist(bool enabled) async {
    final ownerId = await ref.read(currentOwnerIdProvider.future);
    final users = ref.read(userRepositoryProvider);
    final user = await users.getUser(ownerId);
    if (user == null) throw StateError('Missing local session user.');
    await users.updateUser(
      user.copyWith(
        notificationsEnabled: enabled,
        updatedAt: ref.read(clockProvider).now(),
      ),
    );
    state = AsyncData(enabled);
  }
}

final notificationControllerProvider =
    AsyncNotifierProvider<NotificationController, bool>(
      NotificationController.new,
    );
