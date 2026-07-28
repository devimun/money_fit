import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/core/platform/analytics_event.dart';
import 'package:money_fit/core/platform/analytics_sanitizer.dart';
import 'package:money_fit/core/platform/analytics_tracker.dart';

void main() {
  test('NoopAnalyticsTracker completes without SDK initialization', () async {
    await expectLater(
      const NoopAnalyticsTracker().track('ledger_opened'),
      completes,
    );
  });

  test(
    'ThrowingAnalyticsTracker exposes an analytics failure to callers',
    () async {
      final tracker = ThrowingAnalyticsTracker(StateError('offline'));

      await expectLater(tracker.track('ledger_opened'), throwsStateError);
    },
  );

  test('sanitizer keeps only reviewed, non-PII event properties', () {
    final values = AnalyticsSanitizer()
        .sanitize(AnalyticsEvent.transactionCreated, const {
          'transaction_type': 'essential',
          'category_key': 'custom user category',
          'entry_point': 'home',
          'amount': 9000,
          'email': 'person@example.com',
          'client_submission_id': '123e4567-e89b-12d3-a456-426614174000',
        }, analyticsEnvironment: 'prod');

    expect(values, {
      'schema_version': analyticsSchemaVersion,
      'analytics_env': 'prod',
      'transaction_type': 'essential',
      'category_key': 'custom',
      'entry_point': 'home',
    });
  });

  test('update and delete telemetry reject transaction PII', () {
    final sanitizer = AnalyticsSanitizer();
    const privateValues = <String, Object>{
      'transaction_type': 'essential',
      'name': 'Private lunch note',
      'amount': 18000,
      'user_id': 'local-owner-42',
      'id': 'expense-42',
      'email': 'person@example.com',
      'details': 'private details',
    };

    for (final event in [
      AnalyticsEvent.transactionUpdated,
      AnalyticsEvent.transactionDeleted,
    ]) {
      expect(
        sanitizer.sanitize(event, privateValues, analyticsEnvironment: 'prod'),
        {
          'schema_version': analyticsSchemaVersion,
          'analytics_env': 'prod',
          'transaction_type': 'essential',
        },
      );
    }
  });

  test('feedback and contact telemetry keep only canonical non-PII fields', () {
    final sanitizer = AnalyticsSanitizer();

    expect(
      sanitizer.sanitize(AnalyticsEvent.feedbackSubmitted, const {
        'source': 'proactive_prompt',
        'length_bucket': '3_10',
        'attempt_count_bucket': 'first',
        'detail': 'Please add exports',
        'client_submission_id': '00000000-0000-4000-8000-000000000001',
      }),
      {
        'schema_version': analyticsSchemaVersion,
        'analytics_env': 'dev',
        'source': 'proactive_prompt',
        'length_bucket': '3_10',
        'attempt_count_bucket': 'first',
      },
    );
    expect(
      sanitizer.sanitize(AnalyticsEvent.inquirySubmitted, const {
        'inquiry_type': 'bug_report',
        'result': 'success',
        'email': 'person@example.com',
        'details': 'The app did not save my update.',
      }),
      {
        'schema_version': analyticsSchemaVersion,
        'analytics_env': 'dev',
        'inquiry_type': 'bug_report',
        'result': 'success',
      },
    );
  });

  test('sanitizer preserves canonical StatefulShell screen transitions', () {
    final values = AnalyticsSanitizer()
        .sanitize(AnalyticsEvent.screenViewed, const {
          'screen_name': 'calendar',
          'previous_screen_name': 'home',
          'navigation_type': 'branch_switch',
        });

    expect(values['navigation_type'], 'branch_switch');
  });

  test(
    'sanitizer accepts 80-character policy versions only for policy keys',
    () {
      final version = List.filled(80, 'p').join();
      final sanitizer = AnalyticsSanitizer();

      expect(
        sanitizer.sanitize(AnalyticsEvent.feedbackPromptShown, {
          'policy_version': version,
          'variant': List.filled(65, 'v').join(),
        }),
        {
          'schema_version': analyticsSchemaVersion,
          'analytics_env': 'dev',
          'policy_version': version,
        },
      );
      expect(
        sanitizer.sanitize(AnalyticsEvent.adImpression, {
          'ad_format': 'interstitial',
          'placement': 'natural_break',
          'ad_policy_version': version,
        })['ad_policy_version'],
        version,
      );
    },
  );

  test('sanitizer rejects the removed app-open ad taxonomy', () {
    expect(
      AnalyticsSanitizer().sanitize(AnalyticsEvent.adImpression, const {
        'ad_format': 'app_open',
        'placement': 'natural_break',
      }),
      {
        'schema_version': analyticsSchemaVersion,
        'analytics_env': 'dev',
        'placement': 'natural_break',
      },
    );
  });

  test('screen views dual-write custom and Firebase standard events', () async {
    final firebase = _FakeFirebaseAnalyticsClient();
    final tracker = DualAnalyticsTracker(
      const AnalyticsConfiguration(),
      firebase: firebase,
      collectionEnabled: true,
    );

    await tracker.initialize();
    await tracker.trackScreenView(screenName: 'home', navigationType: 'push');

    expect(firebase.events, hasLength(1));
    expect(firebase.events.single.name, 'screen_viewed');
    expect(firebase.events.single.parameters, {
      'schema_version': analyticsSchemaVersion,
      'analytics_env': 'dev',
      'screen_name': 'home',
      'navigation_type': 'push',
    });
    expect(firebase.screenViews, [
      (screenName: 'home', screenClass: 'moneyfit_home'),
    ]);
  });

  test('opt-out prevents Firebase events and standard screen views', () async {
    final firebase = _FakeFirebaseAnalyticsClient();
    final tracker = DualAnalyticsTracker(
      const AnalyticsConfiguration(),
      firebase: firebase,
    );

    await tracker.trackScreenView(
      screenName: 'settings',
      navigationType: 'push',
    );
    await tracker.initialize();

    expect(firebase.events, isEmpty);
    expect(firebase.screenViews, isEmpty);
  });

  test(
    'flushes root and shell screen views after optional analytics is ready',
    () async {
      final firebase = _FakeFirebaseAnalyticsClient();
      final tracker = DualAnalyticsTracker(
        const AnalyticsConfiguration(),
        firebase: firebase,
        collectionEnabled: true,
      );

      await tracker.trackScreenView(
        screenName: 'update_check',
        navigationType: 'push',
      );
      await tracker.trackScreenView(
        screenName: 'home',
        previousScreenName: 'update_check',
        navigationType: 'replace',
      );

      expect(firebase.events, isEmpty);
      expect(firebase.screenViews, isEmpty);

      await tracker.initialize();

      expect(firebase.collectionEnabled, [true]);
      expect(firebase.events.map((event) => event.name), [
        'screen_viewed',
        'screen_viewed',
      ]);
      expect(firebase.events.map((event) => event.parameters!['screen_name']), [
        'update_check',
        'home',
      ]);
      expect(firebase.screenViews, [
        (screenName: 'update_check', screenClass: 'moneyfit_update_check'),
        (screenName: 'home', screenClass: 'moneyfit_home'),
      ]);
    },
  );

  test(
    'opt-out clears screen views queued before optional runtime readiness',
    () async {
      final firebase = _FakeFirebaseAnalyticsClient();
      final tracker = DualAnalyticsTracker(
        const AnalyticsConfiguration(),
        firebase: firebase,
        collectionEnabled: true,
      );

      await tracker.trackScreenView(screenName: 'home', navigationType: 'push');
      await tracker.setCollectionEnabled(false);
      await tracker.initialize();

      expect(firebase.collectionEnabled, [false]);
      expect(firebase.events, isEmpty);
      expect(firebase.screenViews, isEmpty);
    },
  );

  test(
    'local identity is applied only after consent and is cleared explicitly',
    () async {
      final firebase = _FakeFirebaseAnalyticsClient();
      final tracker = DualAnalyticsTracker(
        const AnalyticsConfiguration(),
        firebase: firebase,
        collectionEnabled: true,
      );

      await tracker.setUserId('device-local-owner');
      expect(firebase.userIds, isEmpty);

      await tracker.initialize();
      await tracker.setUserId(null);

      expect(firebase.userIds, ['device-local-owner', null]);
    },
  );

  test('persisted opt-out never applies a local analytics identity', () async {
    final firebase = _FakeFirebaseAnalyticsClient();
    final tracker = DualAnalyticsTracker(
      const AnalyticsConfiguration(),
      firebase: firebase,
    );

    await tracker.setUserId('device-local-owner');
    await tracker.initialize();

    expect(firebase.collectionEnabled, [false]);
    expect(firebase.userIds, isEmpty);
  });

  test(
    'reset clears identity without changing the explicit collection choice',
    () async {
      final firebase = _FakeFirebaseAnalyticsClient();
      final tracker = DualAnalyticsTracker(
        const AnalyticsConfiguration(),
        firebase: firebase,
        collectionEnabled: true,
      );

      await tracker.setUserId('device-local-owner');
      await tracker.initialize();
      await tracker.setCollectionEnabled(false);
      await tracker.reset();
      await tracker.track(
        AnalyticsEvent.feedbackSubmitted.canonicalName,
        parameters: const {
          'source': 'proactive_prompt',
          'length_bucket': '3_10',
          'attempt_count_bucket': 'first',
        },
      );

      expect(firebase.collectionEnabled, [true, false]);
      expect(firebase.userIds, ['device-local-owner', null]);
      expect(firebase.events, isEmpty);
    },
  );

  test(
    'Amplitude-only opt-out does not suppress the Firebase local identity',
    () async {
      final firebase = _FakeFirebaseAnalyticsClient();
      final tracker = DualAnalyticsTracker(
        const AnalyticsConfiguration(),
        firebase: firebase,
        collectionEnabled: true,
      );

      await tracker.setUserId('device-local-owner');
      await tracker.setCollectionEnabled(true);
      await tracker.setAmplitudeCollectionEnabled(false);
      await tracker.track(
        AnalyticsEvent.transactionCreated.canonicalName,
        parameters: const {
          'transaction_type': 'essential',
          'category_key': 'food',
          'entry_point': 'home',
        },
      );
      await tracker.initialize();

      expect(firebase.collectionEnabled, [true]);
      expect(firebase.userIds, ['device-local-owner']);
      expect(firebase.events.single.name, 'create_transaction');
    },
  );
}

class _FakeFirebaseAnalyticsClient implements FirebaseAnalyticsClient {
  final collectionEnabled = <bool>[];
  final userIds = <String?>[];
  final events = <({String name, Map<String, Object>? parameters})>[];
  final screenViews = <({String? screenName, String? screenClass})>[];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    events.add((name: name, parameters: parameters));
  }

  @override
  Future<void> logScreenView({String? screenName, String? screenClass}) async {
    screenViews.add((screenName: screenName, screenClass: screenClass));
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    collectionEnabled.add(enabled);
  }

  @override
  Future<void> setUserId({String? id}) async {
    userIds.add(id);
  }
}
