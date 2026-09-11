import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sikera/app/core/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme widget smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.jagoCardRadius),
              boxShadow: AppTheme.jagoPocketShadow,
            ),
            child: const Text('Bank Jago Pocket Style'),
          ),
        ),
      ),
    );

    expect(find.text('Bank Jago Pocket Style'), findsOneWidget);
  });
}
