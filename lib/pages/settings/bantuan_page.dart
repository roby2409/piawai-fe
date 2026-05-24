import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';

// ─────────────────────────────────────────
// STATIC CONTENT PAGE
// Reusable untuk Pusat Bantuan, Kebijakan Privasi, Syarat & Ketentuan
// ─────────────────────────────────────────
class StaticContentPage extends StatelessWidget {
  final String title;
  final List<_ContentSection> sections;

  const StaticContentPage({
    super.key,
    required this.title,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgOuter,
      appBar: AppBar(
        backgroundColor: context.bgContent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: context.black87,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...sections.map((s) => _SectionCard(section: s)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ContentSection {
  final String? title;
  final String body;

  const _ContentSection({this.title, required this.body});
}

class _SectionCard extends StatelessWidget {
  final _ContentSection section;
  const _SectionCard({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (section.title != null) ...[
            Text(
              section.title!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.primary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            section.body,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// HALAMAN SIAP PAKAI
// ─────────────────────────────────────────

class PusatBantuanPage extends StatelessWidget {
  const PusatBantuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticContentPage(
      title: 'Pusat Bantuan',
      sections: [
        _ContentSection(
          title: 'Apa itu Piawai?',
          body:
              'Piawai adalah platform yang menghubungkan pencari jasa dengan penyedia jasa terdekat di sekitar Anda. Temukan tukang, asisten rumah tangga, dan berbagai penyedia jasa lainnya dengan mudah.',
        ),
        _ContentSection(
          title: 'Bagaimana cara mencari pekerja?',
          body:
              'Buka halaman Eksplor, gunakan fitur pencarian atau filter untuk menemukan pekerja sesuai kebutuhan Anda. Tap marker pada peta untuk melihat profil pekerja terdekat.',
        ),
        _ContentSection(
          title: 'Bagaimana cara mendaftar sebagai penyedia jasa?',
          body:
              'Daftar akun, lalu lengkapi profil Anda di halaman Siap Bantu. Tambahkan layanan yang Anda tawarkan beserta harga, aktifkan status tersedia, dan pastikan lokasi Anda sudah diatur.',
        ),
        _ContentSection(
          title: 'Bagaimana cara menghubungi pekerja?',
          body:
              'Tap profil pekerja di peta, lalu tap tombol "Lihat Profil". Di halaman profil, Anda dapat menghubungi pekerja langsung via WhatsApp atau kontak yang tersedia.',
        ),
        _ContentSection(
          title: 'Butuh bantuan lebih lanjut?',
          body:
              'Hubungi tim kami melalui email support@piawai.id atau WhatsApp di 0812-7306-7776. Kami siap membantu Senin–Jumat, pukul 08.00–17.00 WIB.',
        ),
      ],
    );
  }
}

class KebijakanPrivasiPage extends StatelessWidget {
  const KebijakanPrivasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticContentPage(
      title: 'Kebijakan Privasi',
      sections: [
        _ContentSection(
          title: 'Data yang Kami Kumpulkan',
          body:
              'Kami mengumpulkan informasi yang Anda berikan saat mendaftar, termasuk nama, email, nomor telepon, dan lokasi. Data lokasi digunakan untuk menampilkan pekerja terdekat dan tidak dibagikan ke pihak ketiga tanpa izin Anda.',
        ),
        _ContentSection(
          title: 'Penggunaan Data',
          body:
              'Data Anda digunakan untuk menyediakan dan meningkatkan layanan Piawai, menghubungkan Anda dengan penyedia jasa terdekat, serta menampilkan data yang relevan antara pengguna.',
        ),
        _ContentSection(
          title: 'Keamanan Data',
          body:
              'Kami menerapkan enkripsi dan langkah keamanan standar industri untuk melindungi data Anda. Akses ke data pribadi dibatasi hanya untuk keperluan operasional layanan.',
        ),
        _ContentSection(
          title: 'Hak Pengguna',
          body:
              'Anda berhak mengakses, memperbarui, atau menghapus data pribadi Anda kapan saja. Hubungi kami di privacy@piawai.id untuk permintaan terkait data.',
        ),
        _ContentSection(
          title: 'Perubahan Kebijakan',
          body:
              'Kebijakan ini dapat diperbarui sewaktu-waktu. Perubahan signifikan akan diberitahukan melalui email.',
        ),
      ],
    );
  }
}

class SyaratKetentuanPage extends StatelessWidget {
  const SyaratKetentuanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const StaticContentPage(
      title: 'Syarat & Ketentuan',
      sections: [
        _ContentSection(
          title: 'Penggunaan Layanan',
          body:
              'Dengan menggunakan Piawai, Anda menyetujui syarat dan ketentuan ini. Layanan ini hanya dapat digunakan oleh pengguna berusia 17 tahun ke atas.',
        ),
        _ContentSection(
          title: 'Akun Pengguna',
          body:
              'Anda bertanggung jawab menjaga kerahasiaan akun dan kata sandi Anda. Segala aktivitas yang terjadi di akun Anda menjadi tanggung jawab Anda sepenuhnya.',
        ),
        _ContentSection(
          title: 'Tanggung Jawab Penyedia Jasa',
          body:
              'Penyedia jasa bertanggung jawab atas keakuratan informasi yang diberikan, termasuk layanan, harga, dan ketersediaan. Piawai hanya berperan sebagai platform penghubung.',
        ),
        _ContentSection(
          title: 'Larangan',
          body:
              'Dilarang menggunakan platform untuk tujuan penipuan, spam, atau aktivitas ilegal. Pelanggaran dapat mengakibatkan penonaktifan akun secara permanen.',
        ),
        _ContentSection(
          title: 'Batasan Tanggung Jawab',
          body:
              'Piawai tidak bertanggung jawab atas kerugian yang timbul dari transaksi antara pengguna dan penyedia jasa. Pengguna disarankan untuk melakukan verifikasi sebelum menggunakan jasa.',
        ),
      ],
    );
  }
}
