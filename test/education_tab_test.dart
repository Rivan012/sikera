import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/data/models/dashboard_model.dart';
import 'package:sikera/app/data/models/module_model.dart';
import 'package:sikera/app/modules/education/education_controller.dart';
import 'package:sikera/app/modules/education/education_tab.dart';
import 'package:sikera/app/modules/education/module_detail_page.dart';
import 'package:sikera/app/modules/education/widgets/module_banner.dart';
import 'package:sikera/app/routes/app_pages.dart';

class _EducationController extends EducationController {
  int? openedModule;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchModules({bool forceRefresh = false}) async {}

  @override
  Future<void> fetchModuleDetail(int id) async {
    openedModule = id;
  }
}

void main() {
  testWidgets('Materi fits narrow enlarged text and opens the chosen module', (
    tester,
  ) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final captureKey = GlobalKey();

    final controller = _EducationController();
    controller.modules.assignAll([
      DashboardModuleModel(
        id: 1,
        moduleNumber: 1,
        title: 'Mengenal Kesehatan Reproduksi dan Perawatan Tubuh',
        bannerImage: '/images/banners/module-1.svg',
        totalTopics: 4,
        completedTopics: 2,
        progressPercentage: 50,
        hasPretest: true,
        hasPosttest: false,
      ),
      DashboardModuleModel(
        id: 2,
        moduleNumber: 2,
        title: 'Pubertas & Perubahan Tubuh',
        totalTopics: 4,
        completedTopics: 0,
        progressPercentage: 0,
        hasPretest: false,
        hasPosttest: false,
      ),
    ]);
    Get.put<EducationController>(controller);

    ThemeData testTheme(ThemeData theme) => theme.copyWith(
      appBarTheme: theme.appBarTheme.copyWith(
        titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
          fontFamily: 'Roboto',
        ),
      ),
    );
    Widget app({required double textScale, bool dark = false}) =>
        GetMaterialApp(
          theme: testTheme(AppTheme.lightTheme),
          darkTheme: testTheme(AppTheme.darkTheme),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: RepaintBoundary(key: captureKey, child: const EducationTab()),
          getPages: [
            GetPage(
              name: Routes.EDUCATION_MODULE_DETAIL,
              page: () => const Scaffold(body: Text('Tujuan modul')),
            ),
          ],
        );

    if (Platform.environment['SIKERA_CAPTURE_MATERI'] == '1') {
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
      final font = File('C:/Windows/Fonts/arial.ttf');
      if (font.existsSync()) {
        for (final family in ['Roboto', 'Ahem']) {
          await (FontLoader(family)..addFont(
                Future.value(ByteData.sublistView(font.readAsBytesSync())),
              ))
              .load();
        }
      }
      tester.view.physicalSize = const Size(390, 844);
      for (final dark in [false, true]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(app(textScale: 1, dark: dark));
        await tester.pumpAndSettle();
        expect(find.text('Kemajuan belajar'), findsOneWidget);
        bool imagesReady() => tester
            .widgetList<RawImage>(find.byType(RawImage))
            .every((image) => image.image != null);
        for (var attempt = 0; attempt < 60 && !imagesReady(); attempt++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)),
          );
          await tester.pump();
        }
        expect(imagesReady(), isTrue);
        await tester.pump(const Duration(milliseconds: 100));
        final boundary =
            captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          final file = File(
            'build/materi-final-${dark ? 'dark' : 'light'}.png',
          );
          await file.parent.create(recursive: true);
          await file.writeAsBytes(data!.buffer.asUint8List());
          image.dispose();
        });
      }
    }

    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpWidget(app(textScale: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ModuleBanner), findsNWidgets(2));
    expect(find.byType(ShaderMask), findsNWidgets(2));
    expect(find.text('2/8 submateri tuntas'), findsOneWidget);
    final continueCta = find.byKey(const ValueKey('education-continue-cta'));
    expect(continueCta, findsOneWidget);
    expect(tester.getSize(continueCta).height, greaterThanOrEqualTo(48));

    tester.view.physicalSize = const Size(720, 900);
    await tester.pumpWidget(app(textScale: 1));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(ModuleBanner), findsNWidgets(2));
    expect(find.byType(ShaderMask), findsNWidgets(2));

    await tester.tap(continueCta);
    await tester.pumpAndSettle();
    expect(controller.openedModule, 1);
    expect(Get.currentRoute, Routes.EDUCATION_MODULE_DETAIL);
    Get.back();
    await tester.pumpAndSettle();
    controller.openedModule = null;

    final firstModule = find.text(
      'Mengenal Kesehatan Reproduksi dan Perawatan Tubuh',
    );

    tester.view.physicalSize = const Size(320, 640);
    for (final dark in [false, true]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(app(textScale: 2, dark: dark));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('25%'), findsOneWidget);
      expect(find.byType(ModuleBanner), findsNothing);

      await tester.scrollUntilVisible(firstModule, 180);
      await tester.pumpAndSettle();
      expect(find.text('Sedang dipelajari'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.scrollUntilVisible(
        find.text('Pubertas & Perubahan Tubuh'),
        180,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    await tester.scrollUntilVisible(firstModule, -180);
    await tester.pumpAndSettle();
    await tester.tap(firstModule);
    await tester.pumpAndSettle();
    expect(controller.openedModule, 1);
    expect(Get.currentRoute, Routes.EDUCATION_MODULE_DETAIL);
    expect(find.text('Tujuan modul'), findsOneWidget);
  });

  testWidgets('Detail modul fits narrow enlarged text with one banner', (
    tester,
  ) async {
    Get.testMode = true;
    addTearDown(Get.reset);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final controller = _EducationController();
    controller.currentModule.value = ModuleDetailModel(
      id: 1,
      moduleNumber: 1,
      title: 'Mengenal Kesehatan Reproduksi',
      description: 'Ringkasan modul',
      hasPretest: true,
      hasPosttest: false,
    );
    Get.put<EducationController>(controller);

    final layoutErrors = <String>[];
    for (final dark in [false, true]) {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const ModuleDetailPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ModuleBanner), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is BoxDecoration &&
              (widget.decoration! as BoxDecoration).gradient ==
                  AppTheme.brandGradient,
        ),
        findsNothing,
      );
      expect(find.text('Ringkasan modul'), findsOneWidget);
      expect(find.text('0 dari 0 submateri tuntas'), findsOneWidget);
      final error = tester.takeException();
      if (error != null) {
        layoutErrors.add(
          '${dark ? 'gelap' : 'terang'}: ${error is FlutterError ? error.toStringDeep() : error}',
        );
      }
    }
    if (layoutErrors.isNotEmpty) fail(layoutErrors.join('\n'));
  });
}
