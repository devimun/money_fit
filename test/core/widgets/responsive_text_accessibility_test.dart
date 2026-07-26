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

  testWidgets(
    'button, label, and navigation labels preserve multilingual text scale without overflow',
    (tester) async {
      const button = '계속 진행하여 월간 예산을 설정합니다';
      const label = 'Límite mensual disponible para gastos esenciales';
      const navigation = '設定と通知';
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.5)),
            child: Scaffold(
              body: SizedBox(
                width: 320,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: null,
                        child: ResponsiveButtonText(text: button),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: ResponsiveLabelText(text: label),
                    ),
                    SizedBox(
                      width: 120,
                      child: ResponsiveNavText(text: navigation),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(FittedBox), findsNothing);

      for (final value in [button, label, navigation]) {
        final text = tester.widget<Text>(find.text(value));
        expect(text.maxLines, 1);
        expect(text.softWrap, isFalse);
        expect(text.overflow, TextOverflow.ellipsis);
      }
    },
  );
}
