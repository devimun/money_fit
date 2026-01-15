// ThemeRepository 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_fit/core/repositories/theme_repository.dart';
import 'package:money_fit/core/models/theme_settings.dart';
import 'package:flutter/material.dart';

void main() {
  group('ThemeRepository', () {
    late ThemeRepository repository;

    setUp(() async {
      // SharedPreferences 초기화
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      repository = ThemeRepository(prefs);
    });

    group('loadSettings', () {
      test('저장된 설정이 없으면 기본 설정을 반환해야 함', () {
        // Act
        final settings = repository.loadSettings();

        // Assert
        expect(settings, equals(ThemeSettings.defaultSettings()));
        expect(settings.isDarkMode, isFalse);
        expect(settings.colorSeedValue, equals(0xFF825A3D)); // 기본 브라운 색상
        expect(settings.favoriteColors, isEmpty);
      });

      test('저장된 설정을 올바르게 불러와야 함', () async {
        // Arrange
        final testSettings = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: Colors.blue.toARGB32(),
          favoriteColors: [Colors.red.toARGB32(), Colors.green.toARGB32()],
        );
        await repository.saveSettings(testSettings);

        // Act
        final loadedSettings = repository.loadSettings();

        // Assert
        expect(loadedSettings, equals(testSettings));
        expect(loadedSettings.isDarkMode, isTrue);
        expect(loadedSettings.colorSeedValue, equals(Colors.blue.toARGB32()));
        expect(loadedSettings.favoriteColors, hasLength(2));
      });

      test('잘못된 JSON이 저장되어 있으면 기본 설정을 반환해야 함', () async {
        // Arrange
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('theme_settings', 'invalid json');
        repository = ThemeRepository(prefs);

        // Act
        final settings = repository.loadSettings();

        // Assert
        expect(settings, equals(ThemeSettings.defaultSettings()));
      });
    });

    group('saveSettings', () {
      test('설정을 올바르게 저장해야 함', () async {
        // Arrange
        final testSettings = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: Colors.purple.toARGB32(),
          favoriteColors: [Colors.orange.toARGB32()],
        );

        // Act
        final result = await repository.saveSettings(testSettings);

        // Assert
        expect(result, isTrue);
        
        // 저장된 설정을 다시 불러와서 확인
        final loadedSettings = repository.loadSettings();
        expect(loadedSettings, equals(testSettings));
      });

      test('빈 즐겨찾기 리스트도 올바르게 저장해야 함', () async {
        // Arrange
        final testSettings = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: Colors.teal.toARGB32(),
          favoriteColors: [],
        );

        // Act
        final result = await repository.saveSettings(testSettings);

        // Assert
        expect(result, isTrue);
        
        final loadedSettings = repository.loadSettings();
        expect(loadedSettings.favoriteColors, isEmpty);
      });

      test('큰 즐겨찾기 리스트도 올바르게 저장해야 함', () async {
        // Arrange
        final largeList = List.generate(50, (i) => Colors.primaries[i % Colors.primaries.length].toARGB32());
        final testSettings = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: Colors.amber.toARGB32(),
          favoriteColors: largeList,
        );

        // Act
        final result = await repository.saveSettings(testSettings);

        // Assert
        expect(result, isTrue);
        
        final loadedSettings = repository.loadSettings();
        expect(loadedSettings.favoriteColors, hasLength(50));
        expect(loadedSettings.favoriteColors, equals(largeList));
      });
    });

    group('clearSettings', () {
      test('저장된 설정을 삭제해야 함', () async {
        // Arrange
        final testSettings = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: Colors.indigo.toARGB32(),
          favoriteColors: [Colors.pink.toARGB32()],
        );
        await repository.saveSettings(testSettings);

        // Act
        final result = await repository.clearSettings();

        // Assert
        expect(result, isTrue);
        
        // 삭제 후 기본 설정이 반환되어야 함
        final loadedSettings = repository.loadSettings();
        expect(loadedSettings, equals(ThemeSettings.defaultSettings()));
      });

      test('설정이 없어도 clearSettings는 성공해야 함', () async {
        // Act
        final result = await repository.clearSettings();

        // Assert
        expect(result, isTrue);
      });
    });

    group('Round Trip Tests', () {
      test('여러 번 저장하고 불러와도 데이터가 유지되어야 함', () async {
        // Arrange
        final settings1 = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: Colors.red.toARGB32(),
          favoriteColors: [Colors.blue.toARGB32()],
        );
        final settings2 = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: Colors.green.toARGB32(),
          favoriteColors: [Colors.yellow.toARGB32(), Colors.cyan.toARGB32()],
        );

        // Act & Assert - 첫 번째 저장
        await repository.saveSettings(settings1);
        expect(repository.loadSettings(), equals(settings1));

        // Act & Assert - 두 번째 저장 (덮어쓰기)
        await repository.saveSettings(settings2);
        expect(repository.loadSettings(), equals(settings2));

        // Act & Assert - 삭제
        await repository.clearSettings();
        expect(repository.loadSettings(), equals(ThemeSettings.defaultSettings()));
      });

      test('모든 극단적인 값들이 올바르게 저장되고 불러와져야 함', () async {
        // Arrange - 극단적인 값들
        final extremeSettings = ThemeSettings(
          isDarkMode: true,
          colorSeedValue: 0xFFFFFFFF, // 흰색
          favoriteColors: [
            0xFF000000, // 검정
            0xFFFFFFFF, // 흰색
            0x00000000, // 완전 투명
            0xFF123456, // 임의의 색상
          ],
        );

        // Act
        await repository.saveSettings(extremeSettings);
        final loadedSettings = repository.loadSettings();

        // Assert
        expect(loadedSettings, equals(extremeSettings));
        expect(loadedSettings.colorSeedValue, equals(0xFFFFFFFF));
        expect(loadedSettings.favoriteColors, hasLength(4));
      });
    });

    group('Error Handling', () {
      test('동일한 설정을 여러 번 저장해도 문제없어야 함', () async {
        // Arrange
        final testSettings = ThemeSettings(
          isDarkMode: false,
          colorSeedValue: Colors.lime.toARGB32(),
          favoriteColors: [Colors.brown.toARGB32()],
        );

        // Act - 3번 저장
        await repository.saveSettings(testSettings);
        await repository.saveSettings(testSettings);
        final result = await repository.saveSettings(testSettings);

        // Assert
        expect(result, isTrue);
        expect(repository.loadSettings(), equals(testSettings));
      });
    });
  });
}
