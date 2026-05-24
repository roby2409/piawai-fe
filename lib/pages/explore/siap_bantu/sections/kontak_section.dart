// ─────────────────────────────────────────
// KONTAK SECTION
// ─────────────────────────────────────────
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/services/worker_services.dart';

class KontakSection extends StatefulWidget {
  final WorkerProfileModel? initialProfile;
  final VoidCallback? onDataChanged;

  const KontakSection({
    super.key,
    required this.initialProfile,
    this.onDataChanged,
  });

  @override
  State<KontakSection> createState() => KontakSectionState();
}

class KontakSectionState extends State<KontakSection> {
  final _phoneController = TextEditingController();
  final _igController = TextEditingController();
  bool _isRefetching = false;
  final _workerService = WorkerService();

  bool _isSaving = false;

  bool get _canSave => _phoneController.text.trim().isNotEmpty && !_isSaving;

  @override
  void initState() {
    super.initState();
    if (widget.initialProfile != null) {
      final initialProfile = widget.initialProfile!;
      _phoneController.text = initialProfile.phoneWa ?? "";
      _igController.text = initialProfile.instagram ?? "";
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _igController.dispose();
    super.dispose();
  }

  // ── Refetch setelah CRUD ───────────────────────────────────────────────
  Future<void> _refetch() async {
    try {
      setState(() => _isRefetching = true);
      final raw = await _workerService.fetchProfile();
      setState(() {
        _phoneController.text = raw.phoneWa ?? "";
        _igController.text = raw.instagram ?? "";
        _isRefetching = false;
      });
      widget.onDataChanged?.call();
    } catch (e) {
      setState(() => _isRefetching = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('general.fetch_failed'.tr(args: ['$e']))),
        );
      }
    }
  }

  Future<void> _onSimpan() async {
    if (!_canSave) return;

    final payload = {
      'phone_wa': _phoneController.text.trim(),
      'instagram': _igController.text.trim(),
    };

    setState(() => _isSaving = true);
    try {
      await _workerService.updateProfile(payload);
      _refetch();
      setState(() => _isSaving = false);
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'siap_bantu.information_contact'.tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'siap_bantu.information_contact_desc'.tr(),
                style: TextStyle(fontSize: 13, color: context.black87),
              ),
              const SizedBox(height: 20),

              // Nomor HP
              Text(
                'fields.phone_whatsapp'.tr(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                hint: 'field_hints.phone_whatsapp'.tr(),
              ),
              const SizedBox(height: 16),

              // Instagram (Opsional)
              Text(
                '${'fields.instagram'.tr()} (${'general.optional'.tr()})',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _igController,
                hint: 'field_hints.instagram_username'.tr(),
              ),
              const SizedBox(height: 24),

              // Tips Keamanan
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.primary, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.security_outlined,
                      color: context.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'secure_tips'.tr(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: context.textSecondary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'secure_tips_desc'.tr(),
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
              ),
              const SizedBox(height: 24),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _canSave ? _onSimpan : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    foregroundColor: context.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.white,
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
        ),
        if (_isRefetching)
          Positioned.fill(
            child: ColoredBox(
              color: context.white60,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
