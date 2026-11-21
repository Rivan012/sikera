# Changelog

## 2026-11-21 - Penggantian Sementara Semua Banner Modul dengan Aset Statis

### Konteks
Endpoint banner modul di API belum menyediakan gambar banner final untuk masing-masing modul. Untuk sementara, seluruh banner modul di aplikasi menggunakan satu gambar aset statis yang sama (`assets/banner/banner.png`), sedangkan indikator progres dan tombol aksi pada halaman Beranda (`Ruang Belajar`) tetap dirender dinamis di atas bagian bawah banner.

### Daftar Perubahan
1. **Aset Banner (`assets/banner/banner.png`)**
   - Mengganti berkas `assets/banner/banner.png` dengan desain banner modul baru (`376x188`).
2. **Komponen `ModuleBanner` (`lib/app/modules/education/widgets/module_banner.dart`)**
   - Menambahkan flag sementara `ModuleBanner.useStaticPlaceholderBanner = true` dan konstanta `ModuleBanner.staticPlaceholderAsset = 'assets/banner/banner.png'`.
   - Selama flag bernilai `true`, seluruh pemakaian `ModuleBanner` di aplikasi (Beranda, tab Edukasi/Materi, dan Detail Modul) langsung menampilkan `assets/banner/banner.png` tanpa memanggil endpoint `/api/v1/modules/{id}/banner`.
   - Menambahkan properti opsional `alignment` (default `Alignment.topCenter`) dan `backgroundColor` agar posisi ilustrasi banner tetap utuh.
3. **Kartu Ruang Belajar di Beranda (`lib/app/modules/home/home_tab.dart`)**
   - Kartu modul pada carousel `Ruang Belajar` menampilkan `ModuleBanner` sebagai latar banner untuk setiap modul.
   - Informasi progres (`X dari Y submateri selesai`, persentase, `LinearProgressIndicator`) dan tombol aksi (`Mulai Belajar` / `Lanjutkan Belajar` / `Baca Ulang Materi`) ditumpuk di atas bagian bawah banner dengan kontras teks gelap agar tetap terbaca pada tema terang maupun gelap.
4. **Kartu Modul di Tab Edukasi/Materi (`lib/app/modules/education/education_tab.dart`)**
   - Setiap kartu modul menampilkan `ModuleBanner` di sisi kanan kartu dengan efek gradasi transparan ke kiri (`ShaderMask` + `BlendMode.dstIn`) sehingga banner menyatu halus ke permukaan kartu dan area teks di kiri tetap terbaca jelas.
   - Pada skala teks aksesibilitas besar (`2.0x`), banner disembunyikan otomatis agar teks memiliki ruang penuh tanpa terpotong.
5. **Pengujian (`test/home_tab_test.dart`, `test/education_module_test.dart`, & `test/education_tab_test.dart`)**
   - Menambahkan pengujian default banner statis di `test/education_module_test.dart` sambil tetap menjaga cakupan uji format respons API (SVG, PNG, JPG, fallback 404).
   - Menyesuaikan pengujian `Ruang Belajar` di `test/home_tab_test.dart` untuk memverifikasi rendering `ModuleBanner`, overlay progres, dan tombol aksi.
   - Memperbarui pengujian `EducationTab` di `test/education_tab_test.dart` untuk memverifikasi banner gradasi kanan (`ModuleBanner` + `ShaderMask`) pada ukuran mobile dan tablet.

### Panduan Migrasi ke Banner API Nanti
Ketika gambar banner untuk setiap modul sudah tersedia di backend (`GET /api/v1/modules/{id}/banner` atau field `banner_image`):
1. Buka `lib/app/modules/education/widgets/module_banner.dart`.
2. Ubah `static bool useStaticPlaceholderBanner = false;` (atau hapus cabang `useStaticPlaceholderBanner` dan komentar `TODO(api-banner)`).
3. Pastikan setiap gambar banner dari API memiliki ruang kosong di ~40% bagian bawah (atau sesuaikan `artworkClearance` serta warna transisi overlay di `_LearningModules._buildSlideContent` pada `lib/app/modules/home/home_tab.dart` jika komposisi banner API berbeda).
4. Perbarui pengujian terkait di `test/education_module_test.dart` dan `test/home_tab_test.dart`, lalu jalankan `flutter analyze` dan `flutter test`.
