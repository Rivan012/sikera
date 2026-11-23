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
- Google OAuth 2.0 (Authorization Code + PKCE) melalui `flutter_web_auth_2` dan `crypto`
- `flutter_dotenv` untuk memuat konfigurasi `.env`

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

2. Salin template environment `.env.example` menjadi `.env` lalu isi konfigurasi Google OAuth Client ID Anda.

   ```bash
   cp .env.example .env
   ```

3. Ambil dependency Flutter.

   ```bash
   flutter pub get
   ```

4. Jalankan aplikasi.

   ```bash
   flutter run
   ```

Untuk menjalankan pada perangkat Android atau emulator tertentu:

```bash
flutter devices
flutter run -d <device-id>
```

## Konfigurasi API & Google OAuth 2.0

Konfigurasi disimpan di file `.env` (didaftarkan sebagai asset di `pubspec.yaml` dan diabaikan oleh `.gitignore`). Nilai di `.env` juga tetap dapat ditimpa saat build melalui `--dart-define`.

### Login Google langsung ke Google API (OAuth 2.0 + PKCE)

Tombol Google membuka browser sistem (Custom Tabs di Android / `ASWebAuthenticationSession` di iOS) menuju `https://accounts.google.com/o/oauth2/v2/auth` dengan **PKCE (`S256`)**, menukar `code` langsung ke `https://oauth2.googleapis.com/token` tanpa `client_secret`, lalu mengirim `{"id_token":"<ID token Google>"}` ke `POST /api/v1/auth/login` untuk memperoleh token sesi Laravel Sanctum (`data.token`).

> **Keamanan:** Jangan pernah menyimpan **OAuth Client Secret (`GOCSPX-...`)** di file `.env` aplikasi mobile. Gunakan **OAuth Client ID tipe Android / iOS (Public Client)** yang memang tidak memerlukan `client_secret`.

#### Panduan Setup di Google Cloud Console

1. Buka [Google Cloud Console](https://console.cloud.google.com/) dan pilih proyek Google Cloud Anda (atau buat proyek baru).
2. Buka **APIs & Services → OAuth consent screen** (atau **Google Auth Platform → Branding / Audience**):
   - Pilih tipe **External**, isi nama aplikasi (`SIKERA`), email dukungan, dan email developer.
   - Pada bagian **Scopes**, pastikan `openid`, `.../auth/userinfo.email`, dan `.../auth/userinfo.profile` aktif.
   - Selama status masih **Testing**, tambahkan akun Gmail yang dipakai untuk uji coba ke daftar **Test users**.
3. Ambil **SHA-1 fingerprint** Android Anda (untuk debug/release):

   ```bash
   cd android
   ./gradlew signingReport
   ```

   Salin nilai `SHA1` dari variant `debug` (dan ulangi untuk keystore `release` saat produksi).
4. Buka **APIs & Services → Credentials → + Create Credentials → OAuth client ID**:
   - **Untuk Android**:
     - Application type: **Android**
     - Package name: `com.sikera.app.sikera`
     - SHA-1 certificate fingerprint: tempel SHA-1 dari langkah 3.
     - Setelah dibuat, buka kembali detail Android OAuth Client tersebut, gulir ke **Advanced settings**, lalu **centang `Enable custom URI scheme`** dan simpan.
     - Salin **Client ID** (`xxxxxxxx.apps.googleusercontent.com`) ke `.env` sebagai `GOOGLE_ANDROID_CLIENT_ID`.
   - **Untuk iOS** *(opsional jika membangun iOS)*:
     - Application type: **iOS**
     - Bundle ID: samakan dengan Bundle Identifier `Runner` di Xcode.
     - Salin **Client ID** ke `.env` sebagai `GOOGLE_IOS_CLIENT_ID`.
5. Isi file `.env` di root proyek:

   ```dotenv
   API_BASE_URL=https://sikera.my.id/api/v1
   GOOGLE_ANDROID_CLIENT_ID=1234567890-abcdef.apps.googleusercontent.com
   GOOGLE_IOS_CLIENT_ID=
   ```

   - Redirect URI otomatis dibentuk menjadi `com.googleusercontent.apps.<CLIENT_ID_PREFIX>:/oauth2redirect` dan disinkronkan otomatis ke `AndroidManifest.xml` lewat `android/app/build.gradle.kts` saat build Android.
   - Jika ingin memakai skema package name (`com.sikera.app.sikera:/oauth2redirect`), isi `GOOGLE_ANDROID_REDIRECT_URI=com.sikera.app.sikera:/oauth2redirect` di `.env`.
6. **Sinkronisasi Backend Laravel SIKERA (Wajib):**
   - Karena PKCE mobile menerbitkan `id_token` dengan klaim `aud` bernilai `GOOGLE_ANDROID_CLIENT_ID` (atau `GOOGLE_IOS_CLIENT_ID`), pastikan backend Laravel SIKERA pada `POST /api/v1/auth/login` mengizinkan Client ID mobile tersebut saat memverifikasi `aud` pada `id_token` Google (misalnya dengan memasukkan Android & iOS Client ID ke daftar Client ID yang diizinkan bersama Web Client ID).

### Alamat server

Base URL aplikasi dibaca dari `.env` (`API_BASE_URL`), dapat ditimpa via `--dart-define=API_BASE_URL=<url>`, dengan nilai bawaan `https://sikera.my.id/api/v1` di:

```text
lib/app/core/constants/api_constants.dart
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
