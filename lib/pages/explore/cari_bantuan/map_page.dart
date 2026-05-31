import 'dart:math';
import 'dart:ui' as ui;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/core/helper.dart';
import 'package:piawai/pages/widgets/loading_detect_location.dart';
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
  LatLng? _gpsLocation;
  bool _isLoadingLocation = false;
  _LocationState _locationState = _LocationState.checking;
  WorkerExploreModel? _selectedWorker;

  // ── Filter state ──
  FilterResult? _activeFilter;
  bool _showList = false;

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
    if (f.radiusKm != 5) {
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

    // Lokasi custom — tampil kalau bukan GPS location
    if (f.locationLatLng != null &&
        _gpsLocation != null &&
        f.locationLatLng != _gpsLocation) {
      chips.add(
        _ActiveChipData(
          icon: Icons.location_on_outlined,
          label: f.location,
          onRemove: () async {
            setState(() {
              _myLocation = _gpsLocation; // ← balik ke GPS
              _activeFilter = FilterResult(
                gender: f.gender,
                ageRange: f.ageRange,
                location: 'my_location'.tr(),
                radiusKm: f.radiusKm,
                locationLatLng: _gpsLocation,
              );
            });
            await _loadAll();
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _gpsLocation == null) return;
              _mapController.move(
                _gpsLocation!,
                _zoomFromRadius(_activeFilter?.radiusKm ?? 5),
              );
            });
          },
        ),
      );
    }

    return chips;
  }

  bool get _hasActiveFilter => _activeChips.isNotEmpty;

  Future<void> _openFilter() async {
    if (_myLocation != null) {
      final result = await Navigator.push<FilterResult>(
        context,
        MaterialPageRoute(
          builder: (_) => FilterPage(
            myLocation: _myLocation!,
            initialFilter: _activeFilter,
          ),
          fullscreenDialog: true,
        ),
      );
      if (result != null && mounted) {
        setState(() {
          _activeFilter = result;
          // ← update myLocation kalau user pilih lokasi custom
          if (result.locationLatLng != null) {
            _myLocation = result.locationLatLng;
          }
        });
        await _loadAll();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _myLocation == null) return;
          _mapController.move(
            _myLocation!,
            _zoomFromRadius(_activeFilter?.radiusKm ?? 5),
          );
        });
      }
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
        _gpsLocation = _myLocation;
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
      return Scaffold(body: Center(child: loadingCurrentLocation(context)));
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
            Icon(Icons.error_outline, size: 40),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: TextStyle(color: context.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadAll, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.bgOuter,
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
              buildTileLayer(context),
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: _myLocation!,
                    radius: (_activeFilter?.radiusKm ?? 5) * 1000, // km → meter
                    useRadiusInMeter: true, // ← wajib ini
                    color: context.primary.withOpacity(0.1),
                    borderColor: context.primary.withOpacity(0.4),
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
                      point: LatLng(worker.lat ?? 0, worker.lng ?? 0),
                      width: 70,
                      height: 80,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedWorker = worker);
                          _mapController.move(
                            LatLng(worker.lat ?? 0, worker.lng ?? 0),
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
                                setState(() {
                                  _activeFilter = null;
                                  _myLocation =
                                      _gpsLocation ??
                                      _myLocation; // ← balik ke GPS
                                });
                                await _loadAll();
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  if (!mounted || _myLocation == null) return;
                                  _mapController.move(
                                    _myLocation!,
                                    _zoomFromRadius(5),
                                  );
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: context.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: context.red),
                                ),
                                child: Text(
                                  'Hapus semua',
                                  style: TextStyle(
                                    color: context.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 10,
                          right: 6,
                          top: 6,
                          bottom: 6,
                        ),
                        decoration: BoxDecoration(
                          color: context.bgContent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.primary.withOpacity(0.3),
                          ),
                        ),

                        child: Text(
                          'Default ${'general.radius'.tr()} - ${'general.radius_display'.tr(args: ['${_activeFilter?.radiusKm.round() ?? 5}'])}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.primary,
                          ),
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
              child: GestureDetector(
                onTap: () => setState(() => _showList = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: context.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'cari_bantuan.worker_found'.tr(
                          args: ['${_explore?.total ?? 0}'],
                        ),
                        style: TextStyle(
                          color: context.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.list_rounded, color: context.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),

          if (_showList)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _showList = false),
                child: Container(color: Colors.black.withOpacity(0.3)),
              ),
            ),
          if (_showList)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _WorkerListSheet(
                workers: _explore?.workers ?? [],
                onClose: () => setState(() => _showList = false),
                onTap: (worker) {
                  setState(() {
                    _showList = false;
                    _selectedWorker = worker;
                  });
                  _mapController.move(
                    LatLng(worker.lat ?? 0, worker.lng ?? 0),
                    15.5,
                  );
                },
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
              color: hasActiveFilter ? context.primary : context.bgContent,
              border: Border.all(color: context.divider),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: context.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.tune_rounded,
              color: hasActiveFilter ? context.white : context.primary,
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
                decoration: BoxDecoration(
                  color: context.red,
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
        color: context.bgContent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 13, color: context.primary),
          const SizedBox(width: 5),
          Text(
            data.label,
            style: TextStyle(
              color: context.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: data.onRemove,
            child: Icon(Icons.close, size: 14, color: context.primary),
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
          color: context.bgContent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.divider),
          boxShadow: [
            BoxShadow(
              color: context.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.search, color: context.primary, size: 20),
            ),
            Expanded(
              child: Text(
                hasQuery ? query : 'cari_bantuan.search_worker_hint'.tr(),
                style: TextStyle(
                  color: context.black38,
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
                    decoration: BoxDecoration(
                      color: context.divider,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 13, color: context.black54),
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
            color: context.bgContent,
            border: Border.all(color: context.primary, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: context.primary.withAlpha(isSelected ? 150 : 70),
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
          painter: _TrianglePainter(color: context.primary),
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
                color: context.primary.withAlpha(40),
                border: Border.all(
                  color: context.primary.withAlpha(100),
                  width: 1,
                ),
              ),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.primary,
              boxShadow: [
                BoxShadow(
                  color: context.primary.withAlpha(136),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(Icons.person, size: 13),
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
      decoration: BoxDecoration(
        color: context.bgCard,
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
                color: context.grey,
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
                    border: Border.all(
                      color: context.primary.withAlpha(60),
                      width: 2,
                    ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: context.black87,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        worker.services.join(', '),
                        style: TextStyle(color: context.black54, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 15),
                          const SizedBox(width: 3),
                          Text(
                            'general.radius_display'.tr(
                              args: ['${worker.distanceKm}'],
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'general.age_display'.tr(args: ['${worker.age}']),
                            style: TextStyle(
                              fontSize: 12,
                              color: context.primary,
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
                  child: Icon(Icons.close, color: context.grey, size: 22),
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
                  backgroundColor: context.primary,
                  foregroundColor: context.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'look_profil'.tr(),
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

class _WorkerListSheet extends StatelessWidget {
  final List<WorkerExploreModel> workers;
  final VoidCallback onClose;
  final ValueChanged<WorkerExploreModel> onTap;

  const _WorkerListSheet({
    required this.workers,
    required this.onClose,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x22000000),
            blurRadius: 20,
            offset: const Offset(0, -4),
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
                color: context.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${workers.length} Worker ditemukan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: context.black87,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, color: context.grey, size: 22),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List
          Flexible(
            child: ListView.separated(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 8,
              ),
              itemCount: workers.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final worker = workers[i];
                return ListTile(
                  onTap: () => onTap(worker),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.primary.withAlpha(60),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: worker.avatarUrl != null
                          ? Image.network(
                              imageUrl(worker.avatarUrl!),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Text(
                                  '👨',
                                  style: TextStyle(fontSize: 22),
                                ),
                              ),
                            )
                          : const Center(
                              child: Text('👨', style: TextStyle(fontSize: 22)),
                            ),
                    ),
                  ),
                  title: Text(
                    worker.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    worker.services.join(', '),
                    style: TextStyle(color: context.black54, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${worker.distanceKm} km',
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        worker.gender == 'Wanita' ? Icons.female : Icons.male,
                        color: worker.gender == 'Wanita'
                            ? const Color(0xFFFF4081)
                            : const Color(0xFFFFC107),
                        size: 16,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
