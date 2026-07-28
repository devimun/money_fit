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
  Future<void>? _firebaseStart;
  Future<void>? _supabaseStart;
  CapabilityState<SupabaseConfiguration> _supabase =
      CapabilityUnavailable<SupabaseConfiguration>(
        RemoteCapability.supabase,
        reason: RemoteCapabilityUnavailableReason.notInitialized,
        message: 'Supabase initialization has not completed.',
      );

  /// The runtime result of optional Supabase initialization.
  ///
  /// A valid build configuration is not enough to safely read the SDK
  /// singleton: feedback/contact composition must wait for this state to be
  /// available, and otherwise use its local unavailable implementation.
  CapabilityState<SupabaseConfiguration> get supabase => _supabase;

  Future<void> start(AppEnvironment environment) async {
    await Future.wait([startFirebase(environment), startSupabase(environment)]);
  }

  /// Firebase can be needed for the update decision before other optional
  /// capabilities are started. The same future is reused later by [start].
  Future<void> startFirebase(AppEnvironment environment) =>
      _firebaseStart ??= _startFirebase(environment);

  /// Concurrent callers share one initialization attempt. A failed optional
  /// attempt is deliberately not cached, so a later local retry can recover
  /// without restarting the application.
  Future<void> startSupabase(AppEnvironment environment) {
    if (_supabase.isAvailable) return Future<void>.value();
    return _supabaseStart ??= _startSupabase(
      environment,
    ).whenComplete(() => _supabaseStart = null);
  }

  Future<void> _startFirebase(AppEnvironment environment) async {
    if (!environment.firebase.isAvailable) return;
    await _ignoreFailure(
      () => _initializeFirebase(DefaultFirebaseOptions.currentPlatform),
    );
  }

  Future<void> _startSupabase(AppEnvironment environment) async {
    final configuration = environment.supabase.value;
    if (configuration == null) {
      _supabase = environment.supabase;
      return;
    }
    try {
      await _initializeSupabase(
        url: configuration.url.toString(),
        anonKey: configuration.anonKey,
      );
      _supabase = CapabilityAvailable<SupabaseConfiguration>(configuration);
    } catch (error, stackTrace) {
      _supabase = CapabilityUnavailable<SupabaseConfiguration>(
        RemoteCapability.supabase,
        reason: RemoteCapabilityUnavailableReason.initializationFailed,
        message: 'Supabase initialization failed.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
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
