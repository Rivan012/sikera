import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sikera/app/core/services/storage_service.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/data/models/period_assessment_model.dart';
import 'package:sikera/app/data/models/selfcare_model.dart';
import 'package:sikera/app/modules/selfcare/period_page.dart';
import 'package:sikera/app/modules/selfcare/selfcare_controller.dart';
import 'package:sikera/app/modules/selfcare/blood_guide_page.dart';
import 'package:sikera/app/modules/selfcare/hygiene_guide_page.dart';
import 'package:sikera/app/routes/app_pages.dart';
import 'period_integration_test.dart' show predictionFixture;

class _UiController extends SelfcareController {
  int saves = 0;
  int refreshes = 0;
  int simulations = 0;
  @override
  // ignore: must_call_super
  void onInit() {}
  @override
  Future<void> fetchPeriodHistory() async {
    refreshes++;
  }

  @override
  Future<void> fetchPeriodPrediction() async {
    refreshes++;
  }

  @override
  Future<void> submitPeriod() async {
    saves++;
    periodError.value = validatePeriod() ?? '';
  }

  @override
  Future<void> calculatePbac() async {
    pbacResult.value = PeriodAssessmentResult(
      totalScore: pbacCounts['pads_heavy']! * 20,
      category: 'Hasil uji PBAC',
    );
  }

  @override
  Future<void> calculateWalidd() async {
    waliddResult.value = const PeriodAssessmentResult(
      totalScore: 4,
      maxScore: 12,
      category: 'Hasil uji WaLIDD',
    );
  }

  @override
  Future<PeriodPredictionModel?> calculatePeriodSimulation({
    required DateTime lastPeriodDate,
    required int cycleLength,
    required int periodDuration,
    List<int>? cycleHistory,
    DateTime? targetDate,
    int projectionCount = 3,
  }) async {
    simulations++;
    simulationResult.value = PeriodPredictionModel.fromJson(
      predictionFixture(),
    );
    return simulationResult.value;
  }

  @override
  Future<void> fetchBloodGuides({bool forceRefresh = false}) async {
    bloodGuides.assignAll([
      BloodGuideModel(
        colorName: 'Warna uji',
        hexColor: '#0077B6',
        status: 'Status uji',
        description: 'Panduan dari respons uji.',
      ),
    ]);
  }

  @override
  Future<void> fetchHygieneGuides({bool forceRefresh = false}) async {
    hygieneGuides.assignAll([
      HygieneGuideModel(
        step: 1,
        title: 'Panduan uji',
        description: 'Isi panduan dari respons uji.',
      ),
    ]);
  }
}

