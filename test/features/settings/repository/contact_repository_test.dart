import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/settings/model/inquiry_type.dart';
import 'package:money_fit/features/settings/repository/contact_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';

class _FakeContactApi implements ContactApi {
  Map<String, Object>? payload;
  var authenticationCalls = 0;

  @override
  Future<String> ensureAuthenticatedUserId() async {
    authenticationCalls += 1;
    return 'user-id';
  }

  @override
  Future<void> insert(Map<String, Object> value) async {
    payload = value;
  }
}

void main() {
  ContactRepository repositoryFor(_FakeContactApi api) {
    return ContactRepository(
      api: api,
      platform: () => 'android',
      packageInfo: () async => PackageInfo(
        appName: 'MoneyFit',
        packageName: 'com.moneyfit.app',
        version: '1.2.7',
        buildNumber: '18',
        buildSignature: '',
      ),
    );
  }

  test('serializes a trimmed inquiry with fixed wire values', () async {
    final api = _FakeContactApi();

    await repositoryFor(api).submit(
      type: InquiryType.featureSuggestion,
      email: '  reply@example.com ',
      details: '  Please add CSV export.  ',
      locale: 'en',
    );

    expect(api.authenticationCalls, 1);
    expect(api.payload, {
      'uid': 'user-id',
      'inquiry_type': 'feature_suggestion',
      'email': 'reply@example.com',
      'details': 'Please add CSV export.',
      'platform': 'android',
      'locale': 'en',
      'app_version': '1.2.7',
      'build_number': '18',
    });
  });

  test(
    'rejects invalid input before starting anonymous authentication',
    () async {
      final api = _FakeContactApi();

      await expectLater(
        repositoryFor(api).submit(
          type: InquiryType.bugReport,
          email: 'not-an-email',
          details: 'The app crashed',
          locale: 'en',
        ),
        throwsArgumentError,
      );
      expect(api.authenticationCalls, 0);
    },
  );

  test('inquiry types retain stable backend codes', () {
    expect(InquiryType.values.map((type) => type.wire), [
      'bug_report',
      'feature_suggestion',
      'general_inquiry',
      'other',
    ]);
  });
}
