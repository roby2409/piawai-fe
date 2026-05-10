import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piawai/core/constants.dart';

class SiapBantuPage extends StatefulWidget {
  const SiapBantuPage({super.key});

  @override
  State<SiapBantuPage> createState() => _SiapBantuPageState();
}

class _SiapBantuPageState extends State<SiapBantuPage> {
  int _selectedIndex = 0;

  final List<_SidebarItem> _sidebarItems = const [
    _SidebarItem(icon: Icons.person_outline, label: 'Profil'),
    _SidebarItem(icon: Icons.phone_outlined, label: 'Kontak'),
    _SidebarItem(icon: Icons.work_outline, label: 'Layanan'),
    _SidebarItem(icon: Icons.location_on_outlined, label: 'Area'),
    _SidebarItem(icon: Icons.wifi, label: 'Status'),
    _SidebarItem(icon: Icons.info_outline, label: 'Tentang'),
  ];

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const _ProfilSection();
      case 1:
        return const _KontakSection();
      case 2:
        return _LayananSection();
      case 3:
        return _AreaSection();
      case 4:
        return const _StatusSection();
      case 5:
        return const _TentangSection();
      default:
        return Center(
          child: Text(
            _sidebarItems[_selectedIndex].label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // ── Body: Sidebar + Content ──
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sidebar
                  Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade200, // ← garis tipis pemisah
                          width: 1,
                        ),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: _sidebarItems.length,
                      itemBuilder: (context, index) {
                        final item = _sidebarItems[index];
                        final isActive = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = index),
                          child: Container(
                            height: 68,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFFE0F7F5)
                                  : Colors.transparent,

                              border: Border(
                                left: BorderSide(
                                  color: isActive
                                      ? kPrimary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 22,
                                  color: isActive
                                      ? kPrimary
                                      : Color(0xff9E9E9E),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isActive ? kPrimary : Colors.grey,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Right Content
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// TENTANG SECTION
// ─────────────────────────────────────────
class _TentangSection extends StatefulWidget {
  const _TentangSection();

  @override
  State<_TentangSection> createState() => _TentangSectionState();
}

class _TentangSectionState extends State<_TentangSection> {
  final TextEditingController _bioController = TextEditingController();
  final int _maxChars = 300;

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Tentang Saya',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lengkapi informasi diri Anda untuk membangun kepercayaan dengan pelanggan.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Bio Textarea
          const Text(
            'Bio & Pengalaman Profesional',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              TextField(
                controller: _bioController,
                maxLines: 6,
                maxLength: _maxChars,
                buildCounter:
                    (
                      _, {
                      required currentLength,
                      required isFocused,
                      maxLength,
                    }) => null, // hide default counter
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText:
                      'Ceritakan pengalaman dan keahlian Anda di sini untuk menarik perhatian pencari jasa...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimary),
                  ),
                ),
              ),
              // Character counter bottom-right
              Positioned(
                bottom: 8,
                right: 12,
                child: Text(
                  '${_bioController.text.length} / $_maxChars',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: kPrimary, size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Profil yang lengkap dengan deskripsi yang menarik memiliki peluang 3x lebih besar untuk mendapatkan pesanan.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1e40af)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // TODO: simpan bio
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Helper model
// ─────────────────────────────────────────
class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}

// ─────────────────────────────────────────
// KONTAK SECTION
// ─────────────────────────────────────────
class _KontakSection extends StatefulWidget {
  const _KontakSection();

  @override
  State<_KontakSection> createState() => _KontakSectionState();
}

class _KontakSectionState extends State<_KontakSection> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _igController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _igController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            'Informasi Kontak',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pastikan nomor dan email Anda aktif agar tidak melewatkan tawaran bantuan.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Nomor HP
          const Text(
            'Nomor HP (WhatsApp)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: '81234567890',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Flag Indonesia emoji
                    const Text('🇮🇩', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      '+62',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 20, color: Colors.grey[300]),
                  ],
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Email
          const Text(
            'Email',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'contoh@email.com',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: const Icon(
                Icons.mail_outline,
                color: Colors.grey,
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimary),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Instagram (Opsional)
          const Text(
            'Instagram (Opsional)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _igController,
            decoration: InputDecoration(
              hintText: 'username_kamu',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '@',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimary),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tips Keamanan
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: kBgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimary, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.security_outlined, color: kPrimary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tips Keamanan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Piawai tidak pernah meminta password atau kode OTP Anda melalui WhatsApp, Email, maupun telepon. Pastikan komunikasi hanya terjadi di dalam aplikasi untuk keamanan ekstra.',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // TODO: simpan kontak
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// AREA SECTION
// ─────────────────────────────────────────
class _AreaSection extends StatefulWidget {
  const _AreaSection();

  @override
  State<_AreaSection> createState() => _AreaSectionState();
}

class _AreaSectionState extends State<_AreaSection> {
  double _radius = 15;
  final double _minRadius = 1;
  final double _maxRadius = 50;

  String get _radiusLabel {
    if (_radius % 1 == 0) return '${_radius.toInt()} km';
    return '${_radius.toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Area Layanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: buka halaman atur lokasi
                },
                child: Row(
                  children: const [
                    Text(
                      'Atur Lokasi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 18, color: kPrimary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tentukan jangkauan kerja Anda',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // ── Map Card ──
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGrey),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Map image placeholder
                Stack(
                  children: [
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        // Pakai warna gradient sebagai placeholder map
                        // Ganti dengan Image.network / flutter_map kalau ada
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF0d2137),
                            Color(0xFF0d3b5e),
                            Color(0xFF0a4f7a),
                          ],
                        ),
                      ),
                      child: CustomPaint(painter: _MapPlaceholderPainter()),
                    ),
                    // Radius circle overlay
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 80 + (_radius / _maxRadius) * 60,
                          height: 80 + (_radius / _maxRadius) * 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: kPrimary.withOpacity(0.2),
                            border: Border.all(
                              color: kPrimary.withOpacity(0.6),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Center pin
                    const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.my_location,
                          color: kPrimary,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),

                // Location label
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: kPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jakarta Selatan & Sekitarnya',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Titik Pusat Utama',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Radius Slider ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Radius Jangkauan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                _radiusLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: kPrimary,
              inactiveTrackColor: kGrey,
              thumbColor: kPrimary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              trackHeight: 4,
            ),
            child: Slider(
              value: _radius,
              min: _minRadius,
              max: _maxRadius,
              divisions: 49,
              onChanged: (v) => setState(() => _radius = v),
            ),
          ),

          // Min / Mid / Max labels
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '1 km',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  '25 km',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  '50 km',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Info Box ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline, color: kPrimary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Radius ini menentukan seberapa jauh profil Anda akan muncul pada pencarian pelanggan. Anda hanya akan menerima notifikasi dari area ini.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1e40af)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // TODO: simpan area
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Map Placeholder Painter (garis-garis peta sederhana)
// ─────────────────────────────────────────
class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Grid horizontal
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Grid vertical
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Garis kontur abstrak (simulasi peta)
    final contourPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.3,
        size.width * 0.5,
        size.height * 0.5,
        size.width,
        size.height * 0.35,
      );
    canvas.drawPath(path1, contourPaint);

    final path2 = Path()
      ..moveTo(0, size.height * 0.6)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.7,
        size.width * 0.6,
        size.height * 0.4,
        size.width,
        size.height * 0.6,
      );
    canvas.drawPath(path2, contourPaint);

