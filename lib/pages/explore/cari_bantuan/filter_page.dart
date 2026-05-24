import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/pages/explore/siap_bantu/atur_lokasi_page.dart';
import 'package:piawai/pages/widgets/loading_detect_location.dart';
import 'package:piawai/pages/widgets/map_component.dart';

// ── Model hasil filter ──
class FilterResult {
  final String gender;
  final RangeValues ageRange;
  final String location;
  final double radiusKm;
  final LatLng? locationLatLng;

  const FilterResult({
    required this.gender,
    required this.ageRange,
    required this.location,
    required this.radiusKm,
    this.locationLatLng,
  });
}

// ─────────────────────────────────────────────
//  FILTER PAGE
// ─────────────────────────────────────────────
class FilterPage extends StatefulWidget {
  final LatLng myLocation;
  final FilterResult? initialFilter;

  const FilterPage({super.key, required this.myLocation, this.initialFilter});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  late String _gender;
  late RangeValues _ageRange;
  late double _radius;
  late LatLng _currentLocation;
  late String _locationLabel;
  bool _isLoadingCurrentLocation = false;

  final MapController _previewMapController = MapController();

  @override
  void initState() {
    super.initState();
    final init = widget.initialFilter;
    _gender = init?.gender ?? 'Semua';
    _ageRange = init?.ageRange ?? const RangeValues(18, 55);
    _radius = init?.radiusKm ?? 15;
    _currentLocation = init?.locationLatLng ?? widget.myLocation;
    _locationLabel = init?.location ?? 'my_location'.tr();
  }

  void _reset() async {
    await _getCurrentLocation();
    setState(() {
      _gender = 'Semua';
      _ageRange = const RangeValues(18, 55);
      _radius = 15;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      FilterResult(
        gender: _gender,
        ageRange: _ageRange,
        location: _locationLabel,
        radiusKm: _radius,
        locationLatLng: _currentLocation,
      ),
    );
  }

  void _movePreviewMap(LatLng loc) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _previewMapController.move(loc, 12);
    });
  }

  Future<void> _openLocationSearch() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => AturLokasiPage(
          initialLat: _currentLocation.latitude,
          initialLng: _currentLocation.longitude,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentLocation = LatLng(result['lat'], result['lng']);
        _locationLabel = result['area_label'] ?? '';
      });
      _movePreviewMap(_currentLocation);
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return; // ← add
    setState(() => _isLoadingCurrentLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return; // ← add (after await)
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _locationLabel = 'my_location'.tr();
        _isLoadingCurrentLocation = false;
      });
      _movePreviewMap(_currentLocation);
    } catch (e) {
      if (!mounted) return; // ← add
      setState(() => _isLoadingCurrentLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgOuter,
      appBar: AppBar(
        backgroundColor: context.bgContent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'general.filter'.tr(),
          style: TextStyle(
            color: context.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _reset,
            child: Text(
              'general.reset'.tr(),
              style: TextStyle(
                color: context.black54,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Gender
                  _SectionLabel('fields.gender'.tr()),
                  const SizedBox(height: 12),
                  _GenderToggle(
                    selected: _gender,
                    onChanged: (val) => setState(() => _gender = val),
                  ),

                  const SizedBox(height: 28),

                  // 2. Rentang Umur
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel('fields.age_range'.tr()),
                      Text(
                        'general.age_display'.tr(
                          args: [
                            '${_ageRange.start.round()} - ${_ageRange.end.round()}',
                          ],
                        ),
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _StyledRangeSlider(
                    values: _ageRange,
                    min: 17,
                    max: 70,
                    onChanged: (val) => setState(() => _ageRange = val),
                  ),

                  const SizedBox(height: 28),

                  // 3. Lokasi
                  _SectionLabel('fields.location'.tr()),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _openLocationSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: context.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.divider),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: context.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _locationLabel,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: context.primary,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: _getCurrentLocation,
                        child: Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              color: context.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'fields.use_current_location'.tr(),
                              style: TextStyle(
                                color: context.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Stack(
                    alignment: AlignmentGeometry.center,
                    children: [
                      _MapPreview(
                        center: _currentLocation,
                        radiusKm: _radius,
                        mapController: _previewMapController,
                        onLocationChanged: (latLng) {
                          // ← add this
                          setState(() {
                            _currentLocation = latLng;
                            _locationLabel = 'custom_location'.tr();
                          });
                        },
                      ),
                      if (_isLoadingCurrentLocation)
                        loadingCurrentLocation(context),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // 4. Radius
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel('search_radius'.tr()),
                      Text(
                        'general.radius_display'.tr(
                          args: ['${_radius.round()}'],
                        ),
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _StyledSlider(
                    value: _radius,
                    min: 1,
                    max: 50,
                    minLabel: 'general.radius_display'.tr(args: ['1']),
                    maxLabel: 'general.radius_display'.tr(args: ['50']),
                    onChanged: (val) {
                      setState(() => _radius = val);
                      _movePreviewMap(_currentLocation);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _ApplyButton(onTap: _apply),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LOCATION SEARCH BOTTOM SHEET — Nominatim
// ─────────────────────────────────────────────
class _LocationSearchSheet extends StatefulWidget {
  final LatLng myLocation;
  const _LocationSearchSheet({required this.myLocation});

  @override
  State<_LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<_LocationSearchSheet> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json&limit=6&addressdetails=1',
      );

      final response = await http
          .get(
            uri,
            headers: {
              'User-Agent': 'PiawaiApp/1.0', // wajib di Nominatim
            },
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        setState(() {
          _results = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'search_location_failed'.tr();
          _isLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _error = 'general.no_connection'.tr();
        _isLoading = false;
      });
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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, scrollCtrl) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: context.bgCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  style: TextStyle(color: context.black87),
                  decoration: InputDecoration(
                    hintText: 'field_hints.search_location'.tr(),
                    hintStyle: TextStyle(color: context.black38, fontSize: 14),
                    prefixIcon: Icon(
                      Icons.search,
                      color: context.black45,
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                  ),
                  onChanged: (val) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_ctrl.text == val) _search(val);
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: context.primary),
                    )
                  : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: TextStyle(color: context.grey),
                      ),
                    )
                  : ListView(
                      controller: scrollCtrl,
                      children: [
                        // Opsi lokasi saya selalu ada di atas
                        ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: context.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.my_location,
                              color: context.primary,
                              size: 18,
                            ),
                          ),
                          title: Text(
                            'my_location'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            'use_current_location'.tr(),
                            style: TextStyle(fontSize: 12),
                          ),
                          onTap: () => Navigator.pop(context, {
                            'lat': widget.myLocation.latitude,
                            'lon': widget.myLocation.longitude,
                            'label': 'my_location'.tr(),
                          }),
                        ),
                        const Divider(height: 1, indent: 56),

                        if (_results.isEmpty && _ctrl.text.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(
                              child: Text(
                                'location_not_found'.tr(),
                                style: TextStyle(color: context.grey),
                              ),
                            ),
                          ),

                        ..._results.map((place) {
                          final label = _formatLabel(place);
                          return Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: context.grey.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.location_on_outlined,
                                    color: context.black54,
                                    size: 18,
                                  ),
                                ),
                                title: Text(
                                  label,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => Navigator.pop(context, {
                                  'lat': double.parse(place['lat'] as String),
                                  'lon': double.parse(place['lon'] as String),
                                  'label': label,
                                }),
                              ),
                              const Divider(height: 1, indent: 56),
                            ],
                          );
                        }),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: context.textPrimary,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    ),
  );
}

