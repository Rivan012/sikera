import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/core/widgets/state_view.dart';

void main() {
  Future<void> mount(
    WidgetTester tester,
    StateView state, {
    required bool dark,
    double height = 180,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(320, height);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.darkTheme : AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: Scaffold(body: state),
      ),
    );
    await tester.pump();
  }

  for (final dark in [false, true]) {
    testWidgets('Loading names the request in ${dark ? 'dark' : 'light'}', (
      tester,
    ) async {
      await mount(
        tester,
        const StateView(
          isLoading: true,
          loadingMessage: 'Memuat profil...',
          child: Text('Isi profil'),
        ),
        dark: dark,
        height: 480,
      );
      expect(find.text('Memuat profil...'), findsOneWidget);
      expect(find.text('Isi profil'), findsNothing);
      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.semanticsLabel, 'Memuat profil...');
      expect(
        indicator.color,
        (dark ? AppTheme.darkTheme : AppTheme.lightTheme).colorScheme.primary,
      );
      expect(tester.takeException(), isNull);
    });

    for (final error in [false, true]) {
      testWidgets(
        '${error ? 'Error' : 'Empty'} recovery fits 320x180 at 200% text, dark=$dark',
        (tester) async {
          var retries = 0;
          const message =
              'Catatan belum dapat ditampilkan. Periksa koneksi lalu muat ulang untuk melihat catatan kesehatan.';
          await mount(
            tester,
            StateView(
              isLoading: false,
              isEmpty: !error,
              errorMessage: error ? message : null,
              emptyMessage: message,
              onRetry: () => retries++,
              child: const Text('Isi catatan'),
            ),
            dark: dark,
          );
          expect(find.text(message), findsOneWidget);
          expect(find.text('Isi catatan'), findsNothing);
          expect(tester.takeException(), isNull);

          final retry = error
              ? find.byType(ElevatedButton)
              : find.byType(OutlinedButton);
          await tester.ensureVisible(retry);
          await tester.pumpAndSettle();
          expect(tester.getTopLeft(retry).dy, greaterThanOrEqualTo(0));
          expect(tester.getBottomRight(retry).dy, lessThanOrEqualTo(180));
          await tester.tap(retry);
          await tester.pumpAndSettle();
          expect(retries, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
