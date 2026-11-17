import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sikera/app/modules/education/education_controller.dart';
import 'package:sikera/app/modules/education/result_page.dart';
import 'package:sikera/app/modules/home/home_controller.dart';
import 'package:sikera/app/modules/home/home_tab.dart';
import 'package:sikera/app/modules/main_nav/main_nav_controller.dart';
import 'package:sikera/app/routes/app_pages.dart';

class _HomeController extends HomeController {
  @override
  // ignore: must_call_super
  void onInit() => isLoading.value = false;

  @override
  Future<void> fetchDashboard({bool forceRefresh = false}) async {}
}

class _EducationController extends EducationController {
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> refreshAllProgress([int? moduleId]) async {}
}

class _HomeShell extends GetView<MainNavController> {
  const _HomeShell();

  @override
  Widget build(BuildContext context) => Obx(
    () => Scaffold(
      body: IndexedStack(
        index: controller.currentIndex.value,
        children: const [
          HomeTab(),
          Center(child: Text('Materi')),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('Returning from a module keeps the Home search field alive', (
    tester,
  ) async {
    Get.testMode = true;
    addTearDown(Get.reset);

    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: Routes.HOME,
        getPages: [
          GetPage(
            name: Routes.HOME,
            page: () => const _HomeShell(),
            binding: BindingsBuilder(() {
              Get.lazyPut<MainNavController>(
                () => MainNavController(),
                fenix: true,
              );
              Get.lazyPut<HomeController>(() => _HomeController(), fenix: true);
              Get.lazyPut<EducationController>(
                () => _EducationController(),
                fenix: true,
              );
            }),
          ),
          GetPage(
            name: Routes.EDUCATION_MODULE_DETAIL,
            page: () => const Scaffold(body: Text('Detail modul')),
          ),
          GetPage(
            name: Routes.EDUCATION_RESULT,
            page: () => const ResultPage(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    final home = Get.find<HomeController>();
    final navigation = Get.find<MainNavController>();
    navigation.changeTab(1);
    await tester.pumpAndSettle();
    Get.toNamed(Routes.EDUCATION_MODULE_DETAIL);
    await tester.pumpAndSettle();
    Get.toNamed(
      Routes.EDUCATION_RESULT,
      arguments: {
        'isPretest': false,
        'moduleId': 1,
        'data': {'score': 90},
      },
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kembali ke Beranda'));
    await tester.pumpAndSettle();

    expect(Get.currentRoute, Routes.HOME);
    expect(navigation.currentIndex.value, 0);
    expect(identical(Get.find<HomeController>(), home), isTrue);
    expect(home.isClosed, isFalse);
    final search = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.controller == home.searchController,
    );
    expect(search, findsOneWidget);
    await tester.ensureVisible(search);
    await tester.enterText(search, 'modul');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
