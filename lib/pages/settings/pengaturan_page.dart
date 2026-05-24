import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/core/helper.dart';
import 'package:piawai/pages/auth/auth_screen.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:piawai/pages/settings/informasi_pribadi_page.dart';
import 'package:piawai/pages/settings/kata_password_page.dart';
import 'package:piawai/services/auth_services.dart';
import 'package:piawai/services/theme_service.dart';
import 'package:piawai/services/worker_services.dart';

import 'language_page.dart';
import 'bantuan_page.dart';

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
    return Scaffold(
      backgroundColor: context.bgOuter,
      appBar: AppBar(
        backgroundColor: context.bgContent,
        elevation: 0,
        title: Text(
          'settings.title'.tr(),
          style: TextStyle(
            color: context.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
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
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ProfileCard(profile: _profile!),
        const SizedBox(height: 24),

        _SectionLabel(label: 'settings.account'.tr()),
        const SizedBox(height: 8),
        _SettingsGroup(
          items: [
            _SettingsItem(
              icon: Icons.person_outline,
              label: 'settings.account_section.personal_info'.tr(),
              onTap: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => InformasiPribadiPage(
                      currentEmail: _profile!.emailContact ?? "",
                    ),
                  ),
                );
                if (changed == true) {
                  _loadAll();
                }
              },
            ),
            _SettingsItem(
              icon: Icons.shield_outlined,
              label: 'settings.account_section.security'.tr(),
              onTap: () async {
                final changed = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => KataPasswordPage()),
                );
                if (changed == true) {
                  _loadAll();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),

        _SectionLabel(label: 'settings.app_section.title'.tr()),
        const SizedBox(height: 8),
        _SettingsGroup(
          items: [
            _SettingsItem(
              icon: Icons.language,
              label: 'settings.language'.tr(),
              trailing: context.locale.languageCode,
              onTap: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LanguagePage()),
                );
              },
            ),
            _ThemeSwitchItem(),
          ],
        ),
        const SizedBox(height: 24),

        _SectionLabel(label: 'settings.help_section.title'.tr()),
        const SizedBox(height: 8),
        _SettingsGroup(
          items: [
            _SettingsItem(
              icon: Icons.help_outline,
              label: 'settings.help_section.help_center'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PusatBantuanPage()),
              ),
            ),
            _SettingsItem(
              icon: Icons.privacy_tip_outlined,
              label: 'settings.help_section.privacy_policy'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KebijakanPrivasiPage()),
              ),
            ),
            _SettingsItem(
              icon: Icons.description_outlined,
              label: 'settings.help_section.terms'.tr(),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SyaratKetentuanPage()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        _LogoutButton(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: context.bgCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text('settings.logout'.tr()),
                content: Text('settings.logout_confirm_message'.tr()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'settings.logout_cancel'.tr(),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'settings.logout_confirm_title'.tr(),
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
    );
  }
}

// ─────────────────────────────────────────
// PROFILE CARD
// ─────────────────────────────────────────
class ProfileCard extends StatelessWidget {
  final WorkerProfileModel profile;
  const ProfileCard({super.key, required this.profile});

  String get _initials {
    final parts = profile.fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.bgCard,
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
          // Initials Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: context.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _initials,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${profile.username}',
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
                if (profile.emailContact != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 12,
                        color: context.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          profile.emailContact!,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
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
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: context.primary,
      ),
    );
  }
}

// ─────────────────────────────────────────
// SETTINGS GROUP
// ─────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgCard,
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
                  color: context.divider,
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
                color: context.bgCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: context.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: TextStyle(fontSize: 13, color: context.textSecondary),
              ),
              const SizedBox(width: 4),
            ],
            Icon(Icons.chevron_right, size: 18, color: context.textSecondary),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Colors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'settings.logout'.tr(),
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

// ─────────────────────────────────────────
// THEME SWITCH ITEM
// ─────────────────────────────────────────
class _ThemeSwitchItem extends StatelessWidget {
  const _ThemeSwitchItem();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return InkWell(
          onTap: () => themeService.toggleTheme(),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.bgCard,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    themeService.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    size: 18,
                    color: context.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                Text(
                  themeService.isDarkMode ? 'Dark' : 'Light',
                  style: TextStyle(fontSize: 13, color: context.textSecondary),
                ),
                const SizedBox(width: 4),
                Switch(
                  value: themeService.isDarkMode,
                  onChanged: (_) => themeService.toggleTheme(),
                  activeColor: context.primary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
