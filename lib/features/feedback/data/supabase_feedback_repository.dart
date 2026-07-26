import 'dart:io';

import 'package:money_fit/features/feedback/domain/contact_inquiry_type.dart';
import 'package:money_fit/features/feedback/domain/feedback_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseFeedbackRepository implements FeedbackRepository {
  const SupabaseFeedbackRepository(this._client);

  final SupabaseClient _client;

  String get _platform => Platform.isIOS
      ? 'ios'
      : Platform.isAndroid
      ? 'android'
      : 'other';

  @override
  Future<void> submitReviewFeedback(String detail) async {
    final uid = _client.auth.currentUser?.id;
    await _client.from('app_feedback').insert({
      if (uid != null) 'uid': uid,
      'detail': detail,
      'platform': _platform,
    });
  }

  @override
  Future<void> submitContactInquiry({
    required ContactInquiryType inquiryType,
    required String email,
    required String details,
  }) async {
    final uid = _client.auth.currentUser?.id;
    await _client.from('user_contact').insert({
      if (uid != null) 'uid': uid,
      'inquiry_type': inquiryType.backendCode,
      'email': email,
      'details': details,
      'platform': _platform,
    });
  }
}
