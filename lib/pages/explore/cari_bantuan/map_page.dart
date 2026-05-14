import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/widgets/map_component.dart';

// ─────────────────────────────────────────
// Model
// ─────────────────────────────────────────
class Worker {
  final String name;
  final String job;
  final String phone;
  final String experience;
  final double rating;
  final LatLng position;
  final Color color;
  final String avatar; // emoji fallback
  final String? photoUrl; // network photo (optional)
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
    this.photoUrl,
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
    color: const Color(0xFF1565C0),
    avatar: '👨',
    photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    price: 'Rp 50.000/hari',
  ),
  Worker(
    name: 'Sari Dewi',
    job: 'Tukang Cuci',
    phone: '0813-2345-6789',
    experience: '5 tahun',
    rating: 4.9,
    position: const LatLng(-2.9800, 104.7780),
    color: const Color(0xFF1565C0),
    avatar: '👩',
    photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
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
    photoUrl: 'https://randomuser.me/api/portraits/men/55.jpg',
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
    photoUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
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
    photoUrl: 'https://randomuser.me/api/portraits/men/71.jpg',
    price: 'Rp 120.000/hari',
  ),
  Worker(
    name: 'Audi Setiawan',
    job: 'Tukang Ledeng & Pompa Air',
    phone: '0817-6789-0124',
    experience: '2 tahun',
    rating: 4.4,
    position: const LatLng(-2.9700, 104.7760),
    color: const Color(0xFF1565C0),
    avatar: '👨‍🔧',
    photoUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
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
    photoUrl: 'https://randomuser.me/api/portraits/men/11.jpg',
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
    photoUrl: 'https://randomuser.me/api/portraits/women/12.jpg',
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
// App Entry (wrap in MaterialApp)
// ─────────────────────────────────────────
class CariPekerjaApp extends StatelessWidget {
  const CariPekerjaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        fontFamily: 'Roboto',
      ),
      home: const MainShell(),
    );
  }
}

// ─────────────────────────────────────────
// Main Shell with bottom nav
// ─────────────────────────────────────────
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [MapPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(18),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.explore_outlined,
                  iconActive: Icons.explore,
                  label: 'Eksplor',
                  isActive: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  iconActive: Icons.settings,
                  label: 'Pengaturan',
                  isActive: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconActive;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconActive,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? iconActive : icon,
              color: isActive ? kPrimary : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? kPrimary : Colors.grey,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) => const Center(child: Text('Pengaturan'));
}

// ─────────────────────────────────────────
// Map Screen
// ─────────────────────────────────────────
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

