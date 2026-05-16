import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/widgets/map_component.dart';

// ── Model hasil filter ──
class FilterResult {
  final String gender; // 'Semua' | 'Pria' | 'Wanita'
  final RangeValues ageRange;
  final String location;
  final double radiusKm;

  const FilterResult({
    required this.gender,
    required this.ageRange,
    required this.location,
    required this.radiusKm,
  });
}

// ─────────────────────────────────────────────
//  FILTER PAGE
// ─────────────────────────────────────────────
class FilterPage extends StatefulWidget {
  /// Lokasi pengguna saat ini (opsional, buat preview map)
  final LatLng? myLocation;

  /// Nilai filter awal (opsional)
  final FilterResult? initialFilter;

  const FilterPage({super.key, this.myLocation, this.initialFilter});

  @override
  State<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  // ── State filter ──
  late String _gender;
  late RangeValues _ageRange;
  late TextEditingController _locationCtrl;
  late double _radius;

  // Preview map
  final MapController _previewMapController = MapController();

  // Default center kalau lokasi null (Jakarta Selatan)
  static const _defaultCenter = LatLng(-6.2615, 106.8106);

  LatLng get _mapCenter => widget.myLocation ?? _defaultCenter;

  @override
  void initState() {
    super.initState();
    final init = widget.initialFilter;
    _gender = init?.gender ?? 'Semua';
    _ageRange = init?.ageRange ?? const RangeValues(18, 55);
    _locationCtrl = TextEditingController(
      text: init?.location ?? 'Jakarta Selatan',
    );
    _radius = init?.radiusKm ?? 15;
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _gender = 'Semua';
      _ageRange = const RangeValues(18, 55);
      _locationCtrl.text = 'Jakarta Selatan';
      _radius = 15;
    });
  }

  void _apply() {
    final result = FilterResult(
      gender: _gender,
      ageRange: _ageRange,
      location: _locationCtrl.text,
      radiusKm: _radius,
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ── Header ──
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Filter',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Jenis Kelamin
                  _SectionLabel('Jenis Kelamin'),
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
                      _SectionLabel('Rentang Umur'),
                      Text(
                        '${_ageRange.start.round()} - ${_ageRange.end.round()} Tahun',
                        style: const TextStyle(
                          color: kPrimary,
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
                  _SectionLabel('Lokasi'),
                  const SizedBox(height: 12),
                  _LocationSearchField(controller: _locationCtrl),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      // TODO: ambil lokasi saat ini
                    },
                    child: Row(
                      children: const [
                        Icon(Icons.my_location, color: kPrimary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Gunakan Lokasi Saat Ini',
                          style: TextStyle(
                            color: kPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Mini map preview
                  _MapPreview(
                    center: _mapCenter,
                    radiusKm: _radius,
                    mapController: _previewMapController,
                  ),

                  const SizedBox(height: 28),

                  // 4. Radius Pencarian
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SectionLabel('Radius Pencarian'),
                      Text(
                        '${_radius.round()} km',
                        style: const TextStyle(
                          color: kPrimary,
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
                    minLabel: '1km',
                    maxLabel: '50km',
                    onChanged: (val) => setState(() => _radius = val),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Tombol Tampilkan Hasil ──
          _ApplyButton(onTap: _apply),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SUB-WIDGETS
// ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w600,
      fontSize: 15,
    ),
  );
}

// ── Gender Toggle ──
class _GenderToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _GenderToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = ['Semua', 'Pria', 'Wanita'];
    return Row(
      children: options
          .map(
            (opt) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _GenderChip(
                label: opt,
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
          color: isSelected ? kPrimary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? kPrimary : const Color(0xFFD0D5DD),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ── Range Slider ──
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
        activeTrackColor: kPrimary,
        inactiveTrackColor: const Color(0xFFE0E7F0),
        thumbColor: kPrimary,
        overlayColor: kPrimary.withOpacity(0.12),
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

// ── Single Slider with min/max labels ──
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
            activeTrackColor: kPrimary,
            inactiveTrackColor: const Color(0xFFE0E7F0),
            thumbColor: kPrimary,
            overlayColor: kPrimary.withOpacity(0.12),
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
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
              Text(
                maxLabel,
                style: const TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Location Search Field ──
class _LocationSearchField extends StatelessWidget {
  final TextEditingController controller;
  const _LocationSearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: 'Cari lokasi...',
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 20),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E7F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E7F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
    );
  }
}

// ── Map Preview ──
class _MapPreview extends StatelessWidget {
  final LatLng center;
  final double radiusKm;
  final MapController mapController;

  const _MapPreview({
    required this.center,
    required this.radiusKm,
    required this.mapController,
  });

  @override
  Widget build(BuildContext context) {
    // radius dalam meter untuk CircleLayer
    final radiusM = radiusKm * 1000;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 180,
        child: Stack(
          children: [
            FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 12,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none, // non-interaktif (preview)
                ),
              ),
              children: [
                buildTileLayer(),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: center,
                      radius: radiusM,
                      useRadiusInMeter: true,
                      color: kPrimary.withOpacity(0.12),
                      borderColor: kPrimary.withOpacity(0.5),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: kPrimary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimary.withOpacity(0.3),
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
            // Badge "Pratinjau Jangkauan"
            Positioned(
              bottom: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 14,
                      color: Colors.black54,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Pratinjau Jangkauan',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
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

// ── Apply Button ──
class _ApplyButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ApplyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
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
            backgroundColor: kPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Tampilkan Hasil',
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
