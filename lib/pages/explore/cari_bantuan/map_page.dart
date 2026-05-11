import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Worker {
  final String name;
  final String job;
  final String phone;
  final String experience;
  final double rating;
  final LatLng position;
  final Color color;
  final String avatar;
  final String price;

  const Worker({
    required this.name,
    required this.job,
    required this.phone,
    required this.experience,
    required this.rating,
    required this.position,
    required this.color,
    required this.avatar,
    required this.price,
  });
}

// ─────────────────────────────────────────
// Static Data
// ─────────────────────────────────────────
final List<Worker> allWorkers = [
  Worker(
    name: 'Budi Santoso',
    job: 'Tukang Cuci',
    phone: '0812-3456-7890',
    experience: '3 tahun',
    rating: 4.8,
    position: const LatLng(-2.9720, 104.7700),
    color: const Color(0xFF1976D2),
    avatar: '👨',
    price: 'Rp 50.000/hari',
  ),
  Worker(
    name: 'Sari Dewi',
    job: 'Tukang Cuci',
    phone: '0813-2345-6789',
    experience: '5 tahun',
    rating: 4.9,
    position: const LatLng(-2.9800, 104.7780),
    color: const Color(0xFF1976D2),
    avatar: '👩',
    price: 'Rp 60.000/hari',
  ),
  Worker(
    name: 'Ahmad Rizki',
    job: 'Tukang Listrik',
    phone: '0814-3456-7891',
    experience: '7 tahun',
    rating: 4.7,
    position: const LatLng(-2.9680, 104.7820),
    color: const Color(0xFFFF9800),
    avatar: '👷',
    price: 'Rp 150.000/hari',
  ),
  Worker(
    name: 'Rina Kusuma',
    job: 'Tukang Masak',
    phone: '0815-4567-8902',
    experience: '4 tahun',
    rating: 4.6,
    position: const LatLng(-2.9850, 104.7650),
    color: const Color(0xFFE91E63),
    avatar: '👩‍🍳',
    price: 'Rp 80.000/hari',
  ),
  Worker(
    name: 'Dimas Arya',
    job: 'Tukang Bangunan',
    phone: '0816-5678-9013',
    experience: '10 tahun',
    rating: 4.5,
    position: const LatLng(-2.9760, 104.7830),
    color: const Color(0xFF795548),
    avatar: '👷‍♂️',
    price: 'Rp 120.000/hari',
  ),
  Worker(
    name: 'Lina Marlina',
    job: 'Tukang Cuci',
    phone: '0817-6789-0124',
    experience: '2 tahun',
    rating: 4.4,
    position: const LatLng(-2.9700, 104.7760),
    color: const Color(0xFF1976D2),
    avatar: '👩',
    price: 'Rp 45.000/hari',
  ),
  Worker(
    name: 'Hendra Wijaya',
    job: 'Tukang Listrik',
    phone: '0818-7890-1235',
    experience: '6 tahun',
    rating: 4.8,
    position: const LatLng(-2.9820, 104.7710),
    color: const Color(0xFFFF9800),
    avatar: '👨‍🔧',
    price: 'Rp 140.000/hari',
  ),
  Worker(
    name: 'Putri Amelia',
    job: 'Tukang Masak',
    phone: '0819-8901-2346',
    experience: '3 tahun',
    rating: 4.7,
    position: const LatLng(-2.9740, 104.7690),
    color: const Color(0xFFE91E63),
    avatar: '👩‍🍳',
    price: 'Rp 90.000/hari',
  ),
];

const List<String> jobCategories = [
  'Semua',
  'Tukang Cuci',
  'Tukang Listrik',
  'Tukang Masak',
  'Tukang Bangunan',
];

// ─────────────────────────────────────────
// Map Screen
// ─────────────────────────────────────────
class MapPage extends StatefulWidget {
  const MapPage({super.key});
  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();
  static const LatLng _myLocation = LatLng(-2.9761, 104.7754);

  String _selectedCategory = 'Semua';
  Worker? _selectedWorker;

