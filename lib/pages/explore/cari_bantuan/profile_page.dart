// ─────────────────────────────────────────
// Profile Page (unchanged structure, updated styling)
// ─────────────────────────────────────────
import 'package:flutter/material.dart';

import 'models/worker_model.dart';

class ProfilePage extends StatefulWidget {
  final WorkerExploreModel worker;
  const ProfilePage({super.key, required this.worker});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTab = 0;

  final List<String> _tabs = ['Instalasi Listrik', 'Service AC', 'Perbaikan'];

  final List<String> _serviceDescriptions = [
    'Layanan instalasi listrik profesional mencakup pemasangan titik lampu baru, stop kontak, peralatan panel MCB, hingga pemasangan ulung jalur kabel rumah yang antusias untuk identik SNI. Kami menjamin kerapian pekerjaan dan penggunaan material berkualitas tinggi untuk mencegah risiko atau pendek.',
    'Layanan perbaikan dan perawatan AC untuk semua merek. Meliputi pembersihan AC, pengisian freon, perbaikan kebocoran, dan pengecekan komponen. Kami menggunakan alat ukur profesional untuk memastikan AC bekerja optimal.',
    'Layanan perbaikan elektronik rumah tangga meliputi kulkas, mesin cuci, televisi, dan peralatan listrik lainnya. Menggunakan suku cadang original bergaransi untuk hasil perbaikan yang tahan lama.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  pinned: true,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  title: const Text(
                    'Detail Pekerja',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.share_outlined,
                        color: Colors.black87,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section
                      _buildProfileSection(),

                      const SizedBox(height: 20),

                      // Service Tabs + Content
                      _buildServiceSection(),

                      const SizedBox(height: 20),

                      // About Me Section
                      _buildAboutSection(),

                      const SizedBox(height: 20),

                      // Area Layanan Section
                      _buildAreaSection(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom WhatsApp Button
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Photo
          ClipRoundedRect(
            radius: 12,
            child: Container(
              width: 90,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // Placeholder avatar
                  Center(
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue.shade300,
                    ),
                  ),
                  // Blue bottom strip
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1565C0).withOpacity(0.85),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Name + Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Budi Santoso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFFC107), size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'Pria • 34 Tahun',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats Row
                Row(
                  children: [
                    _buildStatChip(Icons.check_circle_outline, '47', 'Pesanan'),
                    const SizedBox(width: 10),
                    _buildStatChip(Icons.star_border, '4.9', 'Rating'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF1565C0)),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'LAYANAN YANG DITAWARKAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Colors.black45,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Tab Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _selectedTab == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1565C0) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1565C0)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // Service Description Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FBFF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFDCEAFB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _serviceDescriptions[_selectedTab],
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Colors.black87,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFDCEAFB)),
              const SizedBox(height: 14),
              _buildBulletItem(
                Icons.workspace_premium_outlined,
                'Pengalaman 5 Thn & Skor Nilai',
              ),
              const SizedBox(height: 8),
              _buildBulletItem(
                Icons.verified_outlined,
                'Aplikasi Sertifikasi Keahlian',
              ),
              const SizedBox(height: 8),
              _buildBulletItem(
                Icons.handyman_outlined,
                'Perbaikan & Upgrade Panel Listrik',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBulletItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF1565C0)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentang Saya',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Saya teknisi listrik berpengalaman dalam menangani instalasi perumahan dan komersial. Saya berkomitmen untuk memberikan layanan yang profesional, aman, dan tepat waktu. Setiap saat saya selalu mengutamakan kepuasan pelanggan dan memberikan pemeliharaan rutin dengan standar keselamatan tinggi.',
            style: TextStyle(
              fontSize: 13.5,
              color: Colors.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Area Layanan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Map placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFE8F4EA),
              child: Stack(
                children: [
                  // Grid lines to simulate map
                  CustomPaint(
                    size: const Size(double.infinity, 160),
                    painter: _MapGridPainter(),
                  ),
                  // Pin
                  const Center(
                    child: Icon(
                      Icons.location_pin,
                      color: Color(0xFF1565C0),
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Area chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildAreaChip('Jakarta Selatan'),
              _buildAreaChip('Jakarta Barat'),
              _buildAreaChip('Tangerang'),
              _buildAreaChip('Depok'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChip(String area) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 12, color: Color(0xFF1565C0)),
          const SizedBox(width: 4),
          Text(
            area,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1565C0),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.chat, color: Colors.white, size: 20),
          label: const Text(
            'WhatsApp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// Helper widget for clipping
class ClipRoundedRect extends StatelessWidget {
  final double radius;
  final Widget child;

  const ClipRoundedRect({super.key, required this.radius, required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }
}

// Simple grid painter to simulate a map
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB2DFDB).withOpacity(0.5)
      ..strokeWidth = 1;

    // Horizontal lines
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw some road-like shapes
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.55),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.4, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, 0),
      Offset(size.width * 0.6, size.height),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
