# SIKERA

SIKERA (*Sistem Informasi Kesehatan Reproduksi Remaja & Edukasi Mahasiswa*) adalah aplikasi Flutter untuk membantu mahasiswa memperoleh edukasi kesehatan reproduksi yang akurat, aman, dan mudah dipahami.

Aplikasi ini menggabungkan materi pembelajaran, asesmen diri, pencatatan perawatan diri, diskusi forum, serta fitur gamifikasi dalam satu pengalaman yang mendukung kebiasaan hidup sehat dan non-judgmental.

## Fitur Utama

- Materi edukasi kesehatan reproduksi berbasis modul dan submateri
- Pre-test, post-test, flipbook, dan video pembelajaran
- Perhitungan siklus menstruasi, PBAC, dan indeks massa tubuh
- Panduan kebersihan dan darah haid
- Poster edukasi, studi kasus, forum, trivia, dan myth-fact
- Profil pengguna, poin, serta kemajuan belajar
- Dukungan tema terang dan gelap
- Penyimpanan sesi login dan persetujuan kebijakan

## Teknologi

- Flutter dan Dart
- GetX untuk state management, dependency injection, dan routing
- HTTP untuk integrasi REST API
- Shared Preferences untuk penyimpanan lokal
- Flutter SVG untuk aset SVG
- YouTube Iframe untuk video pembelajaran

## Persyaratan

- Flutter SDK yang mendukung Dart `^3.12.2`
- Android Studio atau VS Code
- Android SDK untuk pengembangan Android
- Chrome atau browser lain untuk pengembangan web
- Akses ke REST API SIKERA

## Instalasi

1. Clone repository.

   ```bash
   git clone https://github.com/Rivan012/sikera.git
   cd sikera
   ```

2. Ambil dependency Flutter.

   ```bash
   flutter pub get
   ```

3. Jalankan aplikasi.

   ```bash
   flutter run
   ```

Untuk menjalankan pada perangkat Android atau emulator tertentu:

```bash
flutter devices
flutter run -d <device-id>
```

## Konfigurasi API

Base URL aplikasi diatur di:

```text
lib/app/core/constants/api_constants.dart
```

Nilai bawaan:

```dart
static const String baseUrl = 'https://sikera.my.id/api/v1';
```

Dokumentasi endpoint tersedia di [API_DOC.md](API_DOC.md).

## Pengujian

Jalankan seluruh test widget dan test unit:

```bash
flutter test
```

Untuk memeriksa masalah analisis Dart:

```bash
flutter analyze
```

## Struktur Direktori

```text
lib/
  app/
    core/       Konfigurasi, tema, service, dan widget bersama
    data/       Model dan sumber data
    modules/    Fitur autentikasi, edukasi, forum, dan self-care
    routes/     Routing aplikasi
  main.dart
test/           Unit test dan widget test
assets/         Logo, banner, dan ikon
android/        Konfigurasi aplikasi Android
web/            Konfigurasi aplikasi web
```

## Lisensi

Lisensi proyek belum dicantumkan dalam repository. Hubungi pemilik repository sebelum menggunakan atau mendistribusikan proyek ini.
