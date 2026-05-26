// ─────────────────────────────────────────
// TENTANG SECTION
// ─────────────────────────────────────────
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/core/snackbar_helper.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/services/worker_services.dart';

class TentangSection extends StatefulWidget {
  final WorkerProfileModel? initialProfile;
  final VoidCallback? onDataChanged;

  const TentangSection({
    super.key,
    required this.initialProfile,
    this.onDataChanged,
  });

  @override
  State<TentangSection> createState() => TentangSectionState();
}

class TentangSectionState extends State<TentangSection> {
  final TextEditingController _bioController = TextEditingController();
  final int _maxChars = 300;
  bool _isRefetching = false;
  final _workerService = WorkerService();

  bool _isSaving = false;

  bool get _canSave => _bioController.text.trim().isNotEmpty && !_isSaving;

  @override
  void initState() {
    super.initState();
    if (widget.initialProfile != null) {
      final initialProfile = widget.initialProfile!;
      _bioController.text = initialProfile.bio ?? "";
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  // ── Refetch setelah CRUD ───────────────────────────────────────────────
  Future<void> _refetch() async {
    try {
      setState(() => _isRefetching = true);
      final raw = await _workerService.fetchProfile();
      setState(() {
        _bioController.text = raw.bio ?? "";
        _isRefetching = false;
      });
      widget.onDataChanged?.call();
    } catch (e) {
      setState(() => _isRefetching = false);
      SnackBarHelper.showErrorSnackBar(
        context,
        'general.fetch_failed'.tr(args: ['$e']),
      );
    }
  }

  Future<void> _onSimpan() async {
    if (!_canSave) return;

    final payload = {'bio': _bioController.text.trim()};

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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'about_me'.tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'complete_about_me'.tr(),
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
              const SizedBox(height: 20),

              // Bio Textarea
              Text(
                'bio_professional_experience'.tr(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  InputField(
                    controller: _bioController,
                    hint: 'field_hints.about_me_bio'.tr(),
                    maxLines: 6,
                    maxLength: _maxChars,
                    buildCounter:
                        (
                          _, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) => null, // hide default counter
                    onChanged: (_) => setState(() {}),
                  ),
                  // Character counter bottom-right
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Text(
                      '${_bioController.text.length} / $_maxChars',
                      style: TextStyle(color: context.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Info box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: context.primary, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "field_hints.about_me_info".tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF1e40af),
                        ),
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