class _GenderToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _GenderToggle({required this.selected, required this.onChanged});

  String displayOption(String value) {
    if (value == 'Semua') return 'general.semua'.tr();
    if (value == 'Pria') return 'general.man'.tr();
    if (value == 'Wanita') return 'general.woman'.tr();
    return value;
  }

  @override
  Widget build(BuildContext context) {
    const options = ['Semua', 'Pria', 'Wanita'];
    return Row(
      children: options
          .map(
            (opt) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _GenderChip(
                label: displayOption(opt),
                isSelected: selected == opt,
                onTap: () => onChanged(opt),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _GenderChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? context.primary : context.bgContent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? context.primary : context.divider,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? context.white : context.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _StyledRangeSlider extends StatelessWidget {
  final RangeValues values;
  final double min;
  final double max;
  final ValueChanged<RangeValues> onChanged;
  const _StyledRangeSlider({
    required this.values,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: context.primary,
        inactiveTrackColor: context.divider,
        thumbColor: context.primary,
        overlayColor: context.primary.withOpacity(0.12),
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
      ),
      child: RangeSlider(
        values: values,
        min: min,
        max: max,
        onChanged: onChanged,
      ),
    );
  }
}

class _StyledSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final String minLabel;
  final String maxLabel;
  final ValueChanged<double> onChanged;
  const _StyledSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.minLabel,
    required this.maxLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: context.primary,
            inactiveTrackColor: context.divider,
            thumbColor: context.primary,
            overlayColor: context.primary.withOpacity(0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel,
                style: TextStyle(color: context.black45, fontSize: 12),
              ),
              Text(
                maxLabel,
                style: TextStyle(color: context.black45, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapPreview extends StatefulWidget {
  final LatLng center;
  final double radiusKm;
  final MapController mapController;
  final ValueChanged<LatLng>? onLocationChanged; // ← add this

  const _MapPreview({
    required this.center,
    required this.radiusKm,
    required this.mapController,
    this.onLocationChanged, // ← add this
  });

  @override
  State<_MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<_MapPreview> {
  late LatLng _markerPoint;

  @override
  void initState() {
    super.initState();
    _markerPoint = widget.center;
  }

  @override
  void didUpdateWidget(_MapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync if parent resets location
    if (oldWidget.center != widget.center) {
      setState(() => _markerPoint = widget.center);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                initialCenter: _markerPoint,
                initialZoom: 12,
                // ← Remove InteractiveFlag.none, allow pan + tap
                onTap: (tapPosition, latLng) {
                  setState(() => _markerPoint = latLng);
                  widget.onLocationChanged?.call(latLng); // ← bubble up
                },
              ),
              children: [
                buildTileLayer(context),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _markerPoint,
                      radius: widget.radiusKm * 1000,
                      useRadiusInMeter: true,
                      color: context.primary.withOpacity(0.12),
                      borderColor: context.primary.withOpacity(0.5),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _markerPoint,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: context.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: context.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: context.primary.withOpacity(0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // ── Hint label ──
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: context.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_outlined,
                      size: 14,
                      color: context.black54,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'tap_map_for_move_point'.tr(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ApplyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.bgCard,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primary,
            foregroundColor: context.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Text(
            'general.show_result'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}
