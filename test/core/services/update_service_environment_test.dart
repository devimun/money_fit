import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/features/app_update/application/update_service.dart';

void main() {
  test(
    'Firebase-unavailable environment is not reported as no update',
    () async {
      final status = await UpdateService.fetchUpdateStatus(
        environment: AppEnvironment.test(),
      );

      expect(status.isRemoteCheckUnavailable, isTrue);
      expect(status.isForceUpdateRequired, isFalse);
      expect(status.isUpdateRecommended, isFalse);
      expect(
        status.remoteCapabilityUnavailable?.capability,
        RemoteCapability.firebase,
      );
    },
  );
}
