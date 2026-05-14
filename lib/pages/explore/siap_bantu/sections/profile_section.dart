// ─────────────────────────────────────────
// PROFIL SECTION
// ─────────────────────────────────────────
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/core/helper.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
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
      _jenisKelamin = initialProfile.gender;
    }
  }

  bool _isSaving = false;

  bool get _canSave =>
      _fullNameController.text.trim().isNotEmpty &&
      _jenisKelamin != null &&
      !_isSaving;

  @override
  void dispose() {
    _fullNameController.dispose();
    super.dispose();
  }

  // ── Refetch setelah CRUD ───────────────────────────────────────────────
  Future<void> _refetch() async {
    try {
      setState(() => _isRefetching = true);
      final raw = await _workerService.fetchProfile();
      setState(() {
        _fullNameController.text = raw.fullName;
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
              leading: const Icon(
                Icons.photo_library_outlined,
                color: kPrimary,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: kPrimary),
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
              const Text(
                'Informasi Profil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lengkapi data diri Anda agar pemesan jasa merasa lebih percaya.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // ── Foto Profil ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGrey),
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
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
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
                                        child: const Icon(
                                          Icons.person,
                                          size: 52,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: kGrey,
                                      child: const Icon(
                                        Icons.person,
                                        size: 52,
                                        color: Colors.grey,
                                      ),
                                    ),
                            ),
                          ),
                          // Camera badge
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: kPrimary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: const Text(
                        'Ubah Foto Profil',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Nama Lengkap ──
              const Text(
                'Nama Lengkap',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lengkap',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: kPrimary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Jenis Kelamin ──
              const Text(
                'Jenis Kelamin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _GenderButton(
                    label: 'Pria',
                    icon: Icons.male,
                    isSelected: _jenisKelamin == 'Pria',
                    onTap: () => setState(() => _jenisKelamin = 'Pria'),
                  ),
                  const SizedBox(width: 12),
                  _GenderButton(
                    label: 'Wanita',
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
                      : const Text(
                          'Simpan Layanan',
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
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.white60,
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
            color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? kPrimary : kGrey, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: isSelected ? kPrimary : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? kPrimary : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
