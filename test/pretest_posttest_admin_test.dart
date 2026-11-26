import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/data/models/admin_assessment_model.dart';
import 'package:sikera/app/data/models/dashboard_model.dart';
import 'package:sikera/app/data/models/module_model.dart';
import 'package:sikera/app/data/models/user_model.dart';
import 'package:sikera/app/modules/admin/admin_assessment_controller.dart';
import 'package:sikera/app/modules/admin/admin_posttest_page.dart';
import 'package:sikera/app/modules/admin/admin_pretest_page.dart';
import 'package:sikera/app/modules/admin/admin_question_form_page.dart';
import 'package:sikera/app/modules/education/education_controller.dart';
import 'package:sikera/app/modules/education/education_tab.dart';
import 'package:sikera/app/modules/education/module_detail_page.dart';
import 'package:sikera/app/modules/education/posttest_page.dart';
import 'package:sikera/app/modules/education/topic_page.dart';
import 'package:sikera/app/modules/home/home_controller.dart';
import 'package:sikera/app/modules/main_nav/main_nav_controller.dart';
import 'package:sikera/app/modules/main_nav/main_nav_page.dart';
import 'package:sikera/app/modules/profile/profile_controller.dart';
import 'package:sikera/app/modules/profile/profile_tab.dart';
import 'package:sikera/app/routes/app_pages.dart';

class _FakeEducationController extends EducationController {
  int? fetchedPretestModuleId;
  bool fetchedGlobalPosttest = false;
  bool submittedGlobalPosttest = false;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchModules({bool forceRefresh = false}) async {}

  @override
  Future<void> fetchModuleDetail(int id) async {}

  @override
  Future<void> fetchPretest(int moduleId) async {
    fetchedPretestModuleId = moduleId;
  }

  @override
  Future<void> fetchGlobalPosttest() async {
    fetchedGlobalPosttest = true;
  }

  @override
  Future<void> submitGlobalPosttest() async {
    submittedGlobalPosttest = true;
  }

  @override
  Future<void> refreshAllProgress([int? moduleId]) async {}
}

class _FakeAdminController extends AdminAssessmentController {
  int? loadedModuleId;
  int posttestLoads = 0;
  bool shouldSaveSucceed = true;
  int? savedModuleId;
  AssessmentKind? savedKind;
  String? savedText;
  String? savedCorrectAnswer;
  int? deletedId;

  @override
  Future<void> loadPretestTab({bool forceRefresh = false}) async {
    if (modules.isNotEmpty && selectedModuleId.value == null) {
      selectedModuleId.value = modules.first.id;
    }
    if (selectedModuleId.value != null) {
      loadedModuleId = selectedModuleId.value;
    }
  }

  @override
  Future<void> fetchModules({bool forceRefresh = false}) async {}

  @override
  Future<void> selectModule(int moduleId) async {
    selectedModuleId.value = moduleId;
    loadedModuleId = moduleId;
  }

  @override
  Future<void> fetchPretestQuestions(
    int moduleId, {
    bool forceRefresh = false,
  }) async {
    loadedModuleId = moduleId;
  }

  @override
  Future<void> fetchPosttestQuestions({bool forceRefresh = false}) async {
    posttestLoads++;
  }

  @override
  Future<bool> saveQuestion({
    required AssessmentKind kind,
    int? moduleId,
    int? editingId,
    required String questionText,
    required List<QuestionOption> options,
    required String correctAnswer,
  }) async {
    savedKind = kind;
    savedModuleId = moduleId;
    savedText = questionText;
    savedCorrectAnswer = correctAnswer;
    if (!shouldSaveSucceed) {
      formErrorMessage.value = 'Server menolak penyimpanan soal.';
      return false;
    }
    return true;
  }

  @override
  Future<bool> deleteQuestion(AdminQuestionModel question) async {
    deletedId = question.id;
    if (question.kind == AssessmentKind.pretest) {
      pretestQuestions.removeWhere((q) => q.id == question.id);
    } else {
      posttestQuestions.removeWhere((q) => q.id == question.id);
    }
    return true;
  }
}

class _FakeHomeController extends HomeController {
  @override
  // ignore: must_call_super
  void onInit() => isLoading.value = false;

  @override
  Future<void> fetchDashboard({bool forceRefresh = false}) async {}
}

class _FakeProfileController extends ProfileController {
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchProfile({bool forceRefresh = false}) async {}
}

