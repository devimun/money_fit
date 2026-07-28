import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/config/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('clean checkout has a valid local configuration', () {
      final environment = AppEnvironment.fromValues();

      expect(environment.hasValidLocalConfiguration, isTrue);
      expect(environment.local.flavor, AppFlavor.production);
      expect(environment.localConfigurationFailure, isNull);
    });

    test('invalid local flavor is a ConfigurationFailure', () {
      final environment = AppEnvironment.fromValues(flavor: 'preview');

      expect(environment.hasValidLocalConfiguration, isFalse);
      expect(
        environment.localConfigurationFailure,
        isA<ConfigurationFailure>(),
      );
    });

    test(
      'missing Supabase configuration leaves only that capability unavailable',
      () {
        final environment = AppEnvironment.fromValues();

        expect(environment.supabase.isAvailable, isFalse);
        expect(
          environment.supabase.unavailable?.reason,
          RemoteCapabilityUnavailableReason.missingConfiguration,
        );
        expect(environment.firebase.isAvailable, isTrue);
        expect(environment.hasValidLocalConfiguration, isTrue);
      },
    );

    test(
      'invalid Supabase URL is reported without a local configuration failure',
      () {
        final environment = AppEnvironment.fromValues(
          supabaseUrl: 'not-a-url',
          supabaseAnonKey: 'anon-key',
        );

        expect(environment.supabase.isAvailable, isFalse);
        expect(
          environment.supabase.unavailable?.reason,
          RemoteCapabilityUnavailableReason.invalidConfiguration,
        );
        expect(environment.localConfigurationFailure, isNull);
      },
    );

    test('test environment disables remote capabilities explicitly', () {
      final environment = AppEnvironment.test();

      expect(environment.local.flavor, AppFlavor.test);
      expect(
        environment.supabase.unavailable?.reason,
        RemoteCapabilityUnavailableReason.disabled,
      );
      expect(
        environment.firebase.unavailable?.reason,
        RemoteCapabilityUnavailableReason.disabled,
      );
    });

    test(
      'Amplitude is enabled only by an explicit Dart-define configuration',
      () {
        final disabled = AppEnvironment.fromValues(
          amplitudeApiKey: 'production-key',
          amplitudeEnabled: 'false',
        );
        final enabled = AppEnvironment.fromValues(
          amplitudeApiKey: 'production-key',
          amplitudeEnabled: 'true',
          analyticsEnvironment: 'prod',
          amplitudeServerZone: 'eu',
        );

        expect(disabled.analytics.isAmplitudeEnabled, isFalse);
        expect(enabled.analytics.isAmplitudeEnabled, isTrue);
        expect(enabled.analytics.analyticsEnvironment, 'prod');
        expect(enabled.analytics.amplitudeServerZone, 'eu');
        expect(enabled.analytics.toString(), isNot(contains('production-key')));
      },
    );
  });
}
