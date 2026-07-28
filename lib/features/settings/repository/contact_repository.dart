import 'dart:io';

import 'package:money_fit/features/settings/model/inquiry_type.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ContactSubmissionRepository {
  Future<void> submit({
    required InquiryType type,
    required String email,
    required String details,
    required String locale,
  });
}

/// Minimal Supabase boundary so the dialog can be tested without an SDK client.
abstract interface class ContactApi {
  Future<String> ensureAuthenticatedUserId();
  Future<void> insert(Map<String, Object> payload);
}

class SupabaseContactApi implements ContactApi {
  SupabaseContactApi({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

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
  Future<void> insert(Map<String, Object> payload) {
    return _client.from('user_contact').insert(payload);
  }
}

class ContactRepository implements ContactSubmissionRepository {
  ContactRepository({
    ContactApi? api,
    Future<PackageInfo> Function()? packageInfo,
    String Function()? platform,
  }) : _api = api ?? SupabaseContactApi(),
       _packageInfo = packageInfo ?? PackageInfo.fromPlatform,
       _platform = platform ?? _currentPlatform;

  final ContactApi _api;
  final Future<PackageInfo> Function() _packageInfo;
  final String Function() _platform;

  static String _currentPlatform() {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'other';
  }

  static bool isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  static String _truncate(String value, int maxLength) {
    return value.substring(0, value.length.clamp(0, maxLength));
  }

  @override
  Future<void> submit({
    required InquiryType type,
    required String email,
    required String details,
    required String locale,
  }) async {
    final trimmedDetails = details.trim();
    final trimmedEmail = email.trim();
    if (trimmedDetails.isEmpty || trimmedDetails.length > 500) {
      throw ArgumentError('invalid details');
    }
    if (trimmedEmail.length > 254 ||
        (trimmedEmail.isNotEmpty && !isValidEmail(trimmedEmail))) {
      throw ArgumentError('invalid email');
    }
    final userId = await _api.ensureAuthenticatedUserId();
    final info = await _packageInfo();
    await _api.insert({
      'uid': userId,
      'inquiry_type': type.wire,
      if (trimmedEmail.isNotEmpty) 'email': trimmedEmail,
      'details': trimmedDetails,
      'platform': _platform(),
      'locale': _truncate(locale.trim(), 16),
      'app_version': _truncate(info.version, 40),
      'build_number': _truncate(info.buildNumber, 40),
    });
  }
}