class _FakeNavController extends MainNavController {
  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  void changeTab(int index) {
    currentIndex.value = index.clamp(0, tabCount - 1);
  }
}

AdminQuestionModel _adminQuestion({
  required int id,
  required AssessmentKind kind,
  int? moduleId,
  String text = 'Pertanyaan kesehatan reproduksi mahasiswa?',
  String correct = 'B',
}) {
  return AdminQuestionModel(
    id: id,
    moduleId: moduleId,
    kind: kind,
    questionText: text,
    correctAnswer: correct,
    options: [
      QuestionOption(label: 'A', text: 'Jawaban A'),
      QuestionOption(label: 'B', text: 'Jawaban B yang benar'),
      QuestionOption(label: 'C', text: 'Jawaban C'),
      QuestionOption(label: 'D', text: 'Jawaban D'),
    ],
  );
}

List<DashboardModuleModel> _sampleModules({bool allCompleted = false}) {
  return [
    DashboardModuleModel(
      id: 1,
      moduleNumber: 1,
      title: 'Anatomi dan Higienitas Reproduksi',
      totalTopics: 4,
      completedTopics: allCompleted ? 4 : 2,
      progressPercentage: allCompleted ? 100 : 50,
      hasPretest: true,
      hasPosttest: false,
    ),
    DashboardModuleModel(
      id: 2,
      moduleNumber: 2,
      title: 'Pubertas dan Perubahan Tubuh',
      totalTopics: 4,
      completedTopics: allCompleted ? 4 : 0,
      progressPercentage: allCompleted ? 100 : 0,
      hasPretest: allCompleted,
      hasPosttest: false,
    ),
  ];
}

