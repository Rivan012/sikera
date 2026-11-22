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
- Google Sign-In untuk autentikasi akun Google

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

### Login Google di perangkat

Tombol Google membuka pemilih akun di perangkat dan mengirim `{"id_token":"<ID token Google>"}` ke `POST /api/v1/auth/login`. Backend memverifikasi token dan mengembalikan `data.token` untuk sesi SIKERA.

- Android memerlukan klien OAuth Android untuk package `com.sikera.app.sikera` dan SHA-1 sertifikat penandatangan build di proyek Google Cloud yang sama dengan klien web SIKERA.
- Di iOS, daftarkan bundle ID Runner di proyek Google yang sama. Berikan ID klien iOS melalui `--dart-define=GOOGLE_CLIENT_ID=<id-klien-ios>` dan isi build setting Xcode `GOOGLE_REVERSED_CLIENT_ID` dengan nilai `REVERSED_CLIENT_ID` dari konfigurasi iOS Google.
- Jika backend memakai klien web yang berbeda, berikan `--dart-define=GOOGLE_SERVER_CLIENT_ID=<id-klien-web>` saat membangun aplikasi. Nilainya harus sama dengan `GOOGLE_CLIENT_ID` di backend Laravel.

### Alamat server

Base URL aplikasi diatur di:

```text
lib/app/core/constants/api_constants.dart
```

Nilai bawaan (dapat ditimpa lewat `--dart-define=API_BASE_URL=<url>`):

```dart
static const String baseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://sikera.my.id/api/v1',
);
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
ios/            Konfigurasi aplikasi iOS
web/            Konfigurasi aplikasi web
```

## Lisensi

Lisensi proyek belum dicantumkan dalam repository. Hubungi pemilik repository sebelum menggunakan atau mendistribusikan proyek ini.