enum _LocationState { checking, denied, deniedForever, granted }

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  LatLng? _myLocation; // nullable, gak ada default
  bool _isLoadingLocation = false;
  _LocationState _locationState = _LocationState.checking;
  Worker? _selectedWorker; // ← tambah ini
  String _selectedCategory = 'Semua'; // ← tambah ini

  List<Worker> get _filteredWorkers => _selectedCategory == 'Semua'
      ? allWorkers
      : allWorkers.where((w) => w.job == _selectedCategory).toList();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      setState(() => _locationState = _LocationState.deniedForever);
    } else if (permission == LocationPermission.denied) {
      setState(() => _locationState = _LocationState.denied);
    } else {
      setState(() => _locationState = _LocationState.granted);
      _getCurrentLocation();
    }
  }

  Future<void> _requestPermission() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() => _locationState = _LocationState.granted);
      _getCurrentLocation();
    } else if (permission == LocationPermission.deniedForever) {
      setState(() => _locationState = _LocationState.deniedForever);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(_myLocation!, 14.5);
        }
      });
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Checking permission ──
    if (_locationState == _LocationState.checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ── Permission belum dikasih ──
    if (_locationState == _LocationState.denied ||
        _locationState == _LocationState.deniedForever) {
      return _PermissionUI(
        isDeniedForever: _locationState == _LocationState.deniedForever,
        onRequest: _requestPermission,
      );
    }

    // ── Loading GPS ──
    if (_isLoadingLocation || _myLocation == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: kPrimary),
              SizedBox(height: 16),
              Text(
                'Mendeteksi lokasi Anda...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // ── Map ──
    return Scaffold(
      backgroundColor: const Color(0xFFDEEAF7),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _myLocation!,
              initialZoom: 14.5,
              onTap: (_, __) => setState(() => _selectedWorker = null),
            ),
            children: [
              buildTileLayer(),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _myLocation!,
                    radius: 110,
                    color: kPrimary.withOpacity(0.1),
                    borderColor: kPrimary.withOpacity(0.4),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _myLocation!,
                    width: 56,
                    height: 56,
                    child: const _MyLocationDot(),
                  ),
                  ..._filteredWorkers.map(
                    (worker) => Marker(
                      point: worker.position,
                      width: 70,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedWorker = worker);
                          _mapController.move(worker.position, 15.5);
                        },
                        child: _WorkerPhotoMarker(
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

          // ── Top overlay ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 65),
                    _SearchBar(
                      onChanged: (val) {
                        final match = jobCategories.firstWhere(
                          (cat) =>
                              cat.toLowerCase().contains(val.toLowerCase()),
                          orElse: () => 'Semua',
                        );
                        setState(() => _selectedCategory = match);
                      },
                    ),
                    const SizedBox(height: 15),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _LocationChip(
                            icon: Icons.location_on_outlined,
                            label: 'Radius: 5 km',
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _LocationChip(
                            icon: Icons.male,
                            label: 'Umur',
                            onTap: () {},
                          ),
                          const SizedBox(width: 8),
                          _LocationChip(
                            icon: Icons.male,
                            label: 'Gender',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Sheet worker ──
          if (_selectedWorker != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _WorkerBottomSheet(
                worker: _selectedWorker!,
                onClose: () => setState(() => _selectedWorker = null),
                onViewProfile: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(worker: _selectedWorker!),
                  ),
                ),
              ),
            ),

          // ── Worker count badge ──
          if (_selectedWorker == null)
            Positioned(
              bottom: 24,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_filteredWorkers.length} pekerja ditemukan',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
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
// Search Bar
// ─────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGrey, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Icon(Icons.search, color: Colors.grey[700], size: 22),
                ),
                Expanded(
                  child: TextField(
                    onChanged: onChanged,
                    decoration: InputDecoration(
                      hintText: 'Cari Pekerja...',
                      hintStyle: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 15,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 10),
        // Filter icon button
        Container(
          width: 60,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kGrey, width: 1),
          ),
          child: Icon(Icons.tune, color: Colors.grey[800], size: 20),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Location Chip
// ─────────────────────────────────────────
class _LocationChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LocationChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kGrey, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: kPrimary, size: 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Worker Photo Marker
// ─────────────────────────────────────────
class _WorkerPhotoMarker extends StatelessWidget {
  final Worker worker;
  final bool isSelected;

  const _WorkerPhotoMarker({required this.worker, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final size = isSelected ? 58.0 : 48.0;
    final borderWidth = isSelected ? 3.0 : 2.5;

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
            border: Border.all(color: kPrimary, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: kPrimary.withAlpha(isSelected ? 150 : 70),
                blurRadius: isSelected ? 18 : 8,
                spreadRadius: isSelected ? 2 : 0,
              ),
            ],
          ),
          child: ClipOval(
            child: worker.photoUrl != null
                ? Image.network(
                    worker.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        worker.avatar,
                        style: TextStyle(fontSize: isSelected ? 22 : 18),
                      ),
                    ),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Text(
                          worker.avatar,
                          style: TextStyle(fontSize: isSelected ? 22 : 18),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      worker.avatar,
                      style: TextStyle(fontSize: isSelected ? 22 : 18),
                    ),
                  ),
          ),
        ),
        // Teardrop point
        CustomPaint(
          size: const Size(12, 7),
          painter: _TrianglePainter(color: kPrimary),
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
// My Location Dot
// ─────────────────────────────────────────
class _MyLocationDot extends StatefulWidget {
  const _MyLocationDot();

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
                color: kPrimary.withAlpha(40),
                border: Border.all(color: kPrimary.withAlpha(100), width: 1),
              ),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimary,
              boxShadow: [
                BoxShadow(
                  color: Color(0x881565C0),
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
// Bottom Sheet
// ─────────────────────────────────────────
class _WorkerBottomSheet extends StatelessWidget {
  final Worker worker;
  final VoidCallback onClose;
  final VoidCallback onViewProfile;

  const _WorkerBottomSheet({
    required this.worker,
    required this.onClose,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Photo
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kPrimary.withAlpha(60), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: worker.photoUrl != null
                        ? Image.network(
                            worker.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                worker.avatar,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              worker.avatar,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        worker.job,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 15),
                          const SizedBox(width: 3),
                          Text(
                            '${worker.rating}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            worker.price,
                            style: const TextStyle(
                              fontSize: 12,
                              color: kPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Close
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, color: Colors.grey[400], size: 22),
                ),
              ],
            ),
          ),

          // "Lihat Profil" button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onViewProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Lihat Profil',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Profile Page (unchanged structure, updated styling)
// ─────────────────────────────────────────
class ProfilePage extends StatelessWidget {
  final Worker worker;
  const ProfilePage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil Pekerja',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPrimary, width: 3),
              ),
              child: ClipOval(
                child: worker.photoUrl != null
                    ? Image.network(
                        worker.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            worker.avatar,
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          worker.avatar,
                          style: const TextStyle(fontSize: 40),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              worker.name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              worker.job,
              style: const TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${worker.rating}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _InfoCard(worker: worker),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.phone_outlined),
                label: Text(
                  'Hubungi ${worker.name.split(' ').first}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Worker worker;
  const _InfoCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Nomor HP',
            value: worker.phone,
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.work_outline,
            label: 'Pengalaman',
            value: worker.experience,
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Harga',
            value: worker.price,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kPrimary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PermissionUI extends StatelessWidget {
  final bool isDeniedForever;
  final VoidCallback onRequest;

  const _PermissionUI({required this.isDeniedForever, required this.onRequest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  size: 64,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Izin Lokasi Diperlukan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                isDeniedForever
                    ? 'Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.'
                    : 'Aplikasi butuh akses lokasi untuk menampilkan pekerja di sekitar Anda.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isDeniedForever
                      ? () => Geolocator.openAppSettings()
                      : onRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isDeniedForever
                        ? 'Buka Pengaturan'
                        : 'Izinkan Akses Lokasi',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