void main() {
  group('Model unit tests: UserModel role & GlobalPosttestStatus 3-day rule', () {
    test('UserModel detects admin and non-admin roles', () {
      expect(UserModel.fromJson({'id': 1, 'name': 'Admin', 'role': 'admin'}).isAdmin, isTrue);
      expect(UserModel.fromJson({'id': 2, 'name': 'Super', 'role': 'super_admin'}).isAdmin, isTrue);
      expect(UserModel.fromJson({'id': 3, 'name': 'Flag', 'is_admin': true}).isAdmin, isTrue);
      expect(UserModel.fromJson({'id': 4, 'name': 'Mhs', 'role': 'student'}).isAdmin, isFalse);
      expect(UserModel.fromJson({'id': 5, 'name': 'Default'}).isAdmin, isFalse);
    });

    test('GlobalPosttestStatus enforces 3-day waiting window after all modules done', () {
      final completedAt = DateTime(2026, 11, 20, 10, 0);
      final incomplete = GlobalPosttestStatus(
        totalModules: 4,
        completedModules: 3,
        allModulesCompleted: false,
      );
      expect(
        incomplete.availabilityAt(completedAt),
        PosttestAvailability.lockedIncompleteModules,
      );

      final waiting = GlobalPosttestStatus(
        totalModules: 4,
        completedModules: 4,
        allModulesCompleted: true,
        allModulesCompletedAt: completedAt,
      );
      expect(
        waiting.availabilityAt(completedAt.add(const Duration(days: 2, hours: 23))),
        PosttestAvailability.waitingCooldown,
      );
      expect(
        waiting.formatRemaining(completedAt.add(const Duration(days: 2, hours: 23))),
        '1 jam lagi',
      );
      expect(
        waiting.availabilityAt(completedAt.add(const Duration(days: 3))),
        PosttestAvailability.available,
      );

      final done = waiting.copyWith(hasCompletedPosttest: true, posttestScore: 95);
      expect(done.availabilityAt(completedAt), PosttestAvailability.completed);
    });

    test('AdminQuestionModel parses flat and nested options and serializes payload', () {
      final parsed = AdminQuestionModel.fromJson(
        {
          'id': 12,
          'module_id': 2,
          'question_text': 'Contoh soal',
          'option_a': 'Satu',
          'option_b': 'Dua',
          'answer_key': 'b',
        },
        defaultKind: AssessmentKind.pretest,
      );
      expect(parsed.options.length, 2);
      expect(parsed.correctAnswer, 'B');
      expect(parsed.toPayload()['module_id'], 2);
      expect(parsed.toPayload()['type'], 'pretest');
      expect(parsed.toPayload()['correct_answer'], 'B');
    });
  });

  group('Student flow: Pre-Test gate before material & 3-day Global Post-Test', () {
    late _FakeEducationController edu;

    setUp(() {
      Get.testMode = true;
      edu = _FakeEducationController();
      Get.put<EducationController>(edu);
    });

    tearDown(Get.reset);

    testWidgets('ModuleDetailPage gates materials behind Pre-Test when hasPretest is false', (
      tester,
    ) async {
      edu.currentModule.value = ModuleDetailModel(
        id: 2,
        moduleNumber: 2,
        title: 'Pubertas dan Perubahan Tubuh',
        description: 'Pelajari perubahan tubuh pada masa remaja.',
        hasPretest: false,
        hasPosttest: false,
        topics: [
          TopicModel(id: 10, topicCode: '2.1', title: 'Submateri Rahasia', isLocked: true),
        ],
      );

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 640);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final dark in [false, true]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2.0),
              ),
              child: child!,
            ),
            home: const ModuleDetailPage(),
            getPages: [
              GetPage(
                name: Routes.EDUCATION_PRETEST,
                page: () => const Scaffold(body: Text('Halaman Pre-Test')),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('pretest-gate-view')), findsOneWidget);
        expect(find.text('Pre-Test Sebelum Mengakses Materi'), findsOneWidget);
        expect(find.text('Submateri Rahasia'), findsNothing);
        expect(find.text('Post-Test & Peningkatan N-Gain'), findsNothing);
        expect(tester.takeException(), isNull);
      }

      final startBtn = find.byKey(const ValueKey('pretest-gate-start-btn'));
      expect(tester.getSize(startBtn).height, greaterThanOrEqualTo(48));
      await tester.ensureVisible(startBtn);
      await tester.tap(startBtn);
      await tester.pumpAndSettle();
      expect(edu.fetchedPretestModuleId, 2);
      expect(Get.currentRoute, Routes.EDUCATION_PRETEST);
    });

    testWidgets('TopicPage blocks reading when active module hasPretest is false', (
      tester,
    ) async {
      edu.currentModule.value = ModuleDetailModel(
        id: 1,
        moduleNumber: 1,
        title: 'Modul 1',
        hasPretest: false,
        hasPosttest: false,
      );
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const TopicPage(),
          getPages: [
            GetPage(
              name: Routes.EDUCATION_PRETEST,
              page: () => const Scaffold(body: Text('Pre-Test Dibuka')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pre-Test Diperlukan'), findsOneWidget);
      await tester.tap(find.text('Mulai Pre-Test Sekarang'));
      await tester.pumpAndSettle();
      expect(edu.fetchedPretestModuleId, 1);
      expect(Get.currentRoute, Routes.EDUCATION_PRETEST);
    });

    testWidgets('EducationTab shows 3-day countdown then unlocks Global Post-Test', (
      tester,
    ) async {
      final baseTime = DateTime(2026, 11, 20, 9, 0);
      edu.modules.assignAll(_sampleModules(allCompleted: true));
      edu.posttestStatus.value = GlobalPosttestStatus(
        totalModules: 2,
        completedModules: 2,
        allModulesCompleted: true,
        allModulesCompletedAt: baseTime,
      );
      edu.nowProvider = () => baseTime.add(const Duration(days: 1));

      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const EducationTab(),
          getPages: [
            GetPage(
              name: Routes.EDUCATION_POSTTEST,
              page: () => const PosttestPage(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('global-posttest-card')), findsOneWidget);
      expect(find.text('Menunggu 3 Hari'), findsOneWidget);
      expect(find.textContaining('2 hari lagi'), findsOneWidget);
      expect(find.byKey(const ValueKey('start-global-posttest-btn')), findsNothing);
      expect(tester.takeException(), isNull);

      // Advance time past 3 days
      edu.nowProvider = () => baseTime.add(const Duration(days: 3, minutes: 5));
      edu.posttestStatus.refresh();
      await tester.pumpAndSettle();

      expect(find.text('Tersedia Sekarang'), findsOneWidget);
      final startBtn = find.byKey(const ValueKey('start-global-posttest-btn'));
      expect(startBtn, findsOneWidget);
      expect(tester.getSize(startBtn).height, greaterThanOrEqualTo(48));

      edu.questions.assignAll([
        QuestionModel(
          id: 99,
          questionText: 'Soal Post-Test Akhir',
          options: [
            QuestionOption(label: 'A', text: 'Opsi A'),
            QuestionOption(label: 'B', text: 'Opsi B'),
          ],
        ),
      ]);

      await tester.tap(startBtn);
      await tester.pumpAndSettle();
      expect(edu.fetchedGlobalPosttest, isTrue);
      expect(find.text('Post-Test Akhir'), findsOneWidget);

      await tester.tap(find.text('A. Opsi A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kirim Jawaban'));
      await tester.pumpAndSettle();
      expect(edu.submittedGlobalPosttest, isTrue);
      expect(tester.takeException(), isNull);
    });
  });

  group('Admin role: Separate Pre-Test (per modul) & Post-Test menus and mobile reflow', () {
    late _FakeAdminController admin;
    late _FakeHomeController home;
    late _FakeProfileController profile;
    late _FakeNavController nav;

    setUp(() {
      Get.testMode = true;
      admin = _FakeAdminController();
      admin.modules.assignAll(_sampleModules());
      admin.selectedModuleId.value = 1;
      admin.pretestQuestions.assignAll([
        _adminQuestion(
          id: 101,
          kind: AssessmentKind.pretest,
          moduleId: 1,
          text: 'Soal Pre-Test Modul 1?',
          correct: 'B',
        ),
      ]);
      admin.posttestQuestions.assignAll([
        _adminQuestion(
          id: 201,
          kind: AssessmentKind.posttest,
          text: 'Soal Post-Test Global?',
          correct: 'A',
        ),
      ]);
      home = _FakeHomeController();
      home.currentUser.value = UserModel(id: 9, name: 'Admin SIKERA', role: 'admin');
      profile = _FakeProfileController();
      profile.user.value = home.currentUser.value;
      nav = _FakeNavController();
      nav.isAdmin.value = true;

      Get.put<AdminAssessmentController>(admin);
      Get.put<HomeController>(home);
      Get.put<ProfileController>(profile);
      Get.put<MainNavController>(nav);
    });

    tearDown(Get.reset);

    testWidgets('MainNavPage for Admin uses 4-tab BottomNav on phone and NavigationRail on desktop', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Mobile phone (390x844)
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const MainNavPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('admin-bottom-nav')), findsOneWidget);
      expect(find.byKey(const ValueKey('admin-nav-rail')), findsNothing);
      expect(find.text('Pre-Test'), findsOneWidget);
      expect(find.text('Post-Test'), findsOneWidget);

      await tester.tap(find.text('Pre-Test'));
      await tester.pumpAndSettle();
      expect(nav.currentIndex.value, 1);
      expect(find.text('Kelola Pre-Test'), findsOneWidget);

      await tester.tap(find.text('Post-Test'));
      await tester.pumpAndSettle();
      expect(nav.currentIndex.value, 2);
      expect(find.text('Kelola Post-Test'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Tablet / Desktop (1024x900)
      tester.view.physicalSize = const Size(1024, 900);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('admin-nav-rail')), findsOneWidget);
      expect(find.byKey(const ValueKey('admin-bottom-nav')), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AdminPretestPage switches modules, fits 320px 200% text, and deletes question', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final dark in [false, true]) {
        tester.view.physicalSize = const Size(320, 640);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2.0),
              ),
              child: child!,
            ),
            home: const AdminPretestPage(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Kelola Pre-Test'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminPretestPage(),
          getPages: [
            GetPage(
              name: Routes.ADMIN_QUESTION_FORM,
              page: () => const AdminQuestionFormPage(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('admin-pretest-module-2')));
      await tester.pumpAndSettle();
      expect(admin.loadedModuleId, 2);
      expect(admin.selectedModuleId.value, 2);

      // Verify delete confirmation dialog works
      final deleteBtn = find.byKey(const ValueKey('delete-question-101'));
      await tester.ensureVisible(deleteBtn);
      expect(tester.getSize(deleteBtn).height, greaterThanOrEqualTo(44));
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();
      expect(find.text('Hapus soal Pre-Test?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();
      expect(admin.deletedId, 101);
      expect(admin.pretestQuestions, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AdminPosttestPage and AdminQuestionFormPage validate and submit cleanly', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminPosttestPage(),
          getPages: [
            GetPage(
              name: Routes.ADMIN_QUESTION_FORM,
              page: () => const AdminQuestionFormPage(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kelola Post-Test'), findsOneWidget);
      expect(find.textContaining('3 hari setelah mahasiswa menyelesaikan'), findsOneWidget);
      expect(find.text('Soal Post-Test Global?'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('add-posttest-question-btn')));
      await tester.pumpAndSettle();
      expect(find.text('Tambah Soal Post-Test'), findsOneWidget);

      // Empty submit triggers inline validation
      await tester.tap(find.byKey(const ValueKey('form-save-question-btn')));
      await tester.pumpAndSettle();
      expect(find.text('Pertanyaan wajib diisi.'), findsOneWidget);
      expect(admin.savedText, isNull);

      // Fill valid question and options
      await tester.enterText(
        find.byKey(const ValueKey('form-question-input')),
        'Apa manfaat pemeriksaan kesehatan reproduksi berkala?',
      );
      await tester.enterText(find.byKey(const ValueKey('form-option-A')), 'Deteksi dini');
      await tester.enterText(find.byKey(const ValueKey('form-option-B')), 'Tidak ada');
      await tester.enterText(find.byKey(const ValueKey('form-option-C')), 'Menunda pengobatan');
      await tester.enterText(find.byKey(const ValueKey('form-option-D')), 'Hanya formalitas');
      await tester.tap(find.byKey(const ValueKey('form-correct-A')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('form-save-question-btn')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(admin.savedKind, AssessmentKind.posttest);
      expect(admin.savedModuleId, isNull);
      expect(admin.savedCorrectAnswer, 'A');
      expect(tester.takeException(), isNull);
    });

    testWidgets('AdminPosttestPage, AdminPretestPage desktop two-pane, form error, and ProfileTab admin menu hold up across breakpoints', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // AdminPosttestPage empty, error, loading, and narrow 320px 200% text in both themes
      for (final dark in [false, true]) {
        tester.view.physicalSize = const Size(320, 640);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          GetMaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: dark ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: const TextScaler.linear(2.0),
              ),
              child: child!,
            ),
            home: const AdminPosttestPage(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Kelola Post-Test'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      // Empty & error state recovery on AdminPosttestPage
      tester.view.physicalSize = const Size(390, 844);
      admin.posttestQuestions.clear();
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminPosttestPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Belum ada soal Post-Test Akhir.'), findsOneWidget);

      admin.posttestError.value = 'Gagal memuat Post-Test.';
      await tester.pumpAndSettle();
      expect(find.text('Gagal memuat Post-Test.'), findsOneWidget);
      final beforeRetry = admin.posttestLoads;
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();
      expect(admin.posttestLoads, greaterThan(beforeRetry));
      admin.posttestError.value = '';

      // AdminPretestPage desktop two-pane layout (1024x900)
      tester.view.physicalSize = const Size(1024, 900);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminPretestPage(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(VerticalDivider), findsOneWidget);
      expect(tester.takeException(), isNull);

      // AdminQuestionFormPage inline API error without closing + 320px 200% text
      admin.shouldSaveSucceed = false;
      tester.view.physicalSize = const Size(320, 640);
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Get.to(
                  () => const AdminQuestionFormPage(),
                  arguments: {
                    'kind': AssessmentKind.pretest,
                    'moduleId': 1,
                  },
                ),
                child: const Text('Buka Form'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Buka Form'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('form-question-input')),
        'Pertanyaan Pre-Test?',
      );
      await tester.enterText(find.byKey(const ValueKey('form-option-A')), 'Opsi A');
      await tester.enterText(find.byKey(const ValueKey('form-option-B')), 'Opsi B');
      await tester.enterText(find.byKey(const ValueKey('form-option-C')), 'Opsi C');
      await tester.enterText(find.byKey(const ValueKey('form-option-D')), 'Opsi D');
      await tester.tap(find.byKey(const ValueKey('form-save-question-btn')));
      await tester.pumpAndSettle();
      expect(find.text('Server menolak penyimpanan soal.'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // ProfileTab for Admin shows role indicator and separate Admin menu items
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        GetMaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProfileTab(),
          getPages: [
            GetPage(
              name: Routes.ADMIN_PRETEST,
              page: () => const Scaffold(body: Text('Route Admin Pre-Test')),
            ),
            GetPage(
              name: Routes.ADMIN_POSTTEST,
              page: () => const Scaffold(body: Text('Route Admin Post-Test')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Peran: Admin'), findsOneWidget);
      expect(find.text('Menu Admin'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('profile-admin-pretest-tile')));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, Routes.ADMIN_PRETEST);
      Get.back();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('profile-admin-posttest-tile')));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, Routes.ADMIN_POSTTEST);
      expect(tester.takeException(), isNull);
    });
  });
}
