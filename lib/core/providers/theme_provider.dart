/// Theme Provider - Manages app theme state with AppThemeColors integration
/// Provides light/dark themes using the new theme system
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_fit/core/theme/app_theme_generator.dart';
import 'package:money_fit/core/theme/app_text_styles.dart';
import 'package:money_fit/core/theme/theme_extensions.dart';
import 'package:money_fit/core/repositories/theme_repository.dart';
import 'package:money_fit/core/models/theme_settings.dart';
import 'package:money_fit/core/providers/shared_preferences_provider.dart';

/// Provides ThemeRepository
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeRepository(prefs);
});

/// StateNotifier for managing theme seed color
class ThemeSeedColorNotifier extends StateNotifier<Color> {
  ThemeSeedColorNotifier(this._repository) : super(AppThemeGenerator.defaultSeed) {
    _loadSeedColor();
  }

  final ThemeRepository _repository;

  void _loadSeedColor() {
    final settings = _repository.loadSettings();
    state = settings.colorSeed;
  }

  Future<void> setSeedColor(Color color, List<Color> favoriteColors) async {
    final settings = _repository.loadSettings();
    final updatedSettings = settings.copyWith(
      colorSeedValue: color.toARGB32(),
      favoriteColors: favoriteColors.map((c) => c.toARGB32()).toList(),
    );
    
    final success = await _repository.saveSettings(updatedSettings);
    if (success) {
      state = color;
    }
  }

  List<Color> getFavoriteColors() {
    final settings = _repository.loadSettings();
    return settings.favoriteColorObjects;
  }
}


/// StateNotifier for managing dark mode state
class ThemeModeNotifier extends StateNotifier<bool> {
  ThemeModeNotifier(this._repository) : super(false) {
    _loadDarkMode();
  }

  final ThemeRepository _repository;

  void _loadDarkMode() {
    final settings = _repository.loadSettings();
    state = settings.isDarkMode;
  }

  /// 기존 User.isDarkMode 값을 ThemeSettings로 마이그레이션합니다.
  /// 앱 시작 시 한 번만 호출되어야 합니다.
  Future<void> migrateFromUserSettings(bool userIsDarkMode) async {
    final success = await _repository.migrateFromUserDarkMode(userIsDarkMode);
    if (success) {
      // 마이그레이션 후 상태 다시 로드
      _loadDarkMode();
    }
  }

  Future<void> toggleDarkMode() async {
    final settings = _repository.loadSettings();
    final updatedSettings = settings.copyWith(
      isDarkMode: !state,
    );
    
    final success = await _repository.saveSettings(updatedSettings);
    if (success) {
      state = !state;
    }
  }

  Future<void> setDarkMode(bool isDark) async {
    final settings = _repository.loadSettings();
    final updatedSettings = settings.copyWith(
      isDarkMode: isDark,
    );
    
    final success = await _repository.saveSettings(updatedSettings);
    if (success) {
      state = isDark;
    }
  }
}

/// StateNotifier for managing font size scale
class FontSizeNotifier extends StateNotifier<double> {
  FontSizeNotifier(this._repository) : super(1.0) {
    _loadFontSize();
  }

  final ThemeRepository _repository;

  void _loadFontSize() {
    final settings = _repository.loadSettings();
    state = settings.fontSizeScale;
  }

  /// 현재 폰트 크기 옵션 반환
  FontSizeOption get currentOption => FontSizeOption.fromScale(state);

  Future<void> setFontSize(double scale) async {
    // 유효한 스케일 값인지 검증
    if (!FontSizeOption.isValidScale(scale)) {
      scale = 1.0; // 기본값으로 폴백
    }
    
    final settings = _repository.loadSettings();
    final updatedSettings = settings.copyWith(fontSizeScale: scale);
    
    final success = await _repository.saveSettings(updatedSettings);
    if (success) {
      state = scale;
    }
  }

  /// FontSizeOption으로 폰트 크기 설정
  Future<void> setFontSizeOption(FontSizeOption option) async {
    await setFontSize(option.scale);
  }
}

/// Provides the seed color for theme generation with state management
final themeSeedColorProvider = StateNotifierProvider<ThemeSeedColorNotifier, Color>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return ThemeSeedColorNotifier(repository);
});

/// Provides the dark mode state with state management
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, bool>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return ThemeModeNotifier(repository);
});

/// Provides the font size scale with state management
final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return FontSizeNotifier(repository);
});


