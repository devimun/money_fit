import 'package:money_fit/core/platform/remote_config.dart';
import 'package:money_fit/features/monetization/domain/ad_policy.dart';

/// Adapter only: Remote Config activation/settings remain owned by the common
/// platform service. Its fallback values keep monetization fail-open when
/// Firebase is absent or initialization fails.
class RemoteConfigAdPolicyReader implements AdPolicyReader {
  const RemoteConfigAdPolicyReader(this._remoteConfig);

  final RemoteConfigReader _remoteConfig;

  @override
  String stringValue(String key) => _remoteConfig.stringValue(key);
}