void main() {
  late _UiController controller;
  final capture = GlobalKey();

  ThemeData previewTheme(ThemeData theme) {
    if (Platform.environment['SIKERA_CAPTURE_PERIOD'] != '1') return theme;
    ButtonStyle? fontStyle(ButtonStyle? style) => style?.copyWith(
      textStyle: WidgetStateProperty.resolveWith(
        (states) =>
            style.textStyle?.resolve(states)?.copyWith(fontFamily: 'Roboto'),
      ),
    );
    return theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Roboto',
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: fontStyle(theme.outlinedButtonTheme.style),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: fontStyle(theme.elevatedButtonTheme.style),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: fontStyle(theme.filledButtonTheme.style),
      ),
      textButtonTheme: TextButtonThemeData(
        style: fontStyle(theme.textButtonTheme.style),
      ),
    );
  }

  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({'auth_token': 'test-token'});
    await StorageService.init();
    controller = _UiController();
    controller.isFemale.value = true;
    controller.summaryData.value = {'is_female': true};
    Get.put<SelfcareController>(controller);
  });
  tearDown(() => Get.reset());

  Future<void> mount(
    WidgetTester tester, {
    double width = 390,
    bool dark = false,
    double scale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: previewTheme(AppTheme.lightTheme),
        darkTheme: previewTheme(AppTheme.darkTheme),
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: RepaintBoundary(key: capture, child: const PeriodPage()),
        getPages: [
          GetPage(
            name: Routes.SELFCARE_BLOOD_GUIDE,
            page: () => const BloodGuidePage(),
          ),
          GetPage(
            name: Routes.SELFCARE_HYGIENE_GUIDE,
            page: () => const HygieneGuidePage(),
          ),
          GetPage(
            name: Routes.LOGIN,
            page: () => const Scaffold(body: Text('Halaman masuk')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder target) async {
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    for (final size in [
      (320.0, 1.0),
      (390.0, 1.0),
      (720.0, 1.0),
      (320.0, 2.0),
    ]) {
      testWidgets('Form, PBAC, WaLIDD and calendar fit $size dark=$dark', (
        tester,
      ) async {
        controller.periodPredictions.value = PeriodPredictionModel.fromJson(
          predictionFixture(),
        );
        await mount(tester, width: size.$1, scale: size.$2, dark: dark);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byKey(const ValueKey('save-period')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tap(tester, find.text('Kalkulator'));
        await tap(tester, find.widgetWithText(ChoiceChip, 'PBAC'));
        expect(tester.takeException(), isNull);
        await tap(tester, find.text('Hitung skor PBAC'));
        expect(tester.takeException(), isNull);
        await tap(tester, find.widgetWithText(ChoiceChip, 'WaLIDD'));
        await tap(tester, find.text('Hitung skor WaLIDD'));
        expect(tester.takeException(), isNull);
        await tap(tester, find.text('Prediksi'));
        expect(find.text('Kalender perkiraan'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tap(tester, find.byTooltip('Bulan berikutnya'));
        expect(find.text('Okt 2026'), findsOneWidget);
        await tap(tester, find.byTooltip('Bulan sebelumnya'));
        expect(find.text('Sep 2026'), findsOneWidget);
      });
    }
  }

  testWidgets('Invalid form cannot submit and date picker can be canceled', (
    tester,
  ) async {
    await mount(tester);
    await tap(tester, find.text('Tanggal mulai: Pilih tanggal'));
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.startDate.value, isNull);
    await tap(tester, find.byKey(const ValueKey('save-period')));
    expect(controller.saves, 0);
    expect(find.text('Pilih keteraturan siklus.'), findsOneWidget);
  });

  testWidgets('Form controls, date duration, keyboard and save feedback work', (
    tester,
  ) async {
    await mount(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    expect(FocusManager.instance.primaryFocus, isNotNull);
    await tap(tester, find.byType(DropdownButtonFormField<bool>));
    await tap(tester, find.text('Teratur').last);
    expect(controller.isRegular.value, isTrue);
    await tap(tester, find.text('Tanggal mulai: Pilih tanggal'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(controller.startDate.value, isNotNull);
    await tap(tester, find.text('Tanggal selesai: Pilih tanggal'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Durasi otomatis: 1 hari'), findsOneWidget);
    await tap(tester, find.text('Haid masih berlangsung'));
    expect(controller.endDate.value, isNull);
    await tap(tester, find.text('Sedang').first);
    await tap(tester, find.text('Deras').last);
    expect(controller.flowLevel.value, 'deras');
    await tap(tester, find.text('Merah terang'));
    await tap(tester, find.text('Cokelat').last);
    expect(controller.flowColor.value, 'Cokelat');
    await tap(tester, find.text('Sedang'));
    await tap(tester, find.text('Cair / encer').last);
    expect(controller.bloodConsistency.value, 'Cair / Encer');
    await tap(tester, find.byType(SwitchListTile));
    expect(controller.includePbac.value, isTrue);
    await tap(tester, find.byTooltip('Tambah Pembalut penuh'));
    await tap(tester, find.text('Hitung skor PBAC'));
    expect(controller.pbacResult.value, isNotNull);
    await tap(tester, find.byType(Slider));
    expect(controller.painScore.value, greaterThan(0));
    await tap(tester, find.text('Tidak terganggu'));
    await tap(tester, find.text('Sedikit terganggu').last);
    await tap(tester, find.widgetWithText(FilterChip, 'Perut bawah'));
    expect(controller.workingAbility.value, 1);
    expect(controller.painLocations, ['perut_bawah']);
    final days = find.byWidgetPredicate(
      (widget) =>
          widget is TextFormField &&
          widget.controller == controller.painDaysController,
    );
    await tester.ensureVisible(days);
    await tester.enterText(days, '2');
    await tap(tester, find.text('Hitung skor WaLIDD'));
    expect(controller.waliddResult.value, isNotNull);
    await tap(tester, find.widgetWithText(FilterChip, 'Kram Perut'));
    expect(controller.selectedSymptoms, ['Kram Perut']);
    await tap(tester, find.byKey(const ValueKey('save-period')));
    expect(controller.saves, 1);
    expect(controller.periodError.value, isEmpty);
    controller.periodSuccess.value =
        'Catatan haid berhasil disimpan. +10 poin.';
    await tester.pumpAndSettle();
    await tap(tester, find.text('Lihat prediksi'));
    expect(find.text('Belum ada prediksi'), findsOneWidget);
    await tap(tester, find.text('Catatan'));
    await tap(tester, find.text('Lihat riwayat'));
    expect(find.text('Belum ada catatan haid'), findsOneWidget);
    await tap(tester, find.text('Catatan'));
    await tap(tester, find.text('Buat catatan baru'));
    expect(controller.startDate.value, isNull);
    expect(controller.periodSuccess.value, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('PBAC inputs update and clear previous result', (tester) async {
    await mount(tester);
    await tap(tester, find.text('Kalkulator'));
    await tap(tester, find.widgetWithText(ChoiceChip, 'PBAC'));
    await tap(tester, find.byTooltip('Tambah Pembalut penuh'));
    expect(controller.pbacCounts['pads_heavy'], 1);
    expect(find.text('1'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.byWidgetPredicate(
              (widget) =>
                  widget is IconButton &&
                  widget.tooltip == 'Kurangi Pembalut penuh',
            ),
          )
          .onPressed,
      isNotNull,
    );
    await tap(tester, find.text('Hitung skor PBAC'));
    expect(controller.pbacResult.value!.totalScore, 20);
    await tap(tester, find.byTooltip('Kurangi Pembalut penuh'));
    expect(controller.pbacResult.value, isNull);
    expect(controller.pbacCounts['pads_heavy'], 0);
  });

  testWidgets('Simulation validates dates, runs and clears stale results', (
    tester,
  ) async {
    await StorageService.clearAuth();
    await mount(tester);
    await tap(tester, find.text('Hitung perkiraan siklus'));
    expect(controller.simulations, 0);
    expect(
      controller.simulationError.value,
      'Pilih hari pertama haid terakhir.',
    );
    await tap(tester, find.text('Hari pertama haid terakhir: Pilih tanggal'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tap(tester, find.text('Hitung perkiraan siklus'));
    expect(controller.simulations, 1);
    expect(controller.simulationResult.value, isNotNull);
    await tap(tester, find.text('Detail perhitungan'));
    final duration = find.ancestor(
      of: find.text('Durasi haid'),
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(duration);
    await tester.enterText(duration, '7');
    await tester.pumpAndSettle();
    expect(controller.simulationResult.value, isNull);
    expect(tester.takeException(), isNull);
  });

  test('Period text and selection colors meet AA contrast', () {
    for (final pair in [
      (AppTheme.textPrimaryLight, AppTheme.surfaceLight),
      (AppTheme.textSecondaryLight, AppTheme.surfaceLight),
      (AppTheme.primary700, AppTheme.backgroundLight),
      (Colors.white, AppTheme.primary700),
      (AppTheme.textPrimaryDark, AppTheme.softAccentSurfaceDark),
      (AppTheme.textSecondaryDark, AppTheme.surfaceDark),
      (AppTheme.primary500, AppTheme.surfaceDark),
      (AppTheme.primary900, AppTheme.primary200),
    ]) {
      final a = pair.$1.computeLuminance();
      final b = pair.$2.computeLuminance();
      final ratio = a > b ? (a + .05) / (b + .05) : (b + .05) / (a + .05);
      expect(ratio, greaterThanOrEqualTo(4.5));
    }
  });

  testWidgets('Long dropdown selections remain readable at double text size', (
    tester,
  ) async {
    controller.workingAbility.value = 3;
    controller.bloodConsistency.value = 'Kental / Menggumpal';
    await mount(tester, width: 320, scale: 2);
    await tester.ensureVisible(find.text('Kental / menggumpal'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Harus beristirahat di tempat tidur'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Guest calculators and guides remain available; protected tabs ask for login',
    (tester) async {
      await StorageService.clearAuth();
      await mount(tester);
      expect(find.text('Kalkulator mandiri'), findsOneWidget);
      await tap(tester, find.text('Prediksi'));
      expect(find.text('Masuk untuk melihat catatanmu'), findsOneWidget);
      await tap(tester, find.text('Kalkulator'));
      await tap(tester, find.text('Panduan warna darah'));
      expect(find.text('Warna uji'), findsOneWidget);
      Get.back();
      await tester.pumpAndSettle();
      await tap(tester, find.text('Panduan kebersihan'));
      expect(find.text('1. Panduan uji'), findsOneWidget);
    },
  );

  testWidgets('Male account sees access message and public calculator action', (
    tester,
  ) async {
    controller.isFemale.value = false;
    await mount(tester);
    expect(find.text('Pencatatan khusus mahasiswi'), findsOneWidget);
    expect(find.byKey(const ValueKey('save-period')), findsNothing);
    await tap(tester, find.text('Buka kalkulator'));
    expect(find.text('Kalkulator mandiri'), findsOneWidget);
  });

  testWidgets('History has separate empty, error and clinical record states', (
    tester,
  ) async {
    await mount(tester);
    await tap(tester, find.text('Riwayat'));
    expect(find.text('Belum ada catatan haid'), findsOneWidget);
    controller.historyError.value = 'Koneksi gagal';
    await tester.pumpAndSettle();
    expect(find.text('Koneksi gagal'), findsOneWidget);
    expect(find.text('Belum ada catatan haid'), findsNothing);
    await tap(tester, find.text('Coba lagi'));
    expect(controller.refreshes, greaterThan(1));
    controller.historyError.value = '';
    controller.periodHistory.assignAll([
      PeriodRecordModel.fromJson({
        'start_date': '2026-09-01T00:00:00.000000Z',
        'pbac_score': 123,
        'volume_category': 'menoragia',
        'walidd_total_score': 6,
        'walidd_category': 'Dismenore Sedang',
      }),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('1 Sep 2026'), findsOneWidget);
    expect(find.text('PBAC 123 · menoragia'), findsOneWidget);
    expect(find.text('WaLIDD 6/12 · Dismenore Sedang'), findsOneWidget);
  });

  if (Platform.environment['SIKERA_CAPTURE_PERIOD'] == '1') {
    testWidgets('Capture period UI using test fixtures', (tester) async {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final font = File('C:/Windows/Fonts/arial.ttf');
      if (font.existsSync()) {
        for (final family in ['Roboto', 'Ahem']) {
          await (FontLoader(family)..addFont(
                Future.value(ByteData.sublistView(font.readAsBytesSync())),
              ))
              .load();
        }
      }
      controller.periodPredictions.value = PeriodPredictionModel.fromJson(
        predictionFixture(),
      );
      for (final dark in [false, true]) {
        await mount(tester, dark: dark);
        for (final tab in ['Catatan', 'Prediksi', 'Kalkulator']) {
          await tap(tester, find.text(tab));
          await tester.runAsync(() async {
            final boundary =
                capture.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'build/period-${dark ? 'dark' : 'light'}-${tab.toLowerCase()}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    });
  }
}
