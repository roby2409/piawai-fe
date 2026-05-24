// ─────────────────────────────────────────
// PROFIL SECTION
// ─────────────────────────────────────────
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/core/helper.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:piawai/pages/widgets/input_field.dart';
import 'package:piawai/services/worker_services.dart';

class ProfilSection extends StatefulWidget {
  final WorkerProfileModel? initialProfile;
  final VoidCallback? onDataChanged;

  const ProfilSection({
    super.key,
    required this.initialProfile,
    this.onDataChanged,
  });

  @override
  State<ProfilSection> createState() => ProfilSectionState();
}

class ProfilSectionState extends State<ProfilSection> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  String? _jenisKelamin;
  Uint8List? _fotoBytes; // null = pakai
  bool _isRefetching = false;
  final _workerService = WorkerService();

  @override
  void initState() {
    super.initState();
    if (widget.initialProfile != null) {
      final initialProfile = widget.initialProfile!;
      _fullNameController.text = initialProfile.fullName;
      _usernameController.text = initialProfile.username;
      _ageController.text = initialProfile.age?.toString() ?? '';
      _jenisKelamin = initialProfile.gender;
    }
  }

  bool _isSaving = false;

  bool get _canSave =>
      _fullNameController.text.trim().isNotEmpty &&
      _usernameController.text.trim().isNotEmpty &&
      _jenisKelamin != null &&
      !_isSaving;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // ── Refetch setelah CRUD ───────────────────────────────────────────────
  Future<void> _refetch() async {
    try {
      setState(() => _isRefetching = true);
      final raw = await _workerService.fetchProfile();
      setState(() {
        _fullNameController.text = raw.fullName;
        _usernameController.text = raw.username;
        _jenisKelamin = raw.gender;
        _fotoBytes = null; // ← reset setelah upload sukses
        _isRefetching = false;
      });
      widget.onDataChanged?.call();
    } catch (e) {
      setState(() => _isRefetching = false);
    }
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.photo_library_outlined,
                color: context.primary,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: context.primary),
              title: const Text('Ambil Foto'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _fotoBytes = bytes);
  }

  Future<void> _onSimpan() async {
    if (!_canSave) return;

    final payload = {
      'nama': _fullNameController.text.trim(),
      'username': _usernameController.text.trim(),
      'age': int.parse(_ageController.text),
      'gender': _jenisKelamin,
    };

    setState(() => _isSaving = true);
    try {
      await _workerService.updateProfile(payload);
      if (_fotoBytes != null) {
        await _workerService.uploadAvatar(_fotoBytes!);
      }
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
              // ── Title ──
              Text(
                'siap_bantu.information_profile'.tr(),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'siap_bantu.information_profile_desc'.tr(),
                style: TextStyle(fontSize: 13, color: context.black87),
              ),
              const SizedBox(height: 20),

              // ── Foto Profil ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: context.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.divider),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.bgContent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: context.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _fotoBytes != null
                                  ? Image.memory(_fotoBytes!, fit: BoxFit.cover)
                                  : widget.initialProfile?.avatarUrl != null
                                  ? Image.network(
                                      imageUrl(
                                        widget.initialProfile!.avatarUrl!,
                                      ),
                                      fit: BoxFit.cover,
                                      // Loading placeholder
                                      loadingBuilder: (_, child, progress) =>
                                          progress == null
                                          ? child
                                          : const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                      // Error fallback
                                      errorBuilder: (_, __, ___) => Container(
                                        color: kGrey,
                                        child: Icon(
                                          Icons.person,
                                          size: 52,
                                          color: context.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: kGrey,
                                      child: Icon(
                                        Icons.person,
                                        size: 52,
                                        color: context.grey,
                                      ),
                                    ),
                            ),
                          ),
                          // Camera badge
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: context.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: context.white,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: context.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Text(
                        'siap_bantu.change_profile_picture'.tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Nama Lengkap ──
              Text(
                'fields.full_name'.tr(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _fullNameController,
                hint: 'field_hints.full_name'.tr(),
              ),
              const SizedBox(height: 20),

              // Email
              Text(
                "fields.username".tr(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                hint: 'field_hints.username'.tr(),
                prefixIcon: Icons.alternate_email_outlined,
              ),
              const SizedBox(height: 16),

              Text(
                'fields.age_range'.tr(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              InputField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                hint: 'general.age_display'.tr(args: ['25']),
              ),
              const SizedBox(height: 16),

              // ── Jenis Kelamin ──
              Text(
                'fields.gender'.tr(),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _GenderButton(
                    label: 'general.man'.tr(),
                    icon: Icons.male,
                    isSelected: _jenisKelamin == 'Pria',
                    onTap: () => setState(() => _jenisKelamin = 'Pria'),
                  ),
                  const SizedBox(width: 12),
                  _GenderButton(
                    label: 'general.woman'.tr(),
                    icon: Icons.female,
                    isSelected: _jenisKelamin == 'Wanita',
                    onTap: () => setState(() => _jenisKelamin = 'Wanita'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Save Button ──
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

// ─────────────────────────────────────────
// GENDER BUTTON
// ─────────────────────────────────────────
class _GenderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? context.bgCard : context.bgOuter,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? context.primary : context.divider,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? context.primary : context.black87,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? context.primary : context.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
