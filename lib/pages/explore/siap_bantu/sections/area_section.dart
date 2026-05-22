import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/explore/siap_bantu/atur_lokasi_page.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:piawai/pages/widgets/map_component.dart';
import 'package:piawai/pages/widgets/overlay_snackbar.dart';
import 'package:piawai/services/worker_services.dart';

class AreaSection extends StatefulWidget {
  final WorkerProfileModel? initialProfile;
  final VoidCallback? onDataChanged;

  const AreaSection({
    super.key,
    required this.initialProfile,
    this.onDataChanged,
  });

  @override
  State<AreaSection> createState() => AreaSectionState();
}

class AreaSectionState extends State<AreaSection> {
  double _radius = 15;
  final double _minRadius = 1;
  final double _maxRadius = 50;
  double? _lat;
  double? _lng;
  String? _areaLabel;

  final _workerService = WorkerService();
  bool _isSaving = false;

  String get _radiusLabel {
    if (_radius % 1 == 0) return '${_radius.toInt()} km';
    return '${_radius.toStringAsFixed(1)} km';
  }

  bool get _canSave => _lat != null && _lng != null && !_isSaving;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    if (p != null) {
      _radius = p.radiusKm.toDouble();
      _lat = p.lat;
      _lng = p.lng;
      _areaLabel = p.areaLabel;
    }
  }

  Future<void> _saveArea() async {
    if (!_canSave) return;

    setState(() => _isSaving = true);
    try {
      await _workerService.updateProfile({
        'lat': _lat,
        'lng': _lng,
        'radius_km': _radius.toInt(),
        'area_label': _areaLabel,
      });
      widget.onDataChanged?.call();
      if (mounted) {
        showOverlaySnackbar(context, "service_area_success_added".tr());
      }
    } catch (e) {
      if (mounted) {
        showOverlaySnackbar(
          context,
          'general.save_failed'.tr(args: ['$e']),
          isError: true,
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'siap_bantu.area_services'.tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AturLokasiPage(initialLat: _lat, initialLng: _lng),
                    ),
                  );

                  // ← terima data balik dari AturLokasiPage
                  if (result != null) {
                    setState(() {
                      _lat = result['lat'];
                      _lng = result['lng'];
                      _areaLabel = result['area_label'];
                    });
                  }
                },
                child: Row(
                  children: [
                    Text(
                      "siap_bantu.setting_services".tr(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right, size: 18, color: kPrimary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'siap_bantu.define_scope_work'.tr(),
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // ── Map Card ──
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kGrey),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _lat != null && _lng != null
                    ? _LocationSudahDiatur(lat: _lat, lng: _lng)
                    : _LokasiBelumDiatur(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.my_location,
                          color: kPrimary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _areaLabel ?? 'siap_bantu.location_not_set'.tr(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _lat != null && _lng != null
                                  ? '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'
                                  : 'siap_bantu.tap_set_location'.tr(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Radius Slider ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "siap_bantu.radius_range".tr(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                _radiusLabel,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: kPrimary,
              inactiveTrackColor: kGrey,
              thumbColor: kPrimary,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              trackHeight: 4,
            ),
            child: Slider(
              value: _radius,
              min: _minRadius,
              max: _maxRadius,
              divisions: 49,
              onChanged: (v) => setState(() => _radius = v),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'general.radius_display'.tr(args: ['1']),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  'general.radius_display'.tr(args: ['25']),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  'general.radius_display'.tr(args: ['50']),
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Info Box ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: kPrimary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "siap_bantu.radius_range_desc".tr(),
                    style: TextStyle(fontSize: 12, color: Color(0xFF1e40af)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Save Button ──
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _canSave ? _saveArea : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimary,
                disabledBackgroundColor: const Color(0xFFD1D5DB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'general.save_changes'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationSudahDiatur extends StatelessWidget {
  const _LocationSudahDiatur({required double? lat, required double? lng})
    : _lat = lat,
      _lng = lng;

  final double? _lat;
  final double? _lng;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160, // ← wajib ada
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(_lat!, _lng!),
          initialZoom: 13,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.none,
          ),
        ),
        children: [
          buildTileLayer(),
          CircleLayer(
            circles: [
              CircleMarker(
                point: LatLng(_lat!, _lng!),
                radius: 40,
                color: kPrimary.withOpacity(0.2),
                borderColor: kPrimary.withOpacity(0.6),
                borderStrokeWidth: 2,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(_lat!, _lng!),
                width: 32,
                height: 32,
                child: const Icon(Icons.my_location, color: kPrimary, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LokasiBelumDiatur extends StatelessWidget {
  const _LokasiBelumDiatur();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0d2137), Color(0xFF0d3b5e), Color(0xFF0a4f7a)],
        ),
      ),
      child: Stack(
        children: [
          // ── Grid background ──
          Positioned.fill(
            child: CustomPaint(painter: _MapPlaceholderPainter()),
          ),
          // ── Center content ──
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_off_outlined,
                  color: Colors.white.withOpacity(0.5),
                  size: 36,
                ),
                const SizedBox(height: 8),
                Text(
                  'siap_bantu.location_not_set'.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'siap_bantu.tap_set_location'.tr(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Map Placeholder Painter
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

    final path3 = Path()
      ..moveTo(size.width * 0.1, 0)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.4,
        size.width * 0.4,
        size.height * 0.3,
        size.width * 0.5,
        size.height,
      );
    canvas.drawPath(path3, contourPaint);
  }

  @override
  bool shouldRepaint(_MapPlaceholderPainter oldDelegate) => false;
}
