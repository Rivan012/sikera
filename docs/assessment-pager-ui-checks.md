# Pemeriksaan UI Pre-Test dan Post-Test

Tanggal: 22 September 2026. Lingkup: tampilan satu soal per layar.

## Keputusan Desain

- ENERGY 1 / RHYTHM 1 / MOTION 1: fokus pada soal, tanpa animasi perpindahan yang mengganggu membaca.
- Soal tampil tanpa kartu pembungkus; setiap opsi menggunakan radio native agar pilihan tunggal dan navigasi keyboard jelas.
- Warna mengikuti AppTheme SIKERA. Aksen dipakai untuk jawaban terpilih, progres, dan tindakan utama.
- Ukuran soal 20 dan jawaban 16 mengikuti ukuran teks sistem; kalimat panjang tetap dapat digulir.
- Navigasi berada di luar area gulir agar tombol tetap tersedia ketika soal atau opsi panjang.
- Satu komponen dipakai oleh kedua tes untuk menjaga perilaku pemilihan, navigasi, dan pengiriman konsisten.

## Delivery Gate Antislop

- PASS, R-03/R-35: tes widget pada 320x640, 844x390, dan 1280x900 dengan teks 200% lulus di kedua tema; tombol berikutnya tetap berada dalam layar dan soal berikutnya kembali ke posisi gulir awal.
- PASS, R-17/R-18/R-23/R-24/R-36/R-38: UI memakai soal dan jawaban controller, menghitung progres dari jawaban yang valid, serta mempertahankan rute dan API existing. Screenshot hanya memakai konten berlabel uji.
- PASS, R-25: rasio teks soal terpilih 14.65:1 pada tema terang dan 10.87:1 pada tema gelap; teks tombol putih/biru 4.87:1. Radio terpilih memiliki kontras 4.02:1 dan 7.67:1 terhadap latarnya.
- PASS, R-26/R-27: tombol sebelumnya, berikutnya, kirim, dan muat ulang diuji. Status kosong, memuat, gagal memuat, dan mengirim tersedia. Kontrol jawaban serta navigasi dinonaktifkan saat mengirim.
- PASS, R-32/R-34: navigasi Tab dan pemilihan radio dengan tombol panah diuji. Screenshot tema terang dan gelap diperiksa; label tombol dan status terpilih terbaca.
- PASS, R-02/R-28/R-33/R-37: copy menggunakan label tindakan langsung, tidak menambah FAQ atau klaim, dan perubahan ditulis dalam sumber Flutter sesuai arah desain project.
- PASS, Purpose Gate: batas 8 pada sudut opsi membedakan area sentuh; radio, panah, dan ikon kirim menunjuk tindakan sebenarnya. Tidak ada gradien atau ornamen baru.
- PASS, Liveliness: pertanyaan menjadi fokus layar, jarak memisahkan pertanyaan dari pilihan, dan aksen SIKERA menandai pilihan serta tindakan berikutnya.
- PASS, Craftsmanship: hanya satu soal dirender; kembali ke soal sebelumnya mempertahankan dan dapat mengubah jawaban; kirim hanya tersedia di soal terakhir setelah semua soal terjawab.

## Bukti

- `flutter test test/assessment_pager_test.dart`: 11 tes lulus.
- Analisis Flutter pada dua halaman, komponen pager, dan tes: tidak ada masalah.
- `flutter build web --no-wasm-dry-run`: berhasil.
- Screenshot lokal: `build/assessment-light.png` dan `build/assessment-dark.png`.

Tes pengiriman memakai controller uji untuk memeriksa pilihan metode, ID modul, jawaban, dan status mengirim. Pengiriman jawaban ke server produksi tidak dilakukan.
