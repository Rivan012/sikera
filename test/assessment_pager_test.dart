import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/data/models/module_model.dart';
import 'package:sikera/app/modules/education/education_controller.dart';
import 'package:sikera/app/modules/education/pretest_page.dart';
import 'package:sikera/app/modules/education/posttest_page.dart';
import 'package:sikera/app/modules/education/widgets/test_question_pager.dart';

class _Controller extends EducationController {
  String? submitted;
  int? module;
  int submissions = 0;
  String? retried;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchPretest(int moduleId) async => retried = 'pre';

  @override
  Future<void> fetchPosttest(int moduleId) async => retried = 'post';

  @override
  Future<void> submitPretest(int moduleId) async => _submit('pre', moduleId);

  @override
  Future<void> submitPosttest(int moduleId) async => _submit('post', moduleId);

  void _submit(String kind, int moduleId) {
    submitted = kind;
    module = moduleId;
    submissions++;
    isSubmitting.value = true;
  }
}

QuestionModel _question(int id, {bool long = false}) => QuestionModel(
  id: id,
  questionText: long
      ? List.filled(
          8,
          'Pertanyaan uji panjang untuk memeriksa keterbacaan.',
        ).join(' ')
      : 'Pertanyaan uji $id: pilihan manakah yang kamu pilih?',
  options: [
    QuestionOption(
      label: 'A',
      text: long
          ? List.filled(10, 'Pilihan panjang').join(' ')
          : 'Pilihan pertama',
    ),
    QuestionOption(label: 'B', text: 'Pilihan kedua'),
    QuestionOption(label: 'C', text: 'Pilihan ketiga'),
  ],
);

