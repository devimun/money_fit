import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/app/bootstrap/optional_remote_capabilities.dart';
import 'package:money_fit/core/config/app_environment.dart';

void main() {
  test(
    'starts available remote capabilities without blocking either failure',
    () async {
      final calls = <String>[];
      final capabilities = OptionalRemoteCapabilities(
        initializeFirebase: (options) async => calls.add('firebase'),
        initializeSupabase: ({required url, required anonKey}) async {
          calls.add('supabase:$url:$anonKey');
          throw StateError('network unavailable');
        },
      );
      final environment = AppEnvironment.fromValues(
        firebaseEnabled: 'true',
        supabaseUrl: 'https://money-fit.supabase.co',
        supabaseAnonKey: 'anon-key',
      );

      await capabilities.start(environment);

      expect(calls, [
        'firebase',
        'supabase:https://money-fit.supabase.co:anon-key',
      ]);
      expect(capabilities.supabase.isAvailable, isFalse);
      expect(
        capabilities.supabase.unavailable?.reason,
        RemoteCapabilityUnavailableReason.initializationFailed,
      );
    },
  );

  test(
    'does not initialize remote SDKs that are unavailable in environment',
    () async {
      var calls = 0;
      final capabilities = OptionalRemoteCapabilities(
        initializeFirebase: (options) async => calls++,
        initializeSupabase: ({required url, required anonKey}) async => calls++,
      );

      await capabilities.start(AppEnvironment.test());

      expect(calls, 0);
      expect(capabilities.supabase.isAvailable, isFalse);
      expect(
        capabilities.supabase.unavailable?.reason,
        RemoteCapabilityUnavailableReason.disabled,
      );
    },
  );

  test(
    'exposes Supabase only after optional initialization succeeds',
    () async {
      final capabilities = OptionalRemoteCapabilities(
        initializeFirebase: (options) async {},
        initializeSupabase: ({required url, required anonKey}) async {},
      );
      final environment = AppEnvironment.fromValues(
        supabaseUrl: 'https://money-fit.supabase.co',
        supabaseAnonKey: 'anon-key',
      );

      expect(capabilities.supabase.isAvailable, isFalse);
      expect(
        capabilities.supabase.unavailable?.reason,
        RemoteCapabilityUnavailableReason.notInitialized,
      );

      await capabilities.startSupabase(environment);

      expect(capabilities.supabase.isAvailable, isTrue);
    },
  );

  test(
    'permits a later retry after optional Supabase initialization fails',
    () async {
      var attempts = 0;
      final capabilities = OptionalRemoteCapabilities(
        initializeFirebase: (options) async {},
        initializeSupabase: ({required url, required anonKey}) async {
          attempts += 1;
          if (attempts == 1) throw StateError('offline');
        },
      );
      final environment = AppEnvironment.fromValues(
        supabaseUrl: 'https://money-fit.supabase.co',
        supabaseAnonKey: 'anon-key',
      );

      await capabilities.startSupabase(environment);
      expect(capabilities.supabase.isAvailable, isFalse);

      await capabilities.startSupabase(environment);
      expect(attempts, 2);
      expect(capabilities.supabase.isAvailable, isTrue);
    },
  );
}
