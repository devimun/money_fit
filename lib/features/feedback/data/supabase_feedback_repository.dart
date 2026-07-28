import 'dart:io';

import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/contact_inquiry_validation.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:money_fit/features/feedback/domain/feedback_submission.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class FeedbackRemoteApi {
  Future<String> ensureAuthenticatedUserId();

  /// The deployed RPC returns a bigint. Its value is intentionally ignored:
  /// idempotency is represented by [p_client_submission_id], not a JS number.
  Future<Object?> submitAppFeedback(Map<String, Object?> parameters);

  Future<void> insertContact(Map<String, Object?> values);
}

class SupabaseFeedbackRemoteApi implements FeedbackRemoteApi {
  SupabaseFeedbackRemoteApi(this._client);

  final SupabaseClient _client;

  @override
  Future<String> ensureAuthenticatedUserId() async {
    var user = _client.auth.currentUser;
    user ??= (await _client.auth.signInAnonymously()).user;
    if (user == null) {
      throw const AuthException('Anonymous authentication failed');
    }
    return user.id;
  }

  @override
  Future<Object?> submitAppFeedback(Map<String, Object?> parameters) =>
      _client.rpc('submit_app_feedback', params: parameters);

  @override
  Future<void> insertContact(Map<String, Object?> values) =>
      _client.from('user_contact').insert(values);
}

class SupabaseFeedbackRepository implements FeedbackRepository {
  SupabaseFeedbackRepository(
    SupabaseClient client, {
    Future<PackageInfo> Function()? packageInfo,
    String Function()? platform,
  }) : _api = SupabaseFeedbackRemoteApi(client),
       _packageInfo = packageInfo ?? PackageInfo.fromPlatform,
       _platform = platform ?? _currentPlatform;

  SupabaseFeedbackRepository.withApi(
    FeedbackRemoteApi api, {
    Future<PackageInfo> Function()? packageInfo,
    String Function()? platform,
  }) : _api = api,
       _packageInfo = packageInfo ?? PackageInfo.fromPlatform,
       _platform = platform ?? _currentPlatform;

  final FeedbackRemoteApi _api;
  final Future<PackageInfo> Function() _packageInfo;
  final String Function() _platform;

  static const _supportedLocales = {
    'ko',
    'en',
    'es',
    'pl',
    'uk',
    'cs',
    'de',
    'it',
    'ro',
    'sk',
    'bg',
    'id',
    'ms',
    'fil',
  };

  static final _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  @override
  bool get isAvailable => true;

  @override
  Future<FeedbackSubmitResult> submitFeedback(
    FeedbackSubmission submission,
  ) async {
    final detail = submission.detail.trim();
    if (detail.length < 3 ||
        detail.length > 1000 ||
        !_uuidPattern.hasMatch(submission.clientSubmissionId)) {
      return const FeedbackSubmitFailure(FeedbackSubmissionFailure.validation);
    }

    try {
      await _api.ensureAuthenticatedUserId();
      final info = await _packageInfo();
      await _api.submitAppFeedback({
        'p_detail': detail,
        'p_source': submission.source.wire,
        'p_client_submission_id': submission.clientSubmissionId,
        'p_locale': _locale(submission.locale),
        'p_platform': _platform(),
        'p_app_version': _truncate(info.version, 40),
        'p_build_number': _truncate(info.buildNumber, 40),
      });
      return const FeedbackSubmitSuccess();
    } on AuthException {
      return const FeedbackSubmitFailure(
        FeedbackSubmissionFailure.authentication,
      );
    } on PostgrestException catch (error) {
      if (error.code == '429' || error.message.toLowerCase().contains('rate')) {
        return const FeedbackSubmitFailure(
          FeedbackSubmissionFailure.rateLimited,
        );
      }
      return const FeedbackSubmitFailure(FeedbackSubmissionFailure.server);
    } on SocketException {
      return const FeedbackSubmitFailure(FeedbackSubmissionFailure.network);
    } catch (_) {
      return const FeedbackSubmitFailure(FeedbackSubmissionFailure.server);
    }
  }

  @override
  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
    required String locale,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedDetails = details.trim();
    if (!FeedbackContactInquiryValidation.hasValidDetails(trimmedDetails)) {
      throw ArgumentError.value(
        details,
        'details',
        'must contain 1-500 characters',
      );
    }
    if (!FeedbackContactInquiryValidation.hasValidOptionalEmail(trimmedEmail)) {
      throw ArgumentError.value(
        email,
        'email',
        'must be a valid optional email',
      );
    }

    final userId = await _api.ensureAuthenticatedUserId();
    final info = await _packageInfo();
    await _api.insertContact({
      'uid': userId,
      'inquiry_type': inquiryType.backendCode,
      if (trimmedEmail.isNotEmpty) 'email': trimmedEmail,
      'details': trimmedDetails,
      'platform': _platform(),
      'locale': _locale(locale),
      'app_version': _truncate(info.version, 40),
      'build_number': _truncate(info.buildNumber, 40),
    });
  }

  static String _currentPlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }

  static String _locale(String value) {
    final language = value.trim().split(RegExp('[-_]')).first.toLowerCase();
    return _supportedLocales.contains(language) ? language : 'en';
  }

  static String _truncate(String value, int limit) =>
      value.substring(0, value.length.clamp(0, limit));
}
