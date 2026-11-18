import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/data/models/dashboard_model.dart';
import 'package:sikera/app/data/models/user_model.dart';
import 'package:sikera/app/modules/home/home_controller.dart';
import 'package:sikera/app/modules/home/home_tab.dart';
import 'package:sikera/app/modules/main_nav/main_nav_controller.dart';
import 'package:sikera/app/routes/app_pages.dart';

class _HomeController extends HomeController {
  int refreshes = 0;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchDashboard({bool forceRefresh = false}) async {
    refreshes++;
  }
}

class _NavigationController extends MainNavController {
  @override
  void changeTab(int index) => currentIndex.value = index;
}

DashboardModuleModel _module(int id, String title, int progress) =>
    DashboardModuleModel(
      id: id,
      moduleNumber: id,
      title: title,
      totalTopics: 4,
      completedTopics: progress ~/ 25,
      progressPercentage: progress,
      hasPretest: progress > 0,
      hasPosttest: progress == 100,
    );

void main() {
  late _HomeController controller;
  late _NavigationController navigation;
  final captureKey = GlobalKey();
  final routes = [
    Routes.EDUCATION_MODULE_LIST,
    Routes.EDUCATION_MODULE_DETAIL,
    Routes.SELFCARE_PERIOD,
    Routes.SELFCARE_BMI,
    Routes.SELFCARE_HYGIENE_GUIDE,
    Routes.POSTERS,
    Routes.CASES,
    Routes.TRIVIA,
    Routes.SELFCARE,
  ];

  setUp(() {
    Get.testMode = true;
    controller = _HomeController();
    controller.isLoading.value = false;
    controller.currentUser.value = UserModel(
      id: 1,
      name: 'Mahasiswa Uji',
      points: 120,
      streakDays: 3,
    );
    controller.dashboardData.value = DashboardDataModel(
      modules: [
        _module(1, 'Mengenal Kesehatan Reproduksi', 100),
        _module(2, 'Pubertas & Perubahan Tubuh', 50),
        _module(3, 'Menjaga Kesehatan Reproduksi', 0),
      ],
    );
    Get.put<HomeController>(controller);
    navigation = _NavigationController();
    Get.put<MainNavController>(navigation);
  });

  tearDown(() => Get.reset());

  Future<void> mount(
    WidgetTester tester, {
    double width = 390,
    double height = 844,
    bool dark = false,
    double textScale = 1,
    bool? enableAutoSlide,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GetMaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: dark ? ThemeMode.dark : ThemeMode.light,
        defaultTransition: Transition.noTransition,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: RepaintBoundary(
          key: captureKey,
          child: HomeTab(enableAutoSlide: enableAutoSlide),
        ),
        getPages: routes
            .map(
              (route) => GetPage(
                name: route,
                page: () => Scaffold(
                  appBar: AppBar(),
                  body: Text('Destination: $route'),
                ),
              ),
            )
            .toList(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    for (final width in [320.0, 360.0, 390.0, 720.0, 1280.0]) {
      testWidgets('Home fits ${width}px, ${dark ? 'dark' : 'light'} theme', (
        tester,
      ) async {
        await mount(tester, width: width, dark: dark);
        expect(tester.takeException(), isNull);
        expect(find.text('120'), findsNothing);
        expect(find.text('1 dari 3 modul selesai'), findsOneWidget);
        expect(find.text('50%'), findsOneWidget);
        expect(find.byTooltip('Notifikasi SIKERA'), findsNothing);
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -1800),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Mood Diary'), findsNothing);
        expect(find.text('Wawasan & Aktivitas'), findsNothing);
        expect(find.text('Mitos vs Fakta Kaspro'), findsNothing);
        expect(find.text('Poster & Studi Kasus'), findsNothing);
      });
    }
    testWidgets('Home supports enlarged text in ${dark ? 'dark' : 'light'}', (
      tester,
    ) async {
      controller.currentUser.value = UserModel(
        id: 1,
        name: 'Mahasiswadengannamapanjang Sekali',
      );
      await mount(tester, width: 320, dark: dark, textScale: 2);
      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -2500),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Search filters modules, opens correct ID, and clears', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField), 'PUBERTAS');
    await tester.pumpAndSettle();
    expect(find.text('Pubertas & Perubahan Tubuh'), findsOneWidget);
    expect(find.text('Mengenal Kesehatan Reproduksi'), findsNothing);
    await tapVisible(tester, find.text('Pubertas & Perubahan Tubuh'));
    expect(Get.currentRoute, Routes.EDUCATION_MODULE_DETAIL);
    expect(Get.arguments, 2);
    Get.back();
    await tester.pumpAndSettle();
    expect(controller.refreshes, 1);
    await tester.enterText(find.byType(TextField), 'tidak cocok');
    await tester.pumpAndSettle();
    expect(
      find.text('Tidak ditemukan modul dengan kata kunci tersebut.'),
      findsOneWidget,
    );
    await tapVisible(tester, find.byTooltip('Hapus pencarian'));
    expect(controller.searchQuery.value, isEmpty);
    expect(find.text('Jelajah Layanan'), findsOneWidget);
  });

  testWidgets(
    'Module selector and existing learning actions keep their destinations',
    (tester) async {
      await mount(tester);
      await tapVisible(tester, find.byTooltip('Modul berikutnya'));
      expect(find.text('Menjaga Kesehatan Reproduksi'), findsOneWidget);
      await tapVisible(
        tester,
        find.widgetWithText(ElevatedButton, 'Mulai Belajar'),
      );
      expect(Get.arguments, 3);
      Get.back();
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byTooltip('Modul sebelumnya'));
      expect(find.text('50%'), findsOneWidget);
      await tapVisible(
        tester,
        find.widgetWithText(ElevatedButton, 'Lanjutkan Belajar'),
      );
      expect(Get.arguments, 2);
      Get.back();
      await tester.pumpAndSettle();
      await tapVisible(tester, find.text('Semua modul'));
      expect(Get.currentRoute, Routes.EDUCATION_MODULE_LIST);
      Get.back();
      await tester.pumpAndSettle();
      await tapVisible(tester, find.byKey(const ValueKey('learning-banner')));
      expect(Get.arguments, 2);
    },
  );

  testWidgets('All service actions retain their routes', (tester) async {
    await mount(tester);
    final destinations = {
      'Catat Haid': Routes.SELFCARE_PERIOD,
      'Siklus & IMT': Routes.SELFCARE,
      'Kalkulator IMT': Routes.SELFCARE_BMI,
      'Kuis Trivia': Routes.TRIVIA,
      'Poster Visual': Routes.POSTERS,
      'Studi Kasus': Routes.CASES,
    };
    for (final entry in destinations.entries) {
      expect(find.text(entry.key), findsNothing);
      await tapVisible(tester, find.byTooltip(entry.key));
      expect(Get.currentRoute, entry.value);
      Get.back();
      await tester.pumpAndSettle();
    }
    await tapVisible(tester, find.byTooltip('Edukasi'));
    expect(navigation.currentIndex.value, 1);
    await tapVisible(tester, find.byTooltip('Konseling'));
    expect(navigation.currentIndex.value, 2);
    await tapVisible(tester, find.byTooltip('Buka profil'));
    expect(navigation.currentIndex.value, 3);
  });

  testWidgets('Ruang Belajar auto-slides, wraps around, and supports swipe', (
    tester,
  ) async {
    await mount(tester, enableAutoSlide: true);
    expect(find.text('Pubertas & Perubahan Tubuh'), findsOneWidget);
    expect(find.text('2 dari 3'), findsOneWidget);

    // Auto-slides after 4 seconds to module 3
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Menjaga Kesehatan Reproduksi'), findsOneWidget);
    expect(find.text('3 dari 3'), findsOneWidget);

    // Wraps around after another 4 seconds to module 1
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Mengenal Kesehatan Reproduksi'), findsOneWidget);
    expect(find.text('1 dari 3'), findsOneWidget);

    // Horizontal swipe advances slide and resets auto-slide timer
    await tester.fling(
      find.text('Mengenal Kesehatan Reproduksi'),
      const Offset(-240, 0),
      800,
    );
    await tester.pumpAndSettle();
    expect(find.text('Pubertas & Perubahan Tubuh'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Error retry and empty modules have working recovery actions', (
    tester,
  ) async {
    controller.errorMessage.value = 'Gagal memuat ringkasan beranda.';
    await mount(tester);
    await tapVisible(tester, find.text('Coba Lagi'));
    expect(controller.refreshes, 1);
    controller.errorMessage.value = '';
    controller.dashboardData.value = DashboardDataModel();
    await tester.pumpAndSettle();
    expect(find.text('Belum ada modul tersedia'), findsOneWidget);
    await tapVisible(tester, find.text('Buka daftar modul'));
    expect(Get.currentRoute, Routes.EDUCATION_MODULE_LIST);
  });

  testWidgets('Completed state, loading and pull-to-refresh', (tester) async {
    controller.dashboardData.value = DashboardDataModel(
      modules: [_module(1, 'Materi selesai', 100)],
    );
    await mount(tester);
    expect(find.text('1 dari 1 modul selesai'), findsOneWidget);
    expect(
      find.widgetWithText(ElevatedButton, 'Baca Ulang Materi'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('learning-banner')), findsOneWidget);
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, 400));
    await tester.pumpAndSettle();
    expect(controller.refreshes, 1);
    controller.isLoading.value = true;
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    controller.isLoading.value = false;
    await tester.pumpAndSettle();
    expect(find.text('1 dari 1 modul selesai'), findsOneWidget);
  });

  testWidgets('Header action is keyboard accessible', (tester) async {
    await mount(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(navigation.currentIndex.value, 3);
  });

  if (Platform.environment['SIKERA_CAPTURE_HOME'] == '1') {
    testWidgets('Capture home for visual review (test data)', (tester) async {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final font = File('C:/Windows/Fonts/arial.ttf');
      if (font.existsSync()) {
        final loader = FontLoader('Roboto')
          ..addFont(Future.value(ByteData.sublistView(font.readAsBytesSync())));
        await loader.load();
      }
      for (final dark in [false, true]) {
        await mount(tester, height: 1100, dark: dark);
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/logo/sikera_logo_putih.png'),
            captureKey.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        final boundary =
            captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File('build/home-review-${dark ? 'dark' : 'light'}.png');
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }
    });
  }
}
