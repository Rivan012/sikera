# Terms & Privacy SIKERA

## Ruang lingkup dan sumber

Implementasi mengikuti brief `Prompt Flutter Terms & Privacy SIKERA.md` yang diberikan pengguna. Dokumen administrasi lengkap tidak tersedia di repository. Teks disimpan dalam `lib/app/modules/legal/data/legal_content.dart`, bukan tersebar dalam widget.

Ini implementasi antarmuka dan alur persetujuan, bukan pendapat hukum atau jaminan kepatuhan. Dokumen ditandai sebagai draf pada UI. Substansi yang perlu diverifikasi pengelola sebelum publikasi final:

- Secret Diary dengan PIN/biometrik tidak ditemukan pada source atau dependency aplikasi. Tidak dinyatakan sebagai fitur keamanan yang sudah tersedia.
- Pre-Test per modul ditemukan, tetapi tidak ditemukan gerbang Pre-Test sebelum semua menu utama. Tidak menambahkan flow Pre-Test baru di luar lingkup tugas.
- HTTPS ditemukan pada base URL produksi; tidak dibuat klaim audit TLS atau enkripsi penyimpanan.
- Forum memakai alias/label anonim, bukan jaminan anonimitas terhadap pengelola/server.
- Nama institusi, angkatan, mitra penelitian, teknik anonimisasi, retensi, dan prosedur penghapusan perlu diperjelas.
- Pernyataan tidak menjual/menyewakan data diteruskan sebagai kebijakan yang diberikan pengelola, bukan hasil audit operasional.

Kontak dan nama tim pengembang diteruskan sesuai brief. Data tambahan yang benar-benar diminta formulir akun/self-care juga dicantumkan agar kebijakan tidak mengabaikannya.

## Route dan alur

- `/terms-of-service`: halaman publik Syarat & Ketentuan.
- `/privacy-policy`: halaman publik Kebijakan Privasi.
- `/terms-privacy-consent`: halaman persetujuan yang memerlukan sesi login.

Register berhasil → persetujuan → checkbox dicentang → Lanjutkan → status disimpan → Home. Checkbox tidak dicentang otomatis. Membuka dokumen atau kembali dari dokumen tidak menyimpan persetujuan.

Login dan Splash memeriksa status yang sama. Home memiliki middleware untuk mencegah navigasi langsung melewati persetujuan. Tombol Keluar pada persetujuan mengakhiri sesi tanpa mencatat penerimaan. Tautan dokumen dapat dibuka sebelum registrasi dan dari Profil setelah persetujuan.

## Penyimpanan

Memakai dependency `shared_preferences` yang sudah ada, dengan key boolean `terms_privacy_accepted_<accountId>`, misalnya `terms_privacy_accepted_7`. Sufiks ID mencegah satu akun menyetujui atas nama akun lain pada perangkat yang sama. ID berasal dari data user hasil autentikasi, bukan input pada halaman persetujuan.

Logout tidak menghapus persetujuan; akun yang sama tidak diminta menyetujui lagi ketika login kembali pada perangkat tersebut. Jika ID akun tidak tersedia, penyimpanan ditolak dan pengguna diminta masuk kembali. Status onboarding tidak diubah.

Catatan batasan: status hanya lokal, tidak tersinkron ke server, tidak berversi, dan bukan audit trail persetujuan yang tahan manipulasi. Data aplikasi yang dihapus/perangkat baru memerlukan persetujuan kembali. Middleware ini bukan kontrol otorisasi backend dan bukan persetujuan penelitian terpisah. Tidak menambah endpoint atau mengubah backend.

## File

Modul baru `lib/app/modules/legal/`:

- `data/legal_content.dart`
- `legal_guard.dart`
- `terms_of_service_page.dart`
- `privacy_policy_page.dart`
- `terms_privacy_consent_page.dart`
- `widgets/legal_document_page.dart`
- `widgets/legal_section.dart`
- `widgets/consent_checkbox.dart`
- `widgets/legal_links.dart`

Integrasi: `storage_service.dart`, controller Login/Register, halaman Register/Profil, Splash, dan dua file routing yang sudah ada. Pengujian: `test/legal_test.dart`, pembaruan fixture akun yang sudah setuju di `test/onboarding_test.dart` dan `test/splash_test.dart`. Tidak ada dependency baru; tidak ada perubahan `main.dart`.

## Menjalankan dan memeriksa

```powershell
flutter run
flutter test test/legal_test.dart test/onboarding_test.dart test/splash_test.dart
flutter analyze
```

Uji manual: registrasi akun baru → persetujuan dengan CTA nonaktif → buka kedua dokumen dan kembali → centang checkbox → Lanjutkan → Home → tutup/buka aplikasi → langsung Home. Coba menutup aplikasi sebelum menyetujui, lalu buka kembali; harus kembali ke persetujuan. Coba akun kedua di perangkat sama; penerimaan akun pertama tidak boleh dipakai.

Tes registrasi/login memakai respons HTTP tiruan; tidak membuat akun atau persetujuan pengguna asli. Pengujian mencakup tombol disabled, link bolak-balik, local persistence, pergantian akun, logout, resume, guard Home, error identitas akun, dan layout 320 piksel dengan teks 100%/200% pada terang/gelap.

Hasil: 14 tes legal dan 1 tes capture lulus; `flutter analyze --no-pub` bersih. Suite seluruh proyek mencatat 108 lulus dan 1 kegagalan lama pada tes URL banner edukasi, yang masih mengharapkan localhost alih-alih domain produksi. Kegagalan tersebut tidak diubah dalam lingkup fitur legal.

## Pemeriksaan UI

- PASS, purpose/identitas: tema aplikasi dipertahankan; dokumen tidak memakai ilustrasi, gradient, badge, atau statistik dekoratif. ENERGY 1 / RHYTHM 1 / MOTION 1 sesuai tugas membaca kebijakan.
- PASS, keterbacaan: judul dokumen diulang dalam konten yang dapat digulir agar tetap terbaca saat app bar terpotong pada ukuran teks besar; section heading dan spasi 24/28 membagi teks panjang.
- PASS, kontrol: dua tautan memakai route nyata; checkbox Material, CTA disabled/loading, dan tombol Keluar berfungsi. Footer CTA berada di luar konten scrollable dan di dalam SafeArea.
- PASS, kejujuran: klaim keamanan/flow yang belum terverifikasi ditandai; sumber dan batasan dokumentasi disebutkan, tanpa mengarang implementasi atau tenggat layanan.
- PASS, ruang lingkup: tidak ada package baru atau sistem routing baru; status disimpan per akun dan perubahan tidak mengubah fitur klinis.

Pratinjau dapat dihasilkan dengan environment `SIKERA_CAPTURE_LEGAL=1` saat menjalankan `test/legal_test.dart` pada Windows. Gambar berada di `build/legal-*.png`; font test memakai Arial. Uji widget tidak menggantikan review hukum, audit keamanan, atau pemeriksaan TalkBack pada perangkat.
