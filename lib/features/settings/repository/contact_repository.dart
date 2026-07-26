import 'dart:io';
import 'package:money_fit/features/settings/model/inquiry_type.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactRepository {
  ContactRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;
  final SupabaseClient _client;

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
    if (trimmedEmail.length > 254) {
      throw ArgumentError('invalid email');
    }
    var user = _client.auth.currentUser;
    user ??= (await _client.auth.signInAnonymously()).user;
    if (user == null) {
      throw const AuthException('Anonymous authentication failed');
    }
    final info = await PackageInfo.fromPlatform();
    await _client.from('user_contact').insert({
      'uid': user.id,
      'inquiry_type': type.wire,
      if (trimmedEmail.isNotEmpty) 'email': trimmedEmail,
      'details': trimmedDetails,
      'platform': Platform.isIOS
          ? 'ios'
          : (Platform.isAndroid ? 'android' : 'other'),
      'locale': locale,
      'app_version': info.version,
      'build_number': info.buildNumber,
    });
  }
}
