import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/config/app_environment.dart';
import 'package:money_fit/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Starts remote SDKs which enhance, but never gate, the local application.
///
/// This boundary deliberately lives outside `main`: bootstrap owns the point at
/// which an app has a usable local route, while remote SDK failures remain
/// best-effort. Constructor injection keeps platform initialization testable.
class OptionalRemoteCapabilities {
  OptionalRemoteCapabilities({
    FirebaseInitializer? initializeFirebase,
    SupabaseInitializer? initializeSupabase,
  }) : _initializeFirebase = initializeFirebase ?? _defaultFirebaseInitializer,
       _initializeSupabase = initializeSupabase ?? _defaultSupabaseInitializer;

  final FirebaseInitializer _initializeFirebase;
  final SupabaseInitializer _initializeSupabase;

  Future<void> start(AppEnvironment environment) async {
    await Future.wait([
      _startFirebase(environment),
      _startSupabase(environment),
    ]);
  }

  Future<void> _startFirebase(AppEnvironment environment) async {
    if (!environment.firebase.isAvailable) return;
    await _ignoreFailure(
      () => _initializeFirebase(DefaultFirebaseOptions.currentPlatform),
    );
  }

  Future<void> _startSupabase(AppEnvironment environment) async {
    final configuration = environment.supabase.value;
    if (configuration == null) return;
    await _ignoreFailure(
      () => _initializeSupabase(
        url: configuration.url.toString(),
        anonKey: configuration.anonKey,
      ),
    );
  }

  Future<void> _ignoreFailure(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Optional remote capabilities must never prevent local app use.
    }
  }
}

typedef FirebaseInitializer = Future<void> Function(FirebaseOptions options);
typedef SupabaseInitializer =
    Future<void> Function({required String url, required String anonKey});

Future<void> _defaultFirebaseInitializer(FirebaseOptions options) =>
    Firebase.initializeApp(options: options);

Future<void> _defaultSupabaseInitializer({
  required String url,
  required String anonKey,
}) => Supabase.initialize(url: url, anonKey: anonKey);

final optionalRemoteCapabilitiesProvider = Provider<OptionalRemoteCapabilities>(
  (ref) => OptionalRemoteCapabilities(),
);