/// Provides the light theme with AppThemeColors extension
final lightThemeProvider = Provider<ThemeData>((ref) {
  final seedColor = ref.watch(themeSeedColorProvider);
  final fontSizeScale = ref.watch(fontSizeProvider);
  final appColors = AppThemeGenerator.lightFromSeed(seedColor);
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: appColors.screenBackground,
    primaryColor: appColors.brandPrimary,
    fontFamily: 'Pretendard Variable',
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: appColors.selectedButtonBackground,
        foregroundColor: appColors.textOnBrand,
        minimumSize: const Size(double.maxFinite, 50),
      ),
    ),
    
    colorScheme: ColorScheme.light(
      primary: appColors.brandPrimary,
      secondary: appColors.brandSecondary,
      surface: appColors.cardBackground,
      error: appColors.error,
      onPrimary: appColors.textOnBrand,
      onSecondary: appColors.textOnBrand,
      onSurface: appColors.textPrimary,
      onError: appColors.textOnBrand,
    ),
    
    textTheme: _buildTextTheme(appColors.textPrimary, appColors.textSecondary, fontSizeScale),
    
    appBarTheme: AppBarTheme(
      backgroundColor: appColors.cardBackground,
      centerTitle: false,
      elevation: 1,
      shadowColor: appColors.cardBackground,
      titleTextStyle: AppTextStyles.h3.copyWith(
        color: appColors.brandPrimary,
        fontSize: AppTextStyles.h3.fontSize! * fontSizeScale,
      ),
      iconTheme: IconThemeData(color: appColors.textPrimary),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appColors.screenBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: appColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: appColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: appColors.brandPrimary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: appColors.error),
      ),
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: appColors.cardBackground,
      selectedItemColor: appColors.brandPrimary,
      unselectedItemColor: appColors.brandSecondary,
      selectedLabelStyle: AppTextStyles.navSelected.copyWith(
        fontSize: AppTextStyles.navSelected.fontSize! * fontSizeScale,
      ),
      unselectedLabelStyle: AppTextStyles.nav.copyWith(
        fontSize: AppTextStyles.nav.fontSize! * fontSizeScale,
      ),
      type: BottomNavigationBarType.fixed,
    ),
  ).withAppColors(appColors);
});


/// Provides the dark theme with AppThemeColors extension
final darkThemeProvider = Provider<ThemeData>((ref) {
  final seedColor = ref.watch(themeSeedColorProvider);
  final fontSizeScale = ref.watch(fontSizeProvider);
  final appColors = AppThemeGenerator.darkFromSeed(seedColor);
  
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: appColors.screenBackground,
    primaryColor: appColors.brandPrimary,
    fontFamily: 'Pretendard Variable',
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: appColors.selectedButtonBackground,
        foregroundColor: appColors.textOnBrand,
        minimumSize: const Size(double.maxFinite, 50),
      ),
    ),
    
    colorScheme: ColorScheme.dark(
      primary: appColors.brandPrimary,
      secondary: appColors.brandSecondary,
      surface: appColors.cardBackground,
      error: appColors.error,
      onPrimary: appColors.textOnBrand,
      onSecondary: appColors.textOnBrand,
      onSurface: appColors.textPrimary,
      onError: appColors.textOnBrand,
      outline: appColors.border,
    ),
    
    textTheme: _buildTextTheme(appColors.textPrimary, appColors.textSecondary, fontSizeScale),
    
    appBarTheme: AppBarTheme(
      backgroundColor: appColors.screenBackground,
      elevation: 1,
      shadowColor: Colors.black,
      titleTextStyle: AppTextStyles.h3.copyWith(
        color: appColors.textPrimary,
        fontSize: AppTextStyles.h3.fontSize! * fontSizeScale,
      ),
      iconTheme: IconThemeData(color: appColors.textPrimary),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: appColors.cardBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: appColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: appColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: appColors.brandPrimary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: appColors.error),
      ),
    ),
    
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: appColors.cardBackground,
      selectedItemColor: appColors.brandPrimary,
      unselectedItemColor: appColors.brandSecondary,
      selectedLabelStyle: AppTextStyles.navSelected.copyWith(
        fontSize: AppTextStyles.navSelected.fontSize! * fontSizeScale,
      ),
      unselectedLabelStyle: AppTextStyles.nav.copyWith(
        fontSize: AppTextStyles.nav.fontSize! * fontSizeScale,
      ),
      type: BottomNavigationBarType.fixed,
    ),
  ).withAppColors(appColors);
});

/// Helper function to build TextTheme with font size scale
TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor, double fontSizeScale) {
  return TextTheme(
    displayLarge: AppTextStyles.h1.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.h1.fontSize! * fontSizeScale,
    ),
    displayMedium: AppTextStyles.h2.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.h2.fontSize! * fontSizeScale,
    ),
    displaySmall: AppTextStyles.h3.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.h3.fontSize! * fontSizeScale,
    ),
    headlineMedium: AppTextStyles.h4.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.h4.fontSize! * fontSizeScale,
    ),
    bodyLarge: AppTextStyles.bodyL.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.bodyL.fontSize! * fontSizeScale,
    ),
    bodyMedium: AppTextStyles.bodyM.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.bodyM.fontSize! * fontSizeScale,
    ),
    bodySmall: AppTextStyles.bodyS.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.bodyS.fontSize! * fontSizeScale,
    ),
    labelLarge: AppTextStyles.bodyM.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.bodyM.fontSize! * fontSizeScale,
    ),
    labelMedium: AppTextStyles.bodyMM.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.bodyMM.fontSize! * fontSizeScale,
    ),
    labelSmall: AppTextStyles.caption.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.caption.fontSize! * fontSizeScale,
    ),
    titleSmall: AppTextStyles.captionOnDate.copyWith(
      color: secondaryColor,
      fontSize: AppTextStyles.captionOnDate.fontSize! * fontSizeScale,
    ),
    titleMedium: AppTextStyles.bodyL2.copyWith(
      color: primaryColor,
      fontSize: AppTextStyles.bodyL2.fontSize! * fontSizeScale,
    ),
  );
}
