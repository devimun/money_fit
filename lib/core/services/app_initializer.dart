import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/services/notification_service.dart';
import 'package:money_fit/core/services/ad_service.dart';
import 'package:money_fit/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppInitializer {
  static Future<ProviderContainer> initialize() async {
    FlutterError.onError = (details) {
      log(details.exceptionAsString(), stackTrace: details.stack);
    };

    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load();

    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
    await initializeDateFormatting('ko_KR', null);
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // AdMob 초기화
    await AdService.initialize();

    // 전면 광고 미리 로드
    InterstitialAdManager.instance.loadAd();

    final container = ProviderContainer();
    await container.read(notificationServiceProvider).init();

    return container;
  }
}
