class LegalContentSection {
  const LegalContentSection(this.heading, this.body);
  final String heading;
  final String body;
}

const legalReviewNotice =
    'Draf berdasarkan spesifikasi administrasi SIKERA yang diberikan. Bagian bertanda “Perlu konfirmasi pengelola” belum terverifikasi dan perlu diperjelas sebelum kebijakan dipublikasikan sebagai ketentuan final.';
const legalDeveloper =
    'Tim Pengembang SIKERA (D3 Kebidanan & S1 Sistem Informasi Universitas Bengkulu).';
const legalContacts = ['Nayzilaramadani06@gmail.com', 'rivan@rivan.my.id'];
const consentSummary =
    'Dengan menggunakan SIKERA, Anda perlu membaca dan menyetujui Syarat & Ketentuan serta Kebijakan Privasi.';
const consentLabel =
    'Saya telah membaca dan menyetujui Syarat & Ketentuan serta Kebijakan Privasi SIKERA.';

const termsSections = [
  LegalContentSection(
    'Ketentuan Umum',
    'Menurut dokumen administrasi yang diberikan, dengan mengunduh, memasang, atau membuat akun pada SIKERA, pengguna dianggap menyetujui ketentuan layanan yang berlaku. Aplikasi juga meminta persetujuan eksplisit sebelum pengguna melanjutkan ke Home.',
  ),
  LegalContentSection(
    'Batasan Nasihat Medis',
    'Materi edukasi, artikel, interpretasi warna darah haid, skor nyeri NRS, serta kalkulator IMT ditujukan untuk edukasi dan tindakan preventif mandiri. Informasi ini bukan diagnosis medis dan bukan pengganti konsultasi dengan tenaga kesehatan profesional. Dalam kondisi darurat, hubungi fasilitas atau layanan kesehatan terdekat.',
  ),
  LegalContentSection(
    'Mekanisme Evaluasi',
    'Dokumen administrasi menyatakan pengguna baru wajib menyelesaikan Pre-Test sebelum mengakses menu utama. Post-Test digunakan sesuai mekanisme evaluasi aplikasi.\n\nPerlu konfirmasi pengelola: aplikasi yang diperiksa menyediakan Pre-Test per modul, tetapi belum ditemukan pembatasan seluruh menu utama berdasarkan Pre-Test. Ketentuan dan alur pelaksanaannya perlu diselaraskan.',
  ),
  LegalContentSection(
    'Etika Pengguna',
    'Pada Anonymous Peer Sharing dan Case Study Corner, pengguna dilarang:\n\n• Mengunggah konten pornografi eksplisit atau materi pelecehan.\n• Melakukan intimidasi atau cyberbullying.\n• Melakukan pencemaran nama baik atau menyebarkan ujaran kebencian.\n• Menyebarkan data pribadi pihak lain tanpa hak.\n• Menyebarkan informasi medis yang menyesatkan.\n• Mempromosikan obat-obatan terlarang.',
  ),
  LegalContentSection(
    'Pelanggaran',
    'Pengelola dapat menghapus konten yang melanggar ketentuan dan menonaktifkan atau menghapus akun pengguna yang terbukti melakukan pelanggaran.',
  ),
];

const privacySections = [
  LegalContentSection(
    'Data Akun',
    'Dokumen administrasi mencantumkan nama lengkap atau nama samaran, email, institusi perguruan tinggi, program studi, dan angkatan. Formulir aplikasi saat ini juga meminta inisial, NIM, usia, jenis kelamin, agama, fakultas, pendidikan terakhir, serta kata sandi untuk autentikasi.\n\nPerlu konfirmasi pengelola: sumber data institusi dan angkatan serta cakupan akhir data akun belum dijelaskan dalam dokumen yang tersedia.',
  ),
  LegalContentSection(
    'Data Hasil Belajar',
    'Jawaban Pre-Test dan Post-Test dikumpulkan untuk evaluasi pembelajaran. Menurut dokumen administrasi, data digunakan untuk pengolahan statistik penelitian.',
  ),
  LegalContentSection(
    'Data Pemantauan Mandiri',
    'Data meliputi tanggal siklus menstruasi, tingkat nyeri atau dismenore, tinggi badan, dan berat badan untuk kalkulator IMT. Form pencatatan yang tersedia juga mencakup usia haid pertama, keteraturan siklus, volume dan warna darah, skor PBAC/WaLIDD, gejala, serta catatan pribadi yang diisi pengguna.',
  ),
  LegalContentSection(
    'Data Interaksi Komunitas',
    'Pesan atau tanggapan pada forum disimpan untuk menjalankan fitur komunitas. Tampilan forum menggunakan alias atau label anonim. Penyembunyian identitas publik tidak berarti data tidak dapat dikaitkan dengan akun oleh sistem. Jangan menyertakan data pribadi dalam pesan yang Anda unggah.',
  ),
  LegalContentSection(
    'Penggunaan Data',
    'Menurut kebijakan yang diberikan, data digunakan untuk:\n\n• Menjalankan fitur personalisasi.\n• Menghitung keteraturan siklus.\n• Membantu menentukan status gizi.\n• Mengukur efektivitas edukasi melalui perubahan skor Pre-Test dan Post-Test.\n• Menyajikan laporan statistik agregat atau dianonimkan kepada pihak akademik/kampus mitra sesuai kebutuhan program.\n\nPerlu konfirmasi pengelola: rincian mitra penerima laporan, teknik anonimisasi, dan tata kelola penelitian belum tersedia.',
  ),
  LegalContentSection(
    'Keamanan Data',
    'Konfigurasi API produksi saat ini menggunakan HTTPS untuk komunikasi aplikasi dengan server melalui SSL/TLS.\n\nPerlu konfirmasi pengelola: dokumen menyebut perlindungan Secret Diary melalui PIN/biometrik, tetapi fitur dan mekanisme tersebut belum ditemukan pada aplikasi yang diperiksa. Perlindungan ini belum dapat dinyatakan tersedia.\n\nMenurut kebijakan yang diberikan pengelola, data pengguna tidak diperjualbelikan, disewakan, atau dibagikan kepada pihak komersial ketiga untuk kepentingan periklanan.',
  ),
  LegalContentSection(
    'Hak Pengguna',
    'Pengguna dapat memeriksa informasi akun, memperbarui atau memperbaiki informasi akun, meminta penutupan akun, dan meminta penghapusan data riwayat pribadi dengan menghubungi pengelola resmi SIKERA melalui kontak di bawah.\n\nPerlu konfirmasi pengelola: prosedur verifikasi, jangka waktu respons, dan masa penyimpanan data belum dicantumkan. Pengajuan permintaan tidak sama dengan penghapusan data secara otomatis.',
  ),
  LegalContentSection(
    'Status Persetujuan pada Perangkat',
    'Aplikasi menyimpan status persetujuan lokal per akun menggunakan shared_preferences. Status ini tidak merupakan bukti persetujuan yang tersinkron ke server. Menghapus data aplikasi atau memakai perangkat lain dapat menyebabkan permintaan persetujuan ditampilkan kembali.',
  ),
];
