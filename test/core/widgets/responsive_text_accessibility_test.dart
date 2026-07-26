import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_fit/core/widgets/responsive_text/responsive_text.dart';

void main() {
  testWidgets('title preserves the full semantic label at a large text scale', (
    tester,
  ) async {
    const title = 'A longer accessible title for the current budget';
    final semantics = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(
              body: SizedBox(
                width: 180,
                child: ResponsiveTitleText(text: title),
              ),
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.text(title));
      expect(text.maxLines, ResponsiveTitleText.maxLines);
      expect(find.byType(FittedBox), findsNothing);
      expect(
        tester.getSemantics(find.text(title)),
        matchesSemantics(label: title),
      );
    } finally {
      semantics.dispose();
    }
  });

  testWidgets('message can use two lines without shrinking user text', (
    tester,
  ) async {
    const message = 'Your monthly budget is close to its spending limit.';

    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SizedBox(
              width: 180,
              child: ResponsiveMessageText(text: message),
            ),
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text(message));
    expect(text.maxLines, ResponsiveMessageText.maxLines);
    expect(find.byType(FittedBox), findsNothing);
  });
}
