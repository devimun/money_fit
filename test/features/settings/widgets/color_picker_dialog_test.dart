import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/color_picker_dialog.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/hsv_color_picker.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/preset_colors_grid.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/recent_colors_grid.dart';
import 'package:money_fit/features/settings/widgets/theme_customization/theme_preview_card.dart';

void main() {
  group('ColorPickerDialog', () {
    testWidgets('renders all sections correctly', (tester) async {
      const Color initialColor = Color(0xFF1976D2);
      final List<Color> recentColors = [
        const Color(0xFFD32F2F),
        const Color(0xFF388E3C),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPickerDialog(
              initialColor: initialColor,
              recentColors: recentColors,
              onColorSelected: (_, __) {},
            ),
          ),
        ),
      );

      // Check header
      expect(find.text('테마 색상 선택'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Check sections
      expect(find.text('빠른 선택'), findsOneWidget);
      expect(find.text('최근 사용 색상'), findsOneWidget);
      expect(find.text('자유 선택'), findsOneWidget);

      // Check widgets
      expect(find.byType(ThemePreviewCard), findsOneWidget);
      expect(find.byType(PresetColorsGrid), findsOneWidget);
      expect(find.byType(RecentColorsGrid), findsOneWidget);
      expect(find.byType(HSVColorPicker), findsOneWidget);

      // Check footer buttons
      expect(find.text('취소'), findsOneWidget);
      expect(find.text('적용'), findsOneWidget);
    });

    testWidgets('hides recent colors section when empty', (tester) async {
      const Color initialColor = Color(0xFF1976D2);
      const List<Color> recentColors = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPickerDialog(
              initialColor: initialColor,
              recentColors: recentColors,
              onColorSelected: (_, __) {},
            ),
          ),
        ),
      );

      // Recent colors section should not be visible
      expect(find.text('최근 사용 색상'), findsNothing);
      expect(find.byType(RecentColorsGrid), findsNothing);

      // Other sections should still be visible
      expect(find.text('빠른 선택'), findsOneWidget);
      expect(find.text('자유 선택'), findsOneWidget);
    });

    testWidgets('updates selected color when preset color is tapped',
        (tester) async {
      const Color initialColor = Color(0xFF1976D2);
      Color? selectedColor;
      List<Color>? updatedFavorites;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPickerDialog(
              initialColor: initialColor,
              recentColors: const [],
              onColorSelected: (color, favorites) {
                selectedColor = color;
                updatedFavorites = favorites;
              },
            ),
          ),
        ),
      );

      // Tap confirm button (with initial color)
      await tester.tap(find.text('적용'));
      await tester.pumpAndSettle();

      // Verify callback was called
      expect(selectedColor, isNotNull);
      expect(updatedFavorites, isNotNull);
      expect(updatedFavorites!.length, equals(1));
      expect(selectedColor, equals(initialColor));
    });

    testWidgets('closes dialog when cancel button is tapped', (tester) async {
      const Color initialColor = Color(0xFF1976D2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ColorPickerDialog(
                      initialColor: initialColor,
                      recentColors: const [],
                      onColorSelected: (_, __) {},
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('테마 색상 선택'), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('취소'));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('테마 색상 선택'), findsNothing);
    });

    testWidgets('closes dialog when close icon is tapped', (tester) async {
      const Color initialColor = Color(0xFF1976D2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ColorPickerDialog(
                      initialColor: initialColor,
                      recentColors: const [],
                      onColorSelected: (_, __) {},
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Dialog should be visible
      expect(find.text('테마 색상 선택'), findsOneWidget);

      // Tap close icon
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.text('테마 색상 선택'), findsNothing);
    });

    testWidgets('adds selected color to favorites on confirm', (tester) async {
      const Color initialColor = Color(0xFF1976D2);
      final List<Color> recentColors = [
        const Color(0xFF388E3C),
      ];

      Color? selectedColor;
      List<Color>? updatedFavorites;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPickerDialog(
              initialColor: initialColor,
              recentColors: recentColors,
              onColorSelected: (color, favorites) {
                selectedColor = color;
                updatedFavorites = favorites;
              },
            ),
          ),
        ),
      );

      // Tap confirm button (with initial color)
      await tester.tap(find.text('적용'));
      await tester.pumpAndSettle();

      // Verify new color was added to front of favorites
      expect(selectedColor, equals(initialColor));
      expect(updatedFavorites, isNotNull);
      expect(updatedFavorites!.first, equals(initialColor));
      expect(updatedFavorites!.length, equals(2)); // initial + existing
    });

    testWidgets('limits favorites to 8 colors', (tester) async {
      const Color initialColor = Color(0xFF1976D2);
      final List<Color> recentColors = List.generate(
        8,
        (index) => Color(0xFF000000 + (index * 0x111111)),
      );

      List<Color>? updatedFavorites;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPickerDialog(
              initialColor: initialColor,
              recentColors: recentColors,
              onColorSelected: (_, favorites) {
                updatedFavorites = favorites;
              },
            ),
          ),
        ),
      );

      // Tap confirm button
      await tester.tap(find.text('적용'));
      await tester.pumpAndSettle();

      // Should still have max 8 colors
      expect(updatedFavorites, isNotNull);
      expect(updatedFavorites!.length, equals(8));
      // New color should be at front
      expect(updatedFavorites!.first, equals(initialColor));
    });

    testWidgets('removes duplicate color before adding to favorites',
        (tester) async {
      const Color duplicateColor = Color(0xFF1976D2);
      final List<Color> recentColors = [
        duplicateColor,
        const Color(0xFFD32F2F),
        const Color(0xFF388E3C),
      ];

      List<Color>? updatedFavorites;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPickerDialog(
              initialColor: duplicateColor,
              recentColors: recentColors,
              onColorSelected: (_, favorites) {
                updatedFavorites = favorites;
              },
            ),
          ),
        ),
      );

      // Tap confirm button
      await tester.tap(find.text('적용'));
      await tester.pumpAndSettle();

      // Should not have duplicate
      expect(updatedFavorites, isNotNull);
      expect(updatedFavorites!.length, equals(3)); // Same as before
      expect(updatedFavorites!.first, equals(duplicateColor));
      // Count occurrences of duplicate color
      final int count = updatedFavorites!
          .where((c) => c.toARGB32() == duplicateColor.toARGB32())
          .length;
      expect(count, equals(1)); // Should only appear once
    });

    testWidgets('dialog has proper constraints', (tester) async {
      const Color initialColor = Color(0xFF1976D2);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPickerDialog(
              initialColor: initialColor,
              recentColors: const [],
              onColorSelected: (_, __) {},
            ),
          ),
        ),
      );

      // Find the dialog
      final Finder dialogFinder = find.byType(Dialog);
      expect(dialogFinder, findsOneWidget);

      // Find the container with constraints inside the dialog
      final Finder containerFinder = find.descendant(
        of: dialogFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints != null &&
              widget.constraints!.maxWidth == 500,
        ),
      );

      expect(containerFinder, findsOneWidget);

      final Container dialogContainer = tester.widget(containerFinder);

      // Verify constraints
      expect(dialogContainer.constraints!.maxWidth, equals(500));
      expect(dialogContainer.constraints!.maxHeight, equals(700));
    });
  });
}