void main() {
  late _Controller controller;
  final captureKey = GlobalKey();

  setUp(() {
    Get.testMode = true;
    controller = _Controller();
    controller.questions.assignAll([
      _question(11),
      _question(22),
      _question(33),
    ]);
    Get.put<EducationController>(controller, permanent: true);
  });
  tearDown(Get.reset);

  Future<void> mount(
    WidgetTester tester, {
    bool post = false,
    bool dark = false,
    double scale = 1,
    Size size = const Size(390, 844),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final theme = dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    await tester.pumpWidget(
      GetMaterialApp(
        theme: theme.copyWith(
          appBarTheme: theme.appBarTheme.copyWith(
            titleTextStyle: theme.appBarTheme.titleTextStyle?.copyWith(
              fontFamily: 'Roboto',
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: theme.elevatedButtonTheme.style?.copyWith(
              textStyle: WidgetStatePropertyAll(
                theme.elevatedButtonTheme.style?.textStyle
                    ?.resolve({})
                    ?.copyWith(fontFamily: 'Roboto'),
              ),
            ),
          ),
        ),
        defaultTransition: Transition.noTransition,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: TextButton(
            onPressed: () => Get.to(
              () => RepaintBoundary(
                key: captureKey,
                child: post ? const PosttestPage() : const PretestPage(),
              ),
              arguments: 7,
            ),
            child: const Text('Mulai uji'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Mulai uji'));
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, int id, String label) async {
    final option = find.byKey(ValueKey('answer-$id-$label'));
    final radio = find.descendant(
      of: option,
      matching: find.byType(Radio<String>),
    );
    await tester.ensureVisible(radio);
    await tester.tap(radio);
    await tester.pumpAndSettle();
  }

  for (final post in [false, true]) {
    testWidgets(
      '${post ? 'Post' : 'Pre'}test shows one question, remembers edits and submits only on last',
      (tester) async {
        await mount(tester, post: post);
        expect(find.byKey(const ValueKey('question-11')), findsOneWidget);
        expect(find.byKey(const ValueKey('question-22')), findsNothing);
        expect(find.text('Kirim Jawaban'), findsNothing);
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );
        expect(
          tester
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (w) => w is IconButton && w.tooltip == 'Soal sebelumnya',
                ),
              )
              .onPressed,
          isNull,
        );
        await choose(tester, 11, 'A');
        await tester.tap(find.text('Berikutnya'));
        await tester.pumpAndSettle();
        expect(find.text('Soal 2 dari 3'), findsOneWidget);
        expect(find.byKey(const ValueKey('question-11')), findsNothing);
        await choose(tester, 22, 'B');
        await tester.tap(find.byTooltip('Soal sebelumnya'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
              .groupValue,
          'A',
        );
        await choose(tester, 11, 'C');
        await tester.tap(find.text('Berikutnya'));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
              .groupValue,
          'B',
        );
        await tester.tap(find.text('Berikutnya'));
        await tester.pumpAndSettle();
        expect(find.text('Kirim Jawaban'), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );
        await choose(tester, 33, 'A');
        expect(find.text('3 terjawab'), findsOneWidget);
        await tester.tap(find.text('Kirim Jawaban'));
        await tester.pump();
        expect(controller.submitted, post ? 'post' : 'pre');
        expect(controller.module, 7);
        expect(controller.answers, {'11': 'C', '22': 'B', '33': 'A'});
        expect(find.text('Mengirim...'), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNull,
        );
        expect(
          tester
              .widget<IconButton>(
                find.byWidgetPredicate(
                  (w) => w is IconButton && w.tooltip == 'Soal sebelumnya',
                ),
              )
              .onPressed,
          isNull,
        );
        expect(
          tester
              .widget<RadioListTile<String>>(
                find.byKey(const ValueKey('answer-33-A')),
              )
              .enabled,
          isFalse,
        );
        controller.isSubmitting.value = false;
        await tester.pumpAndSettle();
        expect(find.text('Soal 3 dari 3'), findsOneWidget);
        expect(controller.submissions, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      '${post ? 'Post' : 'Pre'}test empty, loading and retry states',
      (tester) async {
        controller.questions.clear();
        await mount(tester, post: post);
        expect(
          find.text('Soal ${post ? 'Post-Test' : 'Pre-Test'} belum tersedia.'),
          findsOneWidget,
        );
        await tester.tap(find.text('Muat Ulang'));
        expect(controller.retried, post ? 'post' : 'pre');
        controller.isLoading.value = true;
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        controller.isLoading.value = false;
        controller.errorMessage.value = 'Gagal memuat soal.';
        await tester.pumpAndSettle();
        expect(find.text('Gagal memuat soal.'), findsOneWidget);
        await tester.tap(find.text('Coba Lagi'));
        expect(controller.retried, post ? 'post' : 'pre');
        controller.errorMessage.value = '';
        controller.questions.assignAll([_question(88)]);
        await tester.pumpAndSettle();
        expect(find.text('Soal 1 dari 1'), findsOneWidget);
        await choose(tester, 88, 'B');
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNotNull,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final dark in [false, true]) {
    for (final size in [
      const Size(320, 640),
      const Size(844, 390),
      const Size(1280, 900),
    ]) {
      testWidgets('Long questions fit $size with 200% text, dark=$dark', (
        tester,
      ) async {
        controller.questions.assignAll([
          _question(11, long: true),
          _question(22),
        ]);
        await mount(tester, dark: dark, size: size, scale: 2);
        await choose(tester, 11, 'A');
        expect(
          tester.getRect(find.text('Berikutnya')).bottom,
          lessThanOrEqualTo(size.height),
        );
        await tester.tap(find.text('Berikutnya'));
        await tester.pumpAndSettle();
        expect(find.text('Soal 2 dari 2'), findsOneWidget);
        expect(
          tester
              .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
              .controller!
              .offset,
          0,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'Keyboard selects answers and a new question set resets position',
    (tester) async {
      await mount(tester);
      await choose(tester, 11, 'A');
      for (var tab = 0; tab < 8; tab++) {
        final focused = FocusManager.instance.primaryFocus?.context;
        if (focused?.findAncestorWidgetOfExactType<RadioListTile<String>>() !=
            null) {
          break;
        }
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(controller.answers['11'], 'B');
      await tester.tap(find.text('Berikutnya'));
      await tester.pumpAndSettle();
      controller.questions.assignAll([_question(44)]);
      controller.answers.clear();
      await tester.pumpAndSettle();
      expect(find.text('Soal 1 dari 1'), findsOneWidget);
      expect(find.byKey(const ValueKey('question-44')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  if (Platform.environment['SIKERA_CAPTURE_ASSESSMENT'] == '1') {
    for (final dark in [false, true]) {
      testWidgets('Capture assessment, dark=$dark', (tester) async {
        await (FontLoader(
          'MaterialIcons',
        )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
        final font = File('C:/Windows/Fonts/arial.ttf');
        if (font.existsSync()) {
          await (FontLoader('Roboto')..addFont(
                Future.value(ByteData.sublistView(font.readAsBytesSync())),
              ))
              .load();
        }
        await mount(tester, dark: dark);
        await choose(tester, 11, 'B');
        final boundary =
            captureKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        void repaint(RenderObject object) {
          object.markNeedsPaint();
          object.visitChildren(repaint);
        }

        repaint(boundary);
        await tester.pump();
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 2);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          await File(
            'build/assessment-${dark ? 'dark' : 'light'}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
        expect(find.byType(TestQuestionPager), findsOneWidget);
      });
    }
  }
}
