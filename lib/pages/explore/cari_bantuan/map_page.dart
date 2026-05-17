import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/core/helper.dart';
import 'package:piawai/pages/widgets/map_component.dart';
import 'package:piawai/pages/widgets/permission_ui.dart';
import 'package:piawai/services/explore_services.dart';

import 'filter_page.dart';
import 'models/explore_model.dart';
import 'models/worker_model.dart';
import 'profile_page.dart';
import 'search_page.dart';

// ─────────────────────────────────────────
// Map Screen
// ─────────────────────────────────────────
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

enum _LocationState { checking, denied, deniedForever, granted }

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  final MapController _mapController = MapController();
  final _workerService = ExploreService();
  LatLng? _myLocation;
  bool _isLoadingLocation = false;
  _LocationState _locationState = _LocationState.checking;
  WorkerExploreModel? _selectedWorker;

  // ── Filter state ──
  FilterResult? _activeFilter;

  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  ExploreModel? _explore;

  Future<void> _loadAll() async {
    if (_myLocation == null) return;
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final explore = await _workerService.fetchWorkerExplore(
        lat: _myLocation!.latitude,
        lng: _myLocation!.longitude,
        radius: _activeFilter?.radiusKm ?? 5,
        q: _searchQuery.isEmpty ? null : _searchQuery,
        gender: (_activeFilter?.gender == 'Semua')
            ? null
            : _activeFilter?.gender,
        ageMin: _activeFilter?.ageRange.start.round(),
        ageMax: _activeFilter?.ageRange.end.round(),
      );

      if (!mounted) return; // ← add

      setState(() {
        _explore = explore;
        _isLoading = false;
      });

      // ← ganti addPostFrameCallback lama dengan ini
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final radiusM = (_activeFilter?.radiusKm ?? 5) * 1000;
        final radiusDeg = radiusM / 111320;

        final bounds = LatLngBounds.fromPoints([
          LatLng(_myLocation!.latitude + radiusDeg, _myLocation!.longitude),
          LatLng(_myLocation!.latitude - radiusDeg, _myLocation!.longitude),
          LatLng(_myLocation!.latitude, _myLocation!.longitude + radiusDeg),
          LatLng(_myLocation!.latitude, _myLocation!.longitude - radiusDeg),
        ]);

        // _mapController.fitCamera(
        //   CameraFit.bounds(
        //     bounds: bounds,
        //     padding: const EdgeInsets.all(40),
        //     minZoom: 12,
        //   ),
        // );
      });
    } catch (e) {
      if (!mounted) return; // ← add
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ── Active chips: hanya tampil kalau filter aktif ──
  List<_ActiveChipData> get _activeChips {
    if (_activeFilter == null) return [];
    final f = _activeFilter!;
    final chips = <_ActiveChipData>[];

    if (f.gender != 'Semua') {
      chips.add(
        _ActiveChipData(
          icon: Icons.wc,
          label: f.gender,
          onRemove: () async {
            setState(() {
              _activeFilter = FilterResult(
                gender: 'Semua',
                ageRange: f.ageRange,
                location: f.location,
                radiusKm: f.radiusKm,
              );
            });
            await _loadAll();
          },
        ),
      );
    }

    // Umur — tampil kalau bukan default (18–55)
    if (f.ageRange.start != 18 || f.ageRange.end != 55) {
      chips.add(
        _ActiveChipData(
          icon: Icons.cake_outlined,
          label: '${f.ageRange.start.round()}–${f.ageRange.end.round()} thn',
          onRemove: () async {
            setState(() {
              _activeFilter = FilterResult(
                gender: f.gender,
                ageRange: const RangeValues(18, 55),
                location: f.location,
                radiusKm: f.radiusKm,
              );
            });
            await _loadAll();
          },
        ),
      );
    }

    // Radius — tampil kalau bukan default (15 km)
    if (f.radiusKm != 15) {
      chips.add(
        _ActiveChipData(
          icon: Icons.location_on_outlined,
          label: 'Radius: ${f.radiusKm.round()} km',
          onRemove: () async {
            setState(() {
              _activeFilter = FilterResult(
                gender: f.gender,
                ageRange: f.ageRange,
                location: f.location,
                radiusKm: 15,
              );
            });
            await _loadAll();
          },
        ),
      );
    }

    return chips;
  }

  bool get _hasActiveFilter => _activeChips.isNotEmpty;

  // ── Buka filter page ──
  Future<void> _openFilter() async {
    final result = await Navigator.push<FilterResult>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FilterPage(myLocation: _myLocation, initialFilter: _activeFilter),
        fullscreenDialog: true,
      ),
    );
    if (result != null && mounted) {
      setState(() => _activeFilter = result);
      await _loadAll();
    }
  }

  Future<void> _openSearch() async {
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => SearchPage(
          initialQuery: _searchQuery,
          onSearch: (query) async {
            setState(() {
              _searchQuery = query;
            });
            await _loadAll();
          },
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final permission = await Geolocator.checkPermission();
    if (!mounted) return; // ← add (after await)
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
    if (!mounted) return; // ← add (after await)
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      setState(() => _locationState = _LocationState.granted);
      _getCurrentLocation();
    } else if (permission == LocationPermission.deniedForever) {
      setState(() => _locationState = _LocationState.deniedForever);
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return; // ← add
    setState(() => _isLoadingLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return; // ← add (after await)
      setState(() {
        _myLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      await _loadAll();
    } catch (e) {
      if (!mounted) return; // ← add
      setState(() => _isLoadingLocation = false);
    }
  }

  double _zoomFromRadius(double radiusKm) {
    return 14 - (log(radiusKm) / log(2));
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_locationState == _LocationState.checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_locationState == _LocationState.denied ||
        _locationState == _LocationState.deniedForever) {
      return PermissionUI(
        isDeniedForever: _locationState == _LocationState.deniedForever,
        onRequest: _requestPermission,
      );
    }

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

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ── Error ──
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadAll, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFDEEAF7),
      body: Stack(
        children: [
          // ── Map ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _myLocation!,
              initialZoom: _zoomFromRadius(_activeFilter?.radiusKm ?? 5),
              onTap: (_, __) => setState(() => _selectedWorker = null),
            ),
            children: [
              buildTileLayer(),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _myLocation!,
                    radius: (_activeFilter?.radiusKm ?? 5) * 1000, // km → meter
                    useRadiusInMeter: true, // ← wajib ini
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
                  ...(_explore?.workers ?? []).map(
                    (worker) => Marker(
                      point: LatLng(
                        double.parse(worker.lat ?? '0'),
                        double.parse(worker.lng ?? '0'),
                      ),
                      width: 70,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedWorker = worker);
                          _mapController.move(
                            LatLng(
                              double.parse(worker.lat ?? '0'),
                              double.parse(worker.lng ?? '0'),
                            ),
                            15.5,
                          );
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 65),

                    // Search bar + tombol filter
                    Row(
                      children: [
                        Expanded(
                          child: _SearchBar(
                            query: _searchQuery,
                            onTap: _openSearch,
                            onClear: () async {
                              // ← tambah ini
                              setState(() {
                                _searchQuery = '';
                              });
                              await _loadAll();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol filter — badge merah kalau ada filter aktif
                        _FilterButton(
                          hasActiveFilter: _hasActiveFilter,
                          onTap: _openFilter,
                        ),
                      ],
                    ),

                    // ── Active filter chips (hanya muncul kalau ada filter) ──
                    if (_activeChips.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ..._activeChips.map(
                              (chip) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _ActiveFilterChip(data: chip),
                              ),
                            ),
                            // Tombol clear all
                            GestureDetector(
                              onTap: () async {
                                setState(() => _activeFilter = null);
                                await _loadAll();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Text(
                                  'Hapus semua',
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  '${_explore?.total ?? 0} pekerja ditemukan',
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
// Helper model untuk chip aktif
// ─────────────────────────────────────────
class _ActiveChipData {
  final IconData icon;
  final String label;
  final VoidCallback onRemove;

  const _ActiveChipData({
    required this.icon,
    required this.label,
    required this.onRemove,
  });
}

// ─────────────────────────────────────────
// Tombol Filter (dengan badge kalau aktif)
// ─────────────────────────────────────────
class _FilterButton extends StatelessWidget {
  final bool hasActiveFilter;
  final VoidCallback onTap;

  const _FilterButton({required this.hasActiveFilter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: hasActiveFilter ? kPrimary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.tune_rounded,
              color: hasActiveFilter ? Colors.white : Colors.black87,
              size: 22,
            ),
          ),
          // Badge merah kalau ada filter aktif
          if (hasActiveFilter)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Chip filter aktif (dengan tombol X)
// ─────────────────────────────────────────
class _ActiveFilterChip extends StatelessWidget {
  final _ActiveChipData data;

  const _ActiveFilterChip({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 13, color: kPrimary),
          const SizedBox(width: 5),
          Text(
            data.label,
            style: TextStyle(
              color: Colors.grey[900],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: data.onRemove,
            child: const Icon(Icons.close, size: 14, color: kPrimary),
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
  final String query;
  final VoidCallback onTap;
  final VoidCallback? onClear; // ← tambah ini

  const _SearchBar({required this.query, required this.onTap, this.onClear});

  @override
  Widget build(BuildContext context) {
    final hasQuery = query.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.search, color: Colors.black45, size: 20),
            ),
            Expanded(
              child: Text(
                hasQuery ? query : 'Cari Pekerja...',
                style: TextStyle(
                  color: hasQuery ? Colors.black87 : Colors.grey[500],
                  fontSize: 15,
                  fontWeight: hasQuery ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Icon close — tap terpisah dari onTap parent
            if (hasQuery)
              GestureDetector(
                onTap: onClear, // ← tidak bubble ke parent GestureDetector
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 13,
                      color: Colors.black54,
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

// ─────────────────────────────────────────
// Worker Photo Marker
// ─────────────────────────────────────────
class _WorkerPhotoMarker extends StatelessWidget {
  final WorkerExploreModel worker;
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
            child: worker.avatarUrl != null
                ? Image.network(
                    imageUrl(worker.avatarUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        "👨",
                        style: TextStyle(fontSize: isSelected ? 22 : 18),
                      ),
                    ),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: Text(
                          "👨",
                          style: TextStyle(fontSize: isSelected ? 22 : 18),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "👨",
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
  final WorkerExploreModel worker;
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
                    child: worker.avatarUrl != null
                        ? Image.network(
                            imageUrl(worker.avatarUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                "👨",
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              "👨",
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
                        worker.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        worker.services.join(', '),
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
                            '${worker.distanceKm.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${worker.age} thn',
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
