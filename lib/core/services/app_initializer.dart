import 'dart:developer';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/services/notification_service.dart';
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
    final container = ProviderContainer();
    await container.read(notificationServiceProvider).init();

    return container;
  }
}
