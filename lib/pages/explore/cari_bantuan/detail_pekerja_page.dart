import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF1a56db);

// ─────────────────────────────────────────
// MODEL (sesuaikan dengan model yang sudah ada)
// ─────────────────────────────────────────
class PekerjaDetail {
  final String nama;
  final String jenisKelamin;
  final int usia;
  final String? fotoUrl;
  final String tentang;
  final List<LayananDetail> layananList;
  final String area;
  final String noWa;

  const PekerjaDetail({
    required this.nama,
    required this.jenisKelamin,
    required this.usia,
    this.fotoUrl,
    required this.tentang,
    required this.layananList,
    required this.area,
    required this.noWa,
  });
}

class LayananDetail {
  final String nama;
  final String? hargaJam;
  final String? hargaHari;
  final String? hargaProyek;

  const LayananDetail({
    required this.nama,
    this.hargaJam,
    this.hargaHari,
    this.hargaProyek,
  });
}

// ─────────────────────────────────────────
// DETAIL PEKERJA PAGE
// ─────────────────────────────────────────
class DetailPekerjaPage extends StatefulWidget {
  final PekerjaDetail pekerja;

  const DetailPekerjaPage({super.key, required this.pekerja});

  @override
  State<DetailPekerjaPage> createState() => _DetailPekerjaPageState();
}

class _DetailPekerjaPageState extends State<DetailPekerjaPage> {
  int _selectedLayanan = 0;

  PekerjaDetail get p => widget.pekerja;

  void _hubungiWa() {
    // TODO: launch whatsapp URL
    // launchUrl(Uri.parse('https://wa.me/${p.noWa}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: kPrimary, size: 20),
          ),
        ),
        title: const Text(
          'Detail Pekerja',
          style: TextStyle(
            color: kPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: kPrimary, size: 20),
              onPressed: () {},
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Scrollable content ──
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero foto
                _HeroFoto(fotoUrl: p.fotoUrl),

                // Info dasar
                _InfoDasar(
                  nama: p.nama,
                  jenisKelamin: p.jenisKelamin,
                  usia: p.usia,
                ),

                const SizedBox(height: 8),

                // Layanan + tarif
                _LayananCard(
                  layananList: p.layananList,
                  selectedIndex: _selectedLayanan,
                  onSelect: (i) => setState(() => _selectedLayanan = i),
                ),

                const SizedBox(height: 8),

                // Tentang
                _TentangCard(tentang: p.tentang),

                const SizedBox(height: 8),

                // Area
                _AreaCard(area: p.area),

                const SizedBox(height: 8),
              ],
            ),
          ),

          // ── WhatsApp button (fixed bottom) ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(color: Colors.white),
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _hubungiWa,
                  icon: const Icon(Icons.chat_outlined, size: 20),
                  label: const Text(
                    'WhatsApp',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// HERO FOTO
// ─────────────────────────────────────────
class _HeroFoto extends StatelessWidget {
  final String? fotoUrl;
  const _HeroFoto({this.fotoUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 260,
      child: fotoUrl != null
          ? Image.network(fotoUrl!, fit: BoxFit.cover)
          : Container(
              color: const Color(0xFFCBD5E1),
              child: const Icon(Icons.person, size: 80, color: Colors.white),
            ),
    );
  }
}

// ─────────────────────────────────────────
// INFO DASAR
// ─────────────────────────────────────────
class _InfoDasar extends StatelessWidget {
  final String nama;
  final String jenisKelamin;
  final int usia;

  const _InfoDasar({
    required this.nama,
    required this.jenisKelamin,
    required this.usia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nama,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$jenisKelamin • $usia Tahun',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// LAYANAN CARD
// ─────────────────────────────────────────
class _LayananCard extends StatelessWidget {
  final List<LayananDetail> layananList;
  final int selectedIndex;
  final void Function(int) onSelect;

  const _LayananCard({
    required this.layananList,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final selected = layananList[selectedIndex];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'LAYANAN YANG DITAWARKAN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: kPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tab layanan
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(layananList.length, (i) {
                final isActive = i == selectedIndex;
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isActive ? kPrimary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      layananList[i].nama,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isActive ? kPrimary : Colors.grey,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Tarif rows
          if (selected.hargaJam != null)
            _TarifRow(
              icon: Icons.access_time,
              label: 'Tarif Per Jam',
              harga: selected.hargaJam!,
              isProyek: false,
            ),
          if (selected.hargaHari != null) ...[
            const SizedBox(height: 12),
            _TarifRow(
              icon: Icons.calendar_today_outlined,
              label: 'Tarif Per Hari',
              harga: selected.hargaHari!,
              isProyek: false,
            ),
          ],
          if (selected.hargaProyek != null) ...[
            const SizedBox(height: 12),
            _TarifRow(
              icon: Icons.build_outlined,
              label: 'Tarif Proyek',
              harga: selected.hargaProyek!,
              isProyek: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _TarifRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String harga;
  final bool isProyek;

  const _TarifRow({
    required this.icon,
    required this.label,
    required this.harga,
    required this.isProyek,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: kPrimary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (isProyek)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mulai dari',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                harga,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
            ],
          )
        else
          Text(
            harga,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// TENTANG CARD
// ─────────────────────────────────────────
class _TentangCard extends StatelessWidget {
  final String tentang;
  const _TentangCard({required this.tentang});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tentang Saya',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            tentang,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// AREA CARD
// ─────────────────────────────────────────
class _AreaCard extends StatelessWidget {
  final String area;
  const _AreaCard({required this.area});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Area Layanan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Map placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 160,
              child: Stack(
                children: [
                  // Background map
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
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
                  // Radius circle
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
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
                  // Pin
                  const Center(
                    child: Icon(Icons.location_on, color: kPrimary, size: 32),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Area label
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: kPrimary),
              const SizedBox(width: 6),
              Text(
                area,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Map Placeholder Painter (reuse dari AreaSection)
// ─────────────────────────────────────────
class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

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
  }

  @override
  bool shouldRepaint(_MapPlaceholderPainter old) => false;
}
