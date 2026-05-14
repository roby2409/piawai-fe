// ─────────────────────────────────────────
// KONTAK SECTION
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
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
  final _emailController = TextEditingController();
  final _igController = TextEditingController();
  bool _isRefetching = false;
  final _workerService = WorkerService();

  bool _isSaving = false;

  bool get _canSave =>
      _phoneController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      !_isSaving;

  @override
  void initState() {
    super.initState();
    if (widget.initialProfile != null) {
      final initialProfile = widget.initialProfile!;
      _phoneController.text = initialProfile.phoneWa ?? "";
      _emailController.text = initialProfile.emailContact ?? "";
      _igController.text = initialProfile.instagram ?? "";
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
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
        _emailController.text = raw.emailContact ?? "";
        _igController.text = raw.instagram ?? "";
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

    final payload = {
      'phone_wa': _phoneController.text.trim(),
      'email_contact': _emailController.text.trim(),
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
              const Text(
                'Informasi Kontak',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pastikan nomor dan email Anda aktif agar tidak melewatkan tawaran bantuan.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Nomor HP
              const Text(
                'Nomor HP (WhatsApp)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '81234567890',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Flag Indonesia emoji
                        const Text('🇮🇩', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          '+62',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 20,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
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
              const SizedBox(height: 16),

              // Email
              const Text(
                'Email',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'contoh@email.com',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.mail_outline,
                    color: Colors.grey,
                    size: 20,
                  ),
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
              const SizedBox(height: 16),

              // Instagram (Opsional)
              const Text(
                'Instagram (Opsional)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _igController,
                decoration: InputDecoration(
                  hintText: 'username_kamu',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '@',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
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
              const SizedBox(height: 24),

              // Tips Keamanan
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kBgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kPrimary, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.security_outlined,
                      color: kPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tips Keamanan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Piawai tidak pernah meminta password atau kode OTP Anda melalui WhatsApp, Email, maupun telepon. Pastikan komunikasi hanya terjadi di dalam aplikasi untuk keamanan ekstra.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
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