  List<Worker> get _filteredWorkers => _selectedCategory == 'Semua'
      ? allWorkers
      : allWorkers.where((w) => w.job == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Peta ──────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _myLocation,
              initialZoom: 14.5,
              onTap: (_, __) => setState(() => _selectedWorker = null),
            ),
            children: [
              // Tile terang mirip Google Maps
              TileLayer(
                urlTemplate:
                    'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                userAgentPackageName: 'com.example.cari_pekerja',
              ),
              // Radius circle
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _myLocation,
                    radius: 110,
                    color: const Color(0xFF1976D2).withAlpha(25),
                    borderColor: const Color(0xFF1976D2).withAlpha(120),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
              // Markers
              MarkerLayer(
                markers: [
                  // Lokasi saya
                  Marker(
                    point: _myLocation,
                    width: 56,
                    height: 56,
                    child: _MyLocationDot(),
                  ),
                  // Worker markers
                  ..._filteredWorkers.map(
                    (worker) => Marker(
                      point: worker.position,
                      width: 60,
                      height: 70,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedWorker = worker);
                          _mapController.move(worker.position, 15.5);
                        },
                        child: _WorkerMarker(
                          worker: worker,
                          isSelected: _selectedWorker == worker,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Search + Filter Bar ───────────
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Search bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Cari pekerjaan... (contoh: tukang cuci)',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF1976D2),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) {
                          final match = jobCategories.firstWhere(
                            (cat) =>
                                cat.toLowerCase().contains(val.toLowerCase()),
                            orElse: () => 'Semua',
                          );
                          setState(() => _selectedCategory = match);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Category chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: jobCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final cat = jobCategories[i];
                          final isActive = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF1976D2)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(20),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.black87,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Card (worker dipilih) ──
          if (_selectedWorker != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _WorkerCard(
                worker: _selectedWorker!,
                onClose: () => setState(() => _selectedWorker = null),
                onDetail: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(worker: _selectedWorker!),
                  ),
                ),
              ),
            ),

          // ── Counter badge ─────────────────
          Positioned(
            bottom: 24,
            right: 16,
            child: _selectedWorker == null
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1976D2).withAlpha(100),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      '${_filteredWorkers.length} pekerja ditemukan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widget: Titik lokasi saya
// ─────────────────────────────────────────
class _MyLocationDot extends StatefulWidget {
  @override
  State<_MyLocationDot> createState() => _MyLocationDotState();
}

class _MyLocationDotState extends State<_MyLocationDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.8,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: _anim.value,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1976D2).withAlpha(40),
                border: Border.all(
                  color: const Color(0xFF1976D2).withAlpha(100),
                  width: 1,
                ),
              ),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF1976D2),
              boxShadow: [
                BoxShadow(
                  color: Color(0x881976D2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Widget: Marker pekerja di peta
// ─────────────────────────────────────────
class _WorkerMarker extends StatelessWidget {
  final Worker worker;
  final bool isSelected;
  const _WorkerMarker({required this.worker, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 52.0 : 42.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: worker.color, width: isSelected ? 3 : 2),
            boxShadow: [
              BoxShadow(
                color: worker.color.withAlpha(isSelected ? 160 : 80),
                blurRadius: isSelected ? 16 : 8,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: Center(
            child: Text(
              worker.avatar,
              style: TextStyle(fontSize: isSelected ? 24 : 20),
            ),
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _TrianglePainter(color: worker.color),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = ui.Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────
// Widget: Card preview bawah peta
// ─────────────────────────────────────────
class _WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback onClose;
  final VoidCallback onDetail;

  const _WorkerCard({
    required this.worker,
    required this.onClose,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: worker.color.withAlpha(30),
              border: Border.all(color: worker.color, width: 2),
            ),
            child: Center(
              child: Text(worker.avatar, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  worker.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  worker.job,
                  style: TextStyle(
                    color: worker.color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      '${worker.rating}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.work_outline,
                      size: 13,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      worker.experience,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Buttons
          Column(
            children: [
              GestureDetector(
                onTap: onDetail,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: worker.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Lihat',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, color: Colors.grey, size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Halaman Profil Pekerja
// ─────────────────────────────────────────
class ProfilePage extends StatelessWidget {
  final Worker worker;
  const ProfilePage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: worker.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: worker.color.withAlpha(230),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(
                        child: Text(
                          worker.avatar,
                          style: const TextStyle(fontSize: 44),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      worker.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      worker.job,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats row
                  Row(
                    children: [
                      _StatCard(
                        icon: Icons.star,
                        color: Colors.amber,
                        label: 'Rating',
                        value: '${worker.rating}',
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.work,
                        color: worker.color,
                        label: 'Pengalaman',
                        value: worker.experience,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.payments,
                        color: Colors.green,
                        label: 'Tarif',
                        value: worker.price,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info card
                  _InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Kontak',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _InfoRow(
                          icon: Icons.phone,
                          color: Colors.green,
                          text: worker.phone,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          icon: Icons.location_on,
                          color: Colors.red,
                          text: 'Palembang, Sumatera Selatan',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tombol aksi
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Hubungi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: worker.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: worker.color,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: worker.color),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6),
        ],
      ),
      child: child,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class CobaPage extends StatefulWidget {
  const CobaPage({super.key});

  @override
  State<CobaPage> createState() => _CobaPageState();
}

class _CobaPageState extends State<CobaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(child: Text('Coba')),
    );
  }
}