    final path3 = Path()
      ..moveTo(size.width * 0.1, 0)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.4,
        size.width * 0.4,
        size.height * 0.3,
        size.width * 0.5,
        size.height,
      );
    canvas.drawPath(path3, contourPaint);
  }

  @override
  bool shouldRepaint(_MapPlaceholderPainter oldDelegate) => false;
}

// ─────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────
class _LayananItem {
  final String nama;
  final String deskripsi;
  final String? hargaJam;
  final String? hargaHari;
  final String? hargaProyek;

  const _LayananItem({
    required this.nama,
    required this.deskripsi,
    this.hargaJam,
    this.hargaHari,
    this.hargaProyek,
  });
}

// ─────────────────────────────────────────
// LAYANAN SECTION
// ─────────────────────────────────────────
class _LayananSection extends StatefulWidget {
  const _LayananSection();

  @override
  State<_LayananSection> createState() => _LayananSectionState();
}

class _LayananSectionState extends State<_LayananSection> {
  final List<_LayananItem> _items = const [
    _LayananItem(
      nama: 'Tukang Kebun',
      deskripsi:
          'Pemeliharaan taman, potong rumput, dan penataan tanaman hias.',
      hargaJam: 'Rp 45k',
      hargaHari: 'Rp 250k',
      hargaProyek: null,
    ),
    _LayananItem(
      nama: 'Tukang Pijat',
      deskripsi:
          'Pemeliharaan tubuh untuk relaksasi dan kesehatan. Bawa perlengkapan sendiri.',
      hargaJam: 'Rp 45k',
      hargaHari: 'Rp 250k',
      hargaProyek: null,
    ),
    _LayananItem(
      nama: 'Setrika',
      deskripsi: 'Jasa setrika panggilan cepat dan rapi. Minimal 5kg.',
      hargaJam: 'Rp 30k',
      hargaHari: null,
      hargaProyek: 'Rp 5k/kg',
    ),
    _LayananItem(
      nama: 'Cuci Mobil',
      deskripsi: 'Cuci mobil eksterior dan interior di lokasi pelanggan.',
      hargaJam: null,
      hargaHari: null,
      hargaProyek: 'Rp 65k',
    ),
  ];

