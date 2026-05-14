// ─────────────────────────────────────────
// TENTANG SECTION
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      }
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
              const Text(
                'Tentang Saya',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Lengkapi informasi diri Anda untuk membangun kepercayaan dengan pelanggan.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Bio Textarea
              const Text(
                'Bio & Pengalaman Profesional',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  TextField(
                    controller: _bioController,
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
                    decoration: InputDecoration(
                      hintText:
                          'Ceritakan pengalaman dan keahlian Anda di sini untuk menarik perhatian pencari jasa...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
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
                    ),
                  ),
                  // Character counter bottom-right
                  Positioned(
                    bottom: 8,
                    right: 12,
                    child: Text(
                      '${_bioController.text.length} / $_maxChars',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: kPrimary, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Profil yang lengkap dengan deskripsi yang menarik memiliki peluang 3x lebih besar untuk mendapatkan pesanan.',
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
              // Save button
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
                          'Simpan Perubahan',
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
