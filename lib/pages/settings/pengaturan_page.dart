import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/auth/auth_screen.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:piawai/services/auth_services.dart';
import 'package:piawai/services/worker_services.dart';

// ─────────────────────────────────────────
// PENGATURAN PAGE
// ─────────────────────────────────────────
class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final _workerService = WorkerService();

  // state untuk data
  WorkerProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final profile = await _workerService.fetchProfile();

      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Loading ──
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ── Error ──
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadAll, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        title: const Text(
          'Pengaturan',
          style: TextStyle(
            color: kPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProfileCard(profile: _profile!),
          const SizedBox(height: 24),

          _SectionLabel(label: 'Akun'),
          const SizedBox(height: 8),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.person_outline,
                label: 'Informasi Pribadi',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.shield_outlined,
                label: 'Kata Sandi & Keamanan',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          _SectionLabel(label: 'Aplikasi'),
          const SizedBox(height: 8),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.language,
                label: 'Bahasa',
                trailing: 'Indonesia',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          _SectionLabel(label: 'Bantuan'),
          const SizedBox(height: 8),
          _SettingsGroup(
            items: [
              _SettingsItem(
                icon: Icons.help_outline,
                label: 'Pusat Bantuan',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                label: 'Kebijakan Privasi',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.description_outlined,
                label: 'Syarat & Ketentuan',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),

          _LogoutButton(
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text('Keluar'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
              if (confirm != true) return;
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
          const SizedBox(height: 16),

          const Center(
            child: Text(
              'Versi 2.4.1 (2024)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// PROFILE CARD
// ─────────────────────────────────────────
class ProfileCard extends StatelessWidget {
  final WorkerProfileModel profile;
  const ProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kPrimary.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: Container(
                color: kBgCard,
                child: const Icon(Icons.person, size: 32, color: kPrimary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.fullName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 3),
              Text(
                profile.username,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: kPrimary,
      ),
    );
  }
}

// ─────────────────────────────────────────
// SETTINGS GROUP
// ─────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<_SettingsItem> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final isLast = i == items.length - 1;
          return Column(
            children: [
              items[i],
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 6,
                  endIndent: 6,
                  color: const Color(0xFFEEF0F0),
                ),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────
// SETTINGS ITEM
// ─────────────────────────────────────────
class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kBgCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: kPrimary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// LOGOUT BUTTON
// ─────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
