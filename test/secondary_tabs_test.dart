import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sikera/app/core/constants/api_constants.dart';
import 'package:sikera/app/core/theme/app_theme.dart';
import 'package:sikera/app/data/models/user_model.dart';
import 'package:sikera/app/modules/profile/profile_controller.dart';
import 'package:sikera/app/modules/profile/profile_tab.dart';
import 'package:sikera/app/modules/selfcare/selfcare_controller.dart';
import 'package:sikera/app/modules/selfcare/selfcare_tab.dart';
import 'package:sikera/app/routes/app_pages.dart';

class _SelfcareController extends SelfcareController {
  int refreshes = 0;
  int bloodLoads = 0;
  int hygieneLoads = 0;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchSummary({bool forceRefresh = false}) async {
    refreshes++;
  }

  @override
  Future<void> fetchBloodGuides({bool forceRefresh = false}) async {
    bloodLoads++;
  }

  @override
  Future<void> fetchHygieneGuides({bool forceRefresh = false}) async {
    hygieneLoads++;
  }
}

class _ProfileController extends ProfileController {
  int refreshes = 0;
  int logouts = 0;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> fetchProfile({bool forceRefresh = false}) async {
    refreshes++;
  }

  @override
  void toggleTheme(bool value) {
    isDarkMode.value = value;
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Future<void> logout() async {
    logouts++;
  }
}

void main() {
  late _SelfcareController selfcare;
  late _ProfileController profile;
  final captureKey = GlobalKey();
  final routes = [
    Routes.SELFCARE_PERIOD,
    Routes.SELFCARE_BMI,
    Routes.SELFCARE_BLOOD_GUIDE,
    Routes.SELFCARE_HYGIENE_GUIDE,
    Routes.TERMS_OF_SERVICE,
    Routes.PRIVACY_POLICY,
  ];

  setUp(() {
    Get.testMode = true;
    selfcare = _SelfcareController();
    selfcare.isFemale.value = true;
    selfcare.summaryData.value = {
      'latest_bmi': {
        'bmi_value': 20.6,
        'category': 'Normal',
        'advice':
            'Saran dari respons uji untuk menjaga pola makan dan aktivitas.',
      },
    };
    profile = _ProfileController();
    profile.user.value = UserModel(
      id: 1,
      name: 'Mahasiswa Dengan Nama Panjang untuk Pengujian',
      email: 'mahasiswa.dengan.alamat.panjang@example.com',
      prodi: 'Program Studi dengan Nama Panjang untuk Pengujian',
      fakultas: 'Fakultas dengan Nama Panjang untuk Pengujian',
      nim: '12345678901234567890',
      gender: 'P',
      points: 120,
      streakDays: 3,
    );
    Get.put<SelfcareController>(selfcare);
    Get.put<ProfileController>(profile);
  });

  tearDown(() => Get.reset());

  Future<void> mount(
    WidgetTester tester,
    Widget tab, {
    double width = 390,
    double height = 844,
    bool dark = false,
    double textScale = 1,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = Size(width, height);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    profile.isDarkMode.value = dark;
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
        home: RepaintBoundary(key: captureKey, child: tab),
        getPages: routes
            .map(
              (route) => GetPage(
                name: route,
                page: () => Scaffold(appBar: AppBar(), body: Text(route)),
              ),
            )
            .toList(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  for (final dark in [false, true]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets('Selfcare fits 320px at $textScale text scale, dark=$dark', (
        tester,
      ) async {
        await mount(
          tester,
          const SelfcareTab(),
          width: 320,
          dark: dark,
          textScale: textScale,
        );
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(ListView), const Offset(0, -2200));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'Profile fits 320px with long fields at $textScale text scale, dark=$dark',
        (tester) async {
          await mount(
            tester,
            const ProfileTab(),
            width: 320,
            dark: dark,
            textScale: textScale,
          );
          expect(tester.takeException(), isNull);
          await tester.drag(find.byType(ListView), const Offset(0, -2400));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('Selfcare tools retain routes and guide loading', (tester) async {
    await mount(tester, const SelfcareTab());
    for (final action in [
      ('Catat haid', Routes.SELFCARE_PERIOD, null),
      ('Riwayat', Routes.SELFCARE_PERIOD, {'tab': 2}),
      ('Simulasi', Routes.SELFCARE_PERIOD, {'tab': 3}),
      ('Hitung IMT', Routes.SELFCARE_BMI, null),
      ('Karakteristik haid', Routes.SELFCARE_BLOOD_GUIDE, null),
      ('Kebersihan reproduksi', Routes.SELFCARE_HYGIENE_GUIDE, null),
    ]) {
      await tap(tester, find.text(action.$1));
      expect(Get.currentRoute, action.$2);
      expect(Get.arguments, action.$3);
      Get.back();
      await tester.pumpAndSettle();
    }
    expect(selfcare.bloodLoads, 1);
    expect(selfcare.hygieneLoads, 1);
  });

  for (final dark in [false, true]) {
    testWidgets('Selfcare missing summary, loading and retry, dark=$dark', (
      tester,
    ) async {
      selfcare.summaryData.value = null;
      await mount(tester, const SelfcareTab(), dark: dark);
      expect(
        find.text(
          'Belum ada hasil IMT. Masukkan tinggi dan berat badan untuk mulai mencatat.',
        ),
        findsOneWidget,
      );
      expect(
        find.text('Mulai dari catatan hari pertama haidmu.'),
        findsOneWidget,
      );
      selfcare.isLoading.value = true;
      await tester.pump();
      expect(find.text('Memuat catatan kesehatan...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      selfcare.isLoading.value = false;
      selfcare.errorMessage.value = 'Ringkasan belum dapat dimuat. Coba lagi.';
      await tester.pumpAndSettle();
      expect(find.text(selfcare.errorMessage.value), findsOneWidget);
      await tester.tap(find.text('Coba Lagi'));
      await tester.pumpAndSettle();
      expect(selfcare.refreshes, 1);
      selfcare.errorMessage.value = '';
      await tester.pumpAndSettle();
      expect(find.text('Hitung IMT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Tapping the avatar opens the full profile photo', (
    tester,
  ) async {
    const path = '/storage/avatars/student.png';
    final url = Uri.parse(ApiConstants.baseUrl).resolve(path).toString();
    final provider = NetworkImage(url);
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(8, 8);
    picture.dispose();
    PaintingBinding.instance.imageCache.putIfAbsent(
      provider,
      () => OneFrameImageStreamCompleter(Future.value(ImageInfo(image: image))),
    );
    addTearDown(() => provider.evict());
    profile.user.value = UserModel(id: 1, name: 'Aisyah', avatar: path);
    await mount(tester, const ProfileTab());
    await tester.tap(find.byTooltip('Lihat avatar'));
    await tester.pumpAndSettle();
    final photo = tester.widget<Image>(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(Image),
      ),
    );
    expect(photo.image, provider);
    expect(photo.fit, BoxFit.contain);
    expect(find.text('Foto profil gagal dimuat.'), findsNothing);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Academic and appearance text share left edges', (tester) async {
    await mount(tester, const ProfileTab(), height: 1600);
    double left(String text) => tester.getTopLeft(find.text(text)).dx;
    expect(left('Informasi akademik'), left('Tampilan'));
    for (final text in [
      'Nomor induk mahasiswa (NIM)',
      profile.user.value!.nim!,
      'Program studi',
      'Fakultas',
      'Jenis kelamin',
      'Gunakan tampilan dengan latar gelap.',
    ]) {
      expect(left(text), left('Mode gelap'));
      expect(
        tester.widget<Text>(find.text(text)).textAlign,
        isNot(TextAlign.center),
      );
    }
  });

  testWidgets('Profile theme, legal links and logout confirmation work', (
    tester,
  ) async {
    await mount(tester, const ProfileTab());
    await tap(tester, find.byType(SwitchListTile));
    expect(profile.isDarkMode.value, isTrue);
    expect(Get.isDarkMode, isTrue);
    await tap(tester, find.byType(SwitchListTile));
    expect(profile.isDarkMode.value, isFalse);
    for (final action in [
      ('Syarat & Ketentuan', Routes.TERMS_OF_SERVICE),
      ('Kebijakan Privasi', Routes.PRIVACY_POLICY),
    ]) {
      await tap(tester, find.text(action.$1));
      expect(Get.currentRoute, action.$2);
      Get.back();
      await tester.pumpAndSettle();
    }
    await tap(tester, find.text('Keluar dari akun'));
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(profile.logouts, 0);
    await tap(tester, find.text('Keluar dari akun'));
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();
    expect(profile.logouts, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Profile missing data is honest and supports reload', (
    tester,
  ) async {
    profile.user.value = UserModel(id: 1, name: '');
    await mount(tester, const ProfileTab());
    expect(find.text('Nama belum tersedia'), findsOneWidget);
    expect(find.text('Email belum tersedia'), findsOneWidget);
    await tester.tap(find.byTooltip('Lihat avatar'));
    await tester.pumpAndSettle();
    expect(find.text('Belum ada foto profil.'), findsOneWidget);
    await tester.tap(find.text('Tutup'));
    await tester.pumpAndSettle();
    expect(find.text('mhs@unib.ac.id'), findsNothing);
    profile.user.value = null;
    await tester.pumpAndSettle();
    await tester.tap(find.text('Muat Ulang'));
    await tester.pumpAndSettle();
    expect(profile.refreshes, 1);
  });

  if (Platform.environment['SIKERA_CAPTURE_SECONDARY'] == '1') {
    testWidgets('Capture secondary tabs for review (test data)', (
      tester,
    ) async {
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
        for (final screen in [
          ('selfcare', const SelfcareTab()),
          ('profile', const ProfileTab()),
        ]) {
          await mount(tester, screen.$2, height: 1400, dark: dark);
          final boundary =
              captureKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          await tester.runAsync(() async {
            final image = await boundary.toImage(pixelRatio: 2);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              'build/${screen.$1}-review-${dark ? 'dark' : 'light'}.png',
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
