import 'dart:convert';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/pages/widgets/map_component.dart';

class AturLokasiPage extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final double radius;

  const AturLokasiPage({
    super.key,
    this.initialLat,
    this.initialLng,
    required this.radius,
  });

  @override
  State<AturLokasiPage> createState() => _AturLokasiPageState();
}

class _AturLokasiPageState extends State<AturLokasiPage> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  LatLng _pinPosition = const LatLng(-2.9761, 104.7754);
  bool _isLoadingLocation = false;
  bool _isSearching = false;
  bool _showSuggestions = false;
  List<Map<String, dynamic>> _searchResults = [];
  String _locationLabel = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _pinPosition = LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      _getCurrentLocation();
    }

    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── GPS ────────────────────────────────────────────────────────────────
  Future<void> _getCurrentLocation() async {
    if (!mounted) return; // ← tambah ini
    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return; // ← tambah ini
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return; // ← tambah ini — paling penting, setelah await
      setState(() {
        _pinPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
        _locationLabel = '';
        _searchController.clear();
      });
      _mapController.move(_pinPosition, 14);
    } catch (e) {
      if (!mounted) return; // ← tambah ini
      setState(() => _isLoadingLocation = false);
    }
  }

  // ── Nominatim search ───────────────────────────────────────────────────
  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json&limit=5&addressdetails=1',
      );

      final response = await http
          .get(uri, headers: {'User-Agent': 'PiawaiApp/1.0'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _searchResults = data.map((e) => e as Map<String, dynamic>).toList();
          _showSuggestions = true;
          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
      }
    } catch (_) {
      setState(() => _isSearching = false);
    }
  }

  String _formatLabel(Map<String, dynamic> place) {
    final address = place['address'] as Map<String, dynamic>? ?? {};
    final parts = <String>[];
    for (final key in [
      'village',
      'suburb',
      'city_district',
      'city',
      'county',
      'state',
    ]) {
      final val = address[key] as String?;
      if (val != null && val.isNotEmpty && !parts.contains(val)) {
        parts.add(val);
        if (parts.length >= 3) break;
      }
    }
    return parts.isNotEmpty
        ? parts.join(', ')
        : place['display_name'] as String;
  }

  void _selectPlace(Map<String, dynamic> place) {
    final label = _formatLabel(place);
    final lat = double.parse(place['lat'] as String);
    final lng = double.parse(place['lon'] as String);
    final pos = LatLng(lat, lng);

    setState(() {
      _pinPosition = pos;
      _locationLabel = label;
      _searchController.text = label;
      _showSuggestions = false;
    });

    _searchFocus.unfocus();
    _mapController.move(pos, 14);
  }

  // ── Confirm ────────────────────────────────────────────────────────────
  void _confirmLocation() {
    Navigator.pop(context, {
      'lat': _pinPosition.latitude,
      'lng': _pinPosition.longitude,
      'area_label': _locationLabel.isNotEmpty
          ? _locationLabel
          : '${_pinPosition.latitude.toStringAsFixed(4)}, ${_pinPosition.longitude.toStringAsFixed(4)}',
    });
  }

  double _zoomFromRadius(double radiusKm) {
    return 14 - (log(radiusKm) / log(2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgContent,
      body: SafeArea(
        child: ColoredBox(
          color: context.bgOuter,
          child: Stack(
            children: [
              // ── Full screen map ──
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _pinPosition,
                  initialZoom: _zoomFromRadius(widget.radius),
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture && position.center != null) {
                      setState(() {
                        _pinPosition = position.center!;
                        // Reset label kalau user geser manual
                        if (_locationLabel.isNotEmpty) {
                          _locationLabel = '';
                          _searchController.clear();
                        }
                      });
                    }
                  },
                ),
                children: [
                  buildTileLayer(context),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: LatLng(
                          _pinPosition.latitude,
                          _pinPosition.longitude,
                        ),
                        radius: widget.radius * 1000,
                        useRadiusInMeter: true,
                        color: context.primary.withOpacity(0.1),
                        borderColor: context.primary.withOpacity(0.4),
                        borderStrokeWidth: 1.5,
                      ),
                    ],
                  ),
                ],
              ),

              // ── Center pin ──
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: context.primary,
                          size: 48,
                        ),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Top bar: back + search ──
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
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Back button
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.bgCard,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.black.withOpacity(0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                  border: Border.all(color: context.divider),
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  size: 20,
                                  color: context.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Search bar
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: context.black.withOpacity(0.1),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: InputField(
                                  controller: _searchController,
                                  hint: 'field_hints.search_location'.tr(),
                                  onChanged: (val) {
                                    setState(() {});
                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () {
                                        if (_searchController.text == val) {
                                          _search(val);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ── Dropdown suggestions ──
                        if (_showSuggestions && _searchResults.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 6, left: 46),
                            decoration: BoxDecoration(
                              color: context.bgCard,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: context.black.withOpacity(0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: _searchResults.map((place) {
                                final label = _formatLabel(place);
                                final isLast = _searchResults.last == place;
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () => _selectPlace(place),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: context.grey,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                label,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: context.black87,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (!isLast)
                                      const Divider(
                                        height: 1,
                                        indent: 42,
                                        color: Color(0xFFF0F0F0),
                                      ),
                                  ],
                                );
                              }).toList(),
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
                      color: context.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: context.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: _isLoadingLocation
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.primary,
                            ),
                          )
                        : Icon(
                            Icons.my_location,
                            color: context.primary,
                            size: 22,
                          ),
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
                  decoration: BoxDecoration(
                    color: context.bgContent,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: context.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _locationLabel.isNotEmpty
                                  ? _locationLabel
                                  : '${_pinPosition.latitude.toStringAsFixed(5)}, '
                                        '${_pinPosition.longitude.toStringAsFixed(5)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                              children: [
                                TextSpan(
                                  text: 'general.radius_display'.tr(
                                    args: [widget.radius.toStringAsFixed(1)],
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: context.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Titik ini akan jadi pusat area layanan Anda',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _confirmLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.primary,
                            foregroundColor: context.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'confirm_location'.tr(),
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
        ),
      ),
    );
  }
}
