import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/widgets/map_component.dart';

class AturLokasiPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const AturLokasiPage({super.key, this.initialLat, this.initialLng});

  @override
  State<AturLokasiPage> createState() => _AturLokasiPageState();
}

class _AturLokasiPageState extends State<AturLokasiPage> {
  final MapController _mapController = MapController();

  LatLng _pinPosition = const LatLng(-2.9761, 104.7754); // default Palembang
  bool _isLoadingLocation = false;
  bool _isConfirming = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _pinPosition = LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      _getCurrentLocation();
    }
  }

  // ── Ambil GPS current location ─────────────────────────────────────────
  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _pinPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      _mapController.move(_pinPosition, 14);
    } catch (e) {
      setState(() => _isLoadingLocation = false);
    }
  }

  // ── Confirm lokasi → balik ke AreaSection ─────────────────────────────
  void _confirmLocation() {
    Navigator.pop(context, {
      'lat': _pinPosition.latitude,
      'lng': _pinPosition.longitude,
      'area_label': _buildAreaLabel(_pinPosition),
    });
  }

  // ── Build area label dari koordinat (simple) ──────────────────────────
  String _buildAreaLabel(LatLng pos) {
    // Nanti bisa diganti reverse geocoding
    return '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Full screen map ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _pinPosition,
              initialZoom: 14,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && position.center != null) {
                  setState(() {
                    _pinPosition = position.center!;
                  });
                }
              },
            ),
            children: [buildTileLayer()],
          ),

          // ── Center pin (tidak ikut move, selalu tengah) ──
          const Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_pin, color: kPrimary, size: 48),
                    SizedBox(height: 24), // offset biar ujung pin pas di tengah
                  ],
                ),
              ),
            ),
          ),

          // ── Top bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.arrow_back, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Geser peta untuk atur lokasi',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── GPS button ──
          Positioned(
            bottom: 120,
            right: 16,
            child: GestureDetector(
              onTap: _getCurrentLocation,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _isLoadingLocation
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimary,
                        ),
                      )
                    : const Icon(Icons.my_location, color: kPrimary, size: 22),
              ),
            ),
          ),

          // ── Bottom confirm panel ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Koordinat preview
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: kPrimary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${_pinPosition.latitude.toStringAsFixed(5)}, '
                        '${_pinPosition.longitude.toStringAsFixed(5)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Titik ini akan jadi pusat area layanan Anda',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isConfirming ? null : _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Konfirmasi Lokasi',
                        style: TextStyle(
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
        ],
      ),
    );
  }
}
