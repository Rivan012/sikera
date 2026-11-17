# Onboarding SIKERA

Onboarding memakai GetX, PageView, dan shared_preferences yang sudah ada. Tidak ada package baru, perubahan API, atau perubahan alur autentikasi.

## Alur

- Splash memeriksa sesi. Sesi aktif menuju Home bila persetujuan Terms & Privacy sudah tersimpan untuk akun tersebut; jika belum, menuju halaman persetujuan.
- Tanpa sesi: `onboarding_completed` belum ada/false menuju Onboarding; true menuju Login.
- Selanjutnya menggeser PageView dengan animasi 350 ms. Swipe juga memperbarui tiga dot.
- Lewati pada halaman 1/2 dan Mulai Sekarang pada halaman 3 menyimpan `onboarding_completed = true`, lalu mengganti stack navigasi dengan Login. Pendaftaran tetap melalui tautan Register di Login.
- Jika aplikasi ditutup sebelum selesai/melewati, status tidak ditulis dan onboarding muncul kembali.
- Logout tidak menghapus status onboarding. Jika penyimpanan gagal, halaman menampilkan pesan dan tombol dapat dicoba lagi.

## Struktur

`lib/app/modules/onboarding/` mengikuti pola modul proyek:

- `onboarding_data.dart`: tiga judul, deskripsi, dan pilihan ilustrasi.
- `onboarding_controller.dart`: PageController, indeks aktif, navigasi, dan penyelesaian.
- `onboarding_page.dart`: susunan PageView, tombol, tema mint terang/gelap.
- `widgets/onboarding_item.dart`: ilustrasi dan konten halaman yang dapat digulir.
- `widgets/page_indicator.dart`: tiga dot dan label aksesibilitas halaman aktif.

Integrasi berada di `storage_service.dart`, `splash_page.dart`, `app_pages.dart`, dan `app_routes.dart`. `main.dart` tidak perlu diubah.

## Menjalankan

```powershell
flutter pub get
flutter run
```

Untuk mengulang onboarding saat development, logout terlebih dahulu jika ada sesi aktif, hentikan aplikasi, lalu:

```powershell
flutter run --dart-define=RESET_ONBOARDING=true
```

Flag hanya berlaku pada debug build. Hapus flag pada run berikutnya untuk menguji persistensi normal. Hot restart dengan flag masih aktif akan mereset status lagi. Hot reload tidak menjalankan ulang inisialisasi.

Alternatif di kode pengujian/debug: `await StorageService.resetOnboarding();`. Metode ini hanya menghapus key onboarding, bukan token, profil, atau tema. Setelah reset, buka kembali aplikasi atau navigasikan ke `Routes.ONBOARDING` untuk pratinjau langsung.

## Pengujian

```powershell
flutter test test/onboarding_test.dart test/splash_test.dart
flutter test --dart-define=RESET_ONBOARDING=true test/onboarding_test.dart --plain-name "Development reset flag"
flutter analyze
```

Pengujian mencakup first launch, pengguna kembali, sesi aktif, skip dari dua halaman, swipe, next/finish, dot aktif, penghapusan back stack, persistensi flag, reset terisolasi, klik cepat, status loading/error, dan layout terang/gelap pada 320×568, 844×390, serta 800×1024 dengan teks hingga 200%.

Hasil verifikasi: 19 tes onboarding/splash lulus, satu tes capture tambahan lulus, dan tes flag reset dengan dart-define lulus. `flutter analyze --no-pub` tidak menemukan masalah. Suite seluruh proyek: 94 lulus dan 1 gagal di `test/education_module_test.dart`, karena ekspektasi banner masih menggunakan localhost sementara `ApiConstants.baseUrl` menggunakan domain produksi. File edukasi dan konfigurasi API tersebut tidak diubah dalam pekerjaan onboarding.

Uji manual perangkat: install bersih → Splash → tiga halaman → Mulai Sekarang → Login; tutup/buka kembali → Login. Ulangi menggunakan Lewati. Login dengan akun valid → pembukaan berikutnya tetap Home. Tombol kembali dari Login tidak membuka onboarding lagi.

## Pemeriksaan visual

- PASS, identitas/purpose: warna mint/toska berasal dari logo dan splash; tema aplikasi lain tidak diubah. Logo asli, buku/kalender/forum, dan ikon akun menjelaskan isi setiap halaman.
- PASS, komposisi: ENERGY 2 / RHYTHM 2 / MOTION 1; satu ilustrasi utama, judul, deskripsi, dan CTA. Tidak ada statistik/testimoni buatan, gradient, glow, atau dekorasi pemasaran.
- PASS, layout: PageView berisi konten scrollable; footer terpisah dan SafeArea menjaga tombol tetap terjangkau. Batas lebar 600 menjaga keterbacaan tablet.
- PASS, interaksi: semua tombol memiliki handler; animasi tombol mengikuti preferensi reduce-motion, controller dibuang saat rute selesai, dan penyimpanan ditunggu sebelum navigasi.
- PASS, teks/status: pesan error memiliki tindakan pemulihan; loading menonaktifkan tombol. Dot mengumumkan halaman aktif, ilustrasi dekoratif dikeluarkan dari semantics.

Pratinjau otomatis opsional pada Windows: jalankan test dengan environment `SIKERA_CAPTURE_ONBOARDING=1`. Gambar berada di `build/onboarding-{light,dark}-{1,2,3}.png`; renderer pengujian memakai Arial sebagai pengganti font runtime. Pengujian widget bukan pengganti pemeriksaan TalkBack atau launch native pada perangkat.