  void _showMenuOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: kPrimary),
              title: const Text('Edit Layanan'),
              onTap: () {
                Navigator.pop(context);
                _showTambahLayananSheet(
                  context,
                  existing: _items[index],
                  onSave: (item) => setState(() => _items[index] = item),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Hapus Layanan',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _items.removeAt(index)); // hapus dari list
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTambahDialog(BuildContext context) {
    _showTambahLayananSheet(
      context,
      onSave: (item) => setState(() => _items.add(item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Layanan',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showTambahDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Tambah',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── List Layanan ──
          if (_items.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    Icon(
                      Icons.work_off_outlined,
                      size: 48,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada layanan',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_items.length, (i) {
              final item = _items[i];
              return _LayananCard(
                item: item,
                onMenuTap: () => _showMenuOptions(context, i),
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// LAYANAN CARD
// ─────────────────────────────────────────
class _LayananCard extends StatelessWidget {
  final _LayananItem item;
  final VoidCallback onMenuTap;

  const _LayananCard({required this.item, required this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama + Menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.nama,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onMenuTap,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.more_vert, size: 20, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Deskripsi
          Text(
            item.deskripsi,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          // Harga chips
          Row(
            children: [
              _HargaChip(label: 'Jam', value: item.hargaJam),
              const SizedBox(width: 8),
              _HargaChip(label: 'Hari', value: item.hargaHari),
              const SizedBox(width: 8),
              _HargaChip(label: 'Proyek', value: item.hargaProyek),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// HARGA CHIP
// ─────────────────────────────────────────
class _HargaChip extends StatelessWidget {
  final String label;
  final String? value;

  const _HargaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final bool hasValue = value != null;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 3),
            Text(
              hasValue ? value! : '-',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasValue ? kPrimary : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// TAMBAH LAYANAN BOTTOM SHEET
// Panggil dengan: _showTambahLayananSheet(context)
// ─────────────────────────────────────────

void _showTambahLayananSheet(
  BuildContext context, {
  _LayananItem? existing, // isi kalau mode edit
  void Function(_LayananItem)? onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // penting biar keyboard tidak nutup form
    backgroundColor: Colors.transparent,
    builder: (_) => _TambahLayananSheet(existing: existing, onSave: onSave),
  );
}

class _TambahLayananSheet extends StatefulWidget {
  final _LayananItem? existing;
  final void Function(_LayananItem)? onSave;

  const _TambahLayananSheet({this.existing, this.onSave});

  @override
  State<_TambahLayananSheet> createState() => _TambahLayananSheetState();
}

class _TambahLayananSheetState extends State<_TambahLayananSheet> {
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _jamController = TextEditingController();
  final _hariController = TextEditingController();
  final _proyekController = TextEditingController();

  bool _showTarifError = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _namaController.text = e.nama;
      _deskripsiController.text = e.deskripsi;
      _jamController.text = _stripRp(e.hargaJam);
      _hariController.text = _stripRp(e.hargaHari);
      _proyekController.text = _stripRp(e.hargaProyek);
    }
  }

  String _stripRp(String? val) {
    if (val == null) return '';
    return val.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _deskripsiController.dispose();
    _jamController.dispose();
    _hariController.dispose();
    _proyekController.dispose();
    super.dispose();
  }

  bool get _tarifValid =>
      _jamController.text.trim().isNotEmpty ||
      _hariController.text.trim().isNotEmpty ||
      _proyekController.text.trim().isNotEmpty;

  bool get _canSave => _namaController.text.trim().isNotEmpty && _tarifValid;

  String? _formatHarga(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty) return null;
    // format: "Rp 45k" kalau >= 1000, else "Rp X"
    final num = int.tryParse(clean) ?? 0;
    if (num == 0) return null;
    if (num >= 1000) {
      final k = num ~/ 1000;
      final sisa = num % 1000;
      return sisa == 0 ? 'Rp ${k}k' : 'Rp ${num}';
    }
    return 'Rp $num';
  }

  void _onSimpan() {
    setState(() => _showTarifError = !_tarifValid);
    if (!_canSave) return;

    final item = _LayananItem(
      nama: _namaController.text.trim(),
      deskripsi: _deskripsiController.text.trim(),
      hargaJam: _formatHarga(_jamController.text),
      hargaHari: _formatHarga(_hariController.text),
      hargaProyek: _formatHarga(_proyekController.text),
    );

    widget.onSave?.call(item);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle ──
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.existing != null ? 'Edit Layanan' : 'Tambah Layanan',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.close, size: 22, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Scroll area ──
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Layanan
                  _FieldLabel('Nama Layanan'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _namaController,
                    hint: 'Contoh: Tukang Kebun',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi
                  _FieldLabel('Deskripsi'),
                  const SizedBox(height: 6),
                  _InputField(
                    controller: _deskripsiController,
                    hint: 'Jelaskan layanan yang Anda tawarkan...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),

                  // Tarif
                  const Text(
                    'Tarif Layanan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Isi minimal satu tarif',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),

                  _FieldLabel('Per Jam'),
                  const SizedBox(height: 6),
                  _TarifField(
                    controller: _jamController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  _FieldLabel('Per Hari'),
                  const SizedBox(height: 6),
                  _TarifField(
                    controller: _hariController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  _FieldLabel('Per Proyek'),
                  const SizedBox(height: 6),
                  _TarifField(
                    controller: _proyekController,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),

                  // Error tarif
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _showTarifError && !_tarifValid
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Minimal satu tarif harus diisi (Jam, Hari, atau Proyek)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondChild: const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Simpan Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canSave ? _onSimpan : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Layanan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final void Function(String)? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary),
        ),
      ),
    );
  }
}

class _TarifField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const _TarifField({required this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '0',
        hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
        prefixIcon: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Rp',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 8),
              Container(width: 1, height: 20, color: Colors.grey[300]),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// UPDATE sidebar items di _SiapBantuPageState
// ─────────────────────────────────────────
// Ganti _sidebarItems dengan icon yang baru sesuai screenshot:
//
// final List<_SidebarItem> _sidebarItems = const [
//   _SidebarItem(icon: Icons.person_outline,        label: 'Profil'),
//   _SidebarItem(icon: Icons.contact_page_outlined,  label: 'Kontak'),
//   _SidebarItem(icon: Icons.build_outlined,         label: 'Layanan'),
//   _SidebarItem(icon: Icons.map_outlined,           label: 'Area'),
//   _SidebarItem(icon: Icons.verified_user_outlined, label: 'Status'),
//   _SidebarItem(icon: Icons.info_outline,           label: 'Tentang'),
// ];

// ─────────────────────────────────────────
// PROFIL SECTION
// ─────────────────────────────────────────
class _ProfilSection extends StatefulWidget {
  const _ProfilSection();

  @override
  State<_ProfilSection> createState() => _ProfilSectionState();
}

class _ProfilSectionState extends State<_ProfilSection> {
  final _namaController = TextEditingController(text: 'Alex Johnson');
  String _jenisKelamin = 'Pria'; // 'Pria' | 'Wanita'
  Uint8List? _fotoBytes; // null = pakai placeholder

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: kPrimary,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: kPrimary),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _fotoBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          const Text(
            'Informasi Profil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Lengkapi data diri Anda agar pemesan jasa merasa lebih percaya.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // ── Foto Profil ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGrey),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: _fotoBytes != null
                              ? Image.memory(_fotoBytes!, fit: BoxFit.cover)
                              : Container(
                                  color: kGrey,
                                  child: const Icon(
                                    Icons.person,
                                    size: 52,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),
                      // Camera badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickImage,
                  child: const Text(
                    'Ubah Foto Profil',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Nama Lengkap ──
          const Text(
            'Nama Lengkap',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _namaController,
            decoration: InputDecoration(
              hintText: 'Masukkan nama lengkap',
              hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: kPrimary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Jenis Kelamin ──
          const Text(
            'Jenis Kelamin',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _GenderButton(
                label: 'Pria',
                icon: Icons.male,
                isSelected: _jenisKelamin == 'Pria',
                onTap: () => setState(() => _jenisKelamin = 'Pria'),
              ),
              const SizedBox(width: 12),
              _GenderButton(
                label: 'Wanita',
                icon: Icons.female,
                isSelected: _jenisKelamin == 'Wanita',
                onTap: () => setState(() => _jenisKelamin = 'Wanita'),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // TODO: simpan profil
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// GENDER BUTTON
// ─────────────────────────────────────────
class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? kPrimary : kGrey, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? kPrimary : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? kPrimary : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// STATUS SECTION
// ─────────────────────────────────────────
class _StatusSection extends StatefulWidget {
  const _StatusSection();

  @override
  State<_StatusSection> createState() => _StatusSectionState();
}

class _StatusSectionState extends State<_StatusSection> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──
          const Text(
            'Status Kerja',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ── Toggle Card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGrey),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text kiri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Siap Menerima Kerja',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isAvailable
                            ? 'Aktifkan untuk mulai terlihat oleh pencari jasa di sekitar Anda.'
                            : 'Anda sedang tidak menerima pesanan baru saat ini.',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Toggle
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: _isAvailable,
                    onChanged: (val) => setState(() => _isAvailable = val),
                    activeColor: Colors.white,
                    activeTrackColor: kPrimary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: kGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Info Box ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isAvailable
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isAvailable ? const Color(0xFFBFDBFE) : kGrey,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: _isAvailable ? kPrimary : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isAvailable
                        ? 'Saat status aktif, profil Anda akan muncul di hasil pencarian pelanggan sesuai dengan area dan layanan yang Anda atur.'
                        : 'Status tidak aktif. Profil Anda tidak akan muncul di pencarian pelanggan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isAvailable
                          ? const Color(0xFF1e40af)
                          : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                // TODO: simpan status
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
