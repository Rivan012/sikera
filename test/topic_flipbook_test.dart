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
import 'package:sikera/app/modules/education/topic_page.dart';
import 'package:sikera/app/modules/education/widgets/topic_flipbook.dart';
import 'package:sikera/app/modules/education/widgets/topic_video_player.dart';

class _EducationController extends EducationController {
  int retries = 0;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchTopic(int moduleId, int topicId) async => retries++;
}

void main() {
  final content = List.generate(
    40,
    (index) =>
        'Paragraf uji $index. Isi bacaan untuk menguji pergantian halaman tanpa kehilangan teks.',
  ).join('\n\n');
  final topic = TopicModel(
    id: 1,
    topicCode: '1.1',
    title: 'Materi uji flipbook',
    contentHtml: content,
  );
  final captureKey = GlobalKey();
  var finished = 0;

  Future<void> mount(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    bool dark = false,
    double scale = 1,
    bool reduceMotion = false,
    TopicModel? data,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final theme = dark ? AppTheme.darkTheme : AppTheme.lightTheme;
    await tester.pumpWidget(
      MaterialApp(
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
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: reduceMotion,
          ),
          child: child!,
        ),
        home: RepaintBoundary(
          key: captureKey,
          child: Scaffold(
            appBar: AppBar(title: const Text('Materi Pembelajaran')),
            body: TopicFlipbook(
              topic: data ?? topic,
              onFinished: () => finished++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test('HTML preserves paragraph, list and entity boundaries', () {
    expect(
      topicBookPages(
        '<h2>Judul &amp; Isi</h2><p>Satu<br>Dua</p><ol><li>Pertama</li><li>Kedua</li></ol><script>hidden()</script><style>hidden</style>',
      ),
      ['Judul & Isi\n\nSatu\nDua\n\n1. Pertama\n\n2. Kedua'],
    );
    expect(topicBookPages(null), isEmpty);
    expect(topicBookPages('<p> &nbsp; </p>'), isEmpty);
  });

  test('Long content retains all text and does not split words', () {
    final pages = topicBookPages(content);
    expect(pages.length, greaterThan(1));
    expect(
      pages.join(' ').replaceAll(RegExp(r'\s+'), ' '),
      content.replaceAll(RegExp(r'\s+'), ' '),
    );
    final longWord = List.filled(1500, 'x').join();
    expect(topicBookPages(longWord), [longWord]);
    expect(
      topicBookPages('Awal $longWord akhir').join(' '),
      'Awal $longWord akhir',
    );
  });

  testWidgets('Buttons, swipe, keyboard, page boundaries and completion', (
    tester,
  ) async {
    finished = 0;
    await mount(tester);
    final total = topicBookPages(content).length + 1;
    expect(find.text('Halaman 1 dari $total'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_left_rounded),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Mulai Membaca'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman 2 dari $total'), findsOneWidget);
    await tester.tap(find.byTooltip('Halaman berikutnya'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman 3 dari $total'), findsOneWidget);
    await tester.tap(find.byTooltip('Halaman sebelumnya'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-350, 0));
    await tester.pumpAndSettle();
    expect(find.text('Halaman 3 dari $total'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('Halaman 2 dari $total'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Kembali ke sampul'));
    await tester.pumpAndSettle();
    expect(find.text('Halaman 1 dari $total'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(find.text('Halaman $total dari $total'), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(
            find.widgetWithIcon(IconButton, Icons.chevron_right_rounded),
          )
          .onPressed,
      isNull,
    );
    await tester.ensureVisible(find.text('Selesai Membaca'));
    await tester.tap(find.text('Selesai Membaca'));
    expect(finished, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.text('Halaman 1 dari $total'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets('Responsive pages and enlarged text, dark=$dark', (
      tester,
    ) async {
      for (final size in [
        const Size(320, 640),
        const Size(844, 390),
        const Size(1280, 900),
      ]) {
        await mount(tester, size: size, dark: dark, scale: 2);
        await tester.sendKeyEvent(LogicalKeyboardKey.end);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Selesai Membaca'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          tester.getRect(find.byType(PageView)).right,
          lessThanOrEqualTo(size.width),
        );
        expect(
          tester.getRect(find.text('Selesai Membaca')).bottom,
          lessThanOrEqualTo(size.height),
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pumpAndSettle();
      }
    });
  }

  testWidgets('Reduced motion, empty content, and changed topic', (
    tester,
  ) async {
    await mount(tester, reduceMotion: true);
    await tester.tap(find.byTooltip('Halaman berikutnya'));
    await tester.pump();
    expect(tester.widget<PageView>(find.byType(PageView)).controller!.page, 1);
    await mount(
      tester,
      data: TopicModel(id: 2, topicCode: '1.2', title: 'Materi kosong'),
    );
    expect(find.text('Halaman 1 dari 2'), findsOneWidget);
    await tester.tap(find.text('Mulai Membaca'));
    await tester.pumpAndSettle();
    expect(find.text('Isi materi belum tersedia.'), findsOneWidget);
    expect(find.text('Kembali ke Modul'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Video lives on its own page and is removed when leaving it', (
    tester,
  ) async {
    await mount(
      tester,
      data: TopicModel(
        id: 3,
        topicCode: '1.3',
        title: 'Materi dengan video',
        contentHtml: '<p>Isi uji</p>',
        youtubeVideoId: 'v3F4QW_h32M',
      ),
    );
    expect(find.byType(TopicVideoPlayer), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.end);
    await tester.pumpAndSettle();
    expect(find.byType(TopicVideoPlayer), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.pumpAndSettle();
    expect(find.byType(TopicVideoPlayer), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Topic page loading, error retry, empty and loaded states', (
    tester,
  ) async {
    Get.testMode = true;
    final controller =
        Get.put<EducationController>(_EducationController())
            as _EducationController;
    addTearDown(Get.reset);
    controller.isLoading.value = true;
    await tester.pumpWidget(
      GetMaterialApp(theme: AppTheme.lightTheme, home: const TopicPage()),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    controller.isLoading.value = false;
    controller.errorMessage.value = 'Gagal memuat submateri.';
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coba Lagi'));
    expect(controller.retries, 1);
    controller.errorMessage.value = '';
    await tester.pumpAndSettle();
    expect(find.text('Materi tidak ditemukan.'), findsOneWidget);
    controller.currentTopic.value = topic;
    await tester.pumpAndSettle();
    expect(find.byType(TopicFlipbook), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  if (Platform.environment['SIKERA_CAPTURE_FLIPBOOK'] == '1') {
    testWidgets('Capture flipbook with labelled test content', (tester) async {
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
      for (final dark in [false, true]) {
        await tester.pumpWidget(const SizedBox.shrink());
        await mount(tester, dark: dark);
        await tester.sendKeyEvent(LogicalKeyboardKey.home);
        await tester.pumpAndSettle();
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/logo/sikera_logo_putih.png'),
            captureKey.currentContext!,
          ),
        );
        await tester.pumpAndSettle();
        for (final page in ['cover', 'content']) {
          if (page == 'content') {
            await tester.tap(find.text('Mulai Membaca'));
            await tester.pumpAndSettle();
          }
          final boundary =
              captureKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File(
              'build/flipbook-${dark ? 'dark' : 'light'}-$page.png',
            ).writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      }
    });
  }
}
