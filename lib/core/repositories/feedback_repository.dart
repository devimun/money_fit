import 'dart:io';

import 'package:money_fit/core/models/feedback_submission.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum FeedbackFailure { validation, auth, rateLimited, network, server, unknown }

sealed class FeedbackSubmitResult {
  const FeedbackSubmitResult();
}

class FeedbackSubmitSuccess extends FeedbackSubmitResult {
  const FeedbackSubmitSuccess();
}

class FeedbackSubmitFailure extends FeedbackSubmitResult {
  const FeedbackSubmitFailure(this.reason);
  final FeedbackFailure reason;
}

class FeedbackRepository {
  FeedbackRepository({
    SupabaseClient? client,
    Future<PackageInfo> Function()? packageInfo,
  }) : _client = client ?? Supabase.instance.client,
       _packageInfo = packageInfo ?? PackageInfo.fromPlatform;
  final SupabaseClient _client;
  final Future<PackageInfo> Function() _packageInfo;

  Future<FeedbackSubmitResult> submit(FeedbackSubmission submission) async {
    final detail = submission.detail.trim();
    if (detail.length < 3 || detail.length > 1000) {
      return const FeedbackSubmitFailure(FeedbackFailure.validation);
    }
    try {
      var user = _client.auth.currentUser;
      user ??= (await _client.auth.signInAnonymously()).user;
      if (user == null) {
        return const FeedbackSubmitFailure(FeedbackFailure.auth);
      }
      final info = await _packageInfo();
      final payload = <String, dynamic>{
        'p_detail': detail,
        'p_source': submission.source.wire,
        'p_client_submission_id': submission.clientSubmissionId,
        'p_locale': submission.locale,
        'p_platform': Platform.isIOS
            ? 'ios'
            : (Platform.isAndroid ? 'android' : 'other'),
        'p_app_version': info.version,
        'p_build_number': info.buildNumber,
      };
      // The RPC is intentionally idempotent. A compatibility fallback keeps
      // review feedback working until the additive backend migration is live.
      await _client.rpc('submit_app_feedback', params: payload);
      return const FeedbackSubmitSuccess();
    } on PostgrestException catch (error) {
      if (error.code == '429' || error.message.toLowerCase().contains('rate')) {
        return const FeedbackSubmitFailure(FeedbackFailure.rateLimited);
      }
      return const FeedbackSubmitFailure(FeedbackFailure.server);
    } on AuthException {
      return const FeedbackSubmitFailure(FeedbackFailure.auth);
    } on SocketException {
      return const FeedbackSubmitFailure(FeedbackFailure.network);
    } catch (_) {
      return const FeedbackSubmitFailure(FeedbackFailure.unknown);
    }
  }
}
