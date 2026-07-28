import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/feedback/data/supabase_feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  const submission = FeedbackSubmission(
    detail: 'Please add CSV export.',
    source: FeedbackSource.proactivePrompt,
    clientSubmissionId: '00000000-0000-4000-8000-000000000001',
    locale: 'ko-KR',
  );

  test(
    'sends an idempotent RPC payload and ignores its bigint return value',
    () async {
      final api = _RecordingApi();
      final repository = _repository(api);

      final result = await repository.submitFeedback(submission);

      expect(result, isA<FeedbackSubmitSuccess>());
      expect(api.authenticationCalls, 1);
      expect(api.feedbackParameters, {
        'p_detail': 'Please add CSV export.',
        'p_source': 'proactive_prompt',
        'p_client_submission_id': '00000000-0000-4000-8000-000000000001',
        'p_locale': 'ko',
        'p_platform': 'test',
        'p_app_version': '1.2.7',
        'p_build_number': '18',
      });
    },
  );

  test(
    'validates contact fields before creating anonymous auth state',
    () async {
      final api = _RecordingApi();
      final repository = _repository(api);

      await expectLater(
        repository.submitContactInquiry(
          inquiryType: ContactInquiryType.bugReport,
          email: 'not an email',
          details: 'The app stopped saving.',
          locale: 'en',
        ),
        throwsArgumentError,
      );

      expect(api.authenticationCalls, 0);
    },
  );

  test('creates anonymous identity before a valid contact insert', () async {
    final api = _RecordingApi();
    final repository = _repository(api);

    await repository.submitContactInquiry(
      inquiryType: ContactInquiryType.featureSuggestion,
      email: 'person@example.com',
      details: 'Please add more categories.',
      locale: 'unknown-locale',
    );

    expect(api.authenticationCalls, 1);
    expect(api.contactValues?['uid'], 'anonymous-user');
    expect(api.contactValues?['inquiry_type'], 'feature_suggestion');
    expect(api.contactValues?['locale'], 'en');
  });

  test('normalizes accepted contact fields before remote delivery', () async {
    final api = _RecordingApi();
    final repository = _repository(api);

    await repository.submitContactInquiry(
      inquiryType: ContactInquiryType.generalInquiry,
      email: '  person@example.com  ',
      details: '  Please keep this detail.  ',
      locale: 'en',
    );

    expect(api.contactValues?['email'], 'person@example.com');
    expect(api.contactValues?['details'], 'Please keep this detail.');
  });
}

SupabaseFeedbackRepository _repository(_RecordingApi api) =>
    SupabaseFeedbackRepository.withApi(
      api,
      packageInfo: () async => PackageInfo(
        appName: 'MoneyFit',
        packageName: 'com.moneyfit.app',
        version: '1.2.7',
        buildNumber: '18',
        buildSignature: '',
      ),
      platform: () => 'test',
    );

class _RecordingApi implements FeedbackRemoteApi {
  int authenticationCalls = 0;
  Map<String, Object?>? feedbackParameters;
  Map<String, Object?>? contactValues;

  @override
  Future<String> ensureAuthenticatedUserId() async {
    authenticationCalls += 1;
    return 'anonymous-user';
  }

  @override
  Future<void> insertContact(Map<String, Object?> values) async {
    contactValues = values;
  }

  @override
  Future<Object?> submitAppFeedback(Map<String, Object?> parameters) async {
    feedbackParameters = parameters;
    return 9223372036854775807;
  }
}
