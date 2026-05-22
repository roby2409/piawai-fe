import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:piawai/pages/widgets/overlay_snackbar.dart';
import 'package:piawai/services/worker_services.dart';

class StatusSection extends StatefulWidget {
  final WorkerProfileModel? initialProfile;
  final VoidCallback? onDataChanged;

  const StatusSection({
    super.key,
    required this.initialProfile,
    this.onDataChanged,
  });

  @override
  State<StatusSection> createState() => StatusSectionState();
}

class StatusSectionState extends State<StatusSection> {
  final _workerService = WorkerService();
  bool _isAvailable = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isAvailable = widget.initialProfile?.isAvailable ?? false;
  }

  Future<void> _saveStatus() async {
    setState(() => _isSaving = true);
    try {
      await _workerService.updateProfile({
        'is_available': _isAvailable ? 1 : 0,
      });
      widget.onDataChanged?.call();
      if (mounted) {
        showOverlaySnackbar(context, "siap_bantu.status_success_save".tr());
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
          // ── Title ──
          Text(
            'siap_bantu.status_work'.tr(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // ── Toggle Card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kGrey),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'siap_bantu.status_ready_work_accept'.tr(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isAvailable
                            ? 'siap_bantu.status_ready_work_accept'.tr()
                            : 'siap_bantu.activate_to_start'.tr(),
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: _isAvailable,
                    onChanged: _isSaving
                        ? null
                        : (val) => setState(() => _isAvailable = val),
                    activeColor: Colors.white,
                    activeTrackColor: kPrimary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: kGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Info Box ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _isAvailable
                  ? const Color(0xFFEFF6FF)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isAvailable ? const Color(0xFFBFDBFE) : kGrey,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: _isAvailable ? kPrimary : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isAvailable
                        ? 'siap_bantu.status_is_active'.tr()
                        : 'siap_bantu.status_is_not_active'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _isAvailable
                          ? const Color(0xFF1e40af)
                          : Colors.grey[500],
                    ),
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
              onPressed: _isSaving ? null : _saveStatus,
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
