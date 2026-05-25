import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:piawai/services/worker_services.dart';
import 'sections/area_section.dart';
import 'sections/kontak_section.dart';
import 'sections/layanan_section.dart' show LayananSection;
import 'sections/profile_section.dart';
import 'sections/status_section.dart';
import 'sections/tentang_section.dart';

class SiapBantuPage extends StatefulWidget {
  const SiapBantuPage({super.key});

  @override
  State<SiapBantuPage> createState() => _SiapBantuPageState();
}

class _SiapBantuPageState extends State<SiapBantuPage> {
  int _selectedIndex = 0;
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

  final List<_SidebarItem> _sidebarItems = [
    _SidebarItem(
      icon: Icons.person_outline,
      label: 'siap_bantu.sidebar.profil'.tr(),
    ),
    _SidebarItem(
      icon: Icons.phone_outlined,
      label: 'siap_bantu.sidebar.contact'.tr(),
    ),
    _SidebarItem(
      icon: Icons.work_outline,
      label: 'siap_bantu.sidebar.services'.tr(),
    ),
    _SidebarItem(
      icon: Icons.location_on_outlined,
      label: 'siap_bantu.sidebar.area'.tr(),
    ),
    _SidebarItem(icon: Icons.wifi, label: 'siap_bantu.sidebar.status'.tr()),
    _SidebarItem(
      icon: Icons.info_outline,
      label: 'siap_bantu.sidebar.about'.tr(),
    ),
  ];

  Widget _buildContent() {
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
            Icon(Icons.alarm, size: 40),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: TextStyle(color: context.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadAll, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    // ── Content ──
    switch (_selectedIndex) {
      case 0:
        return ProfilSection(
          initialProfile: _profile,
          onDataChanged: _loadAll, // ← callback setelah CRUD
        );
      case 1:
        return KontakSection(
          initialProfile: _profile,
          onDataChanged: _loadAll, // ← callback setelah CRUD
        );
      case 2:
        return LayananSection(
          initialServices: _profile?.services ?? [], // ← pass data
          onDataChanged: _loadAll, // ← callback setelah CRUD
        );
      case 3:
        return AreaSection(
          initialProfile: _profile,
          onDataChanged: _loadAll, // ← callback setelah CRUD
        );
      case 4:
        return StatusSection(
          initialProfile: _profile,
          onDataChanged: _loadAll, // ← callback setelah CRUD
        );
      case 5:
        return TentangSection(
          initialProfile: _profile,
          onDataChanged: _loadAll, // ← callback setelah CRUD
        );
      default:
        return Center(
          child: Text(
            _sidebarItems[_selectedIndex].label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          color: context.bgOuter,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Stack(
          children: [
            Container(
              height: 200,
              alignment: Alignment.center,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: BoxDecoration(color: context.bgCard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'siap_bantu.ready_help_mode'.tr(),
                        style: TextStyle(
                          color: context.primary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    textAlign: TextAlign.center,
                    !(_profile?.isProfileComplete ?? false)
                        ? 'siap_bantu.profile_not_already'.tr()
                        : !(_profile?.isAvailable ?? false)
                        ? 'siap_bantu.profile_complete_not_active'.tr()
                        : 'siap_bantu.profil_already_complete'.tr(),
                    style: TextStyle(color: context.black87, fontSize: 13),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            // ── Body: Sidebar + Content ──
            Container(
              padding: EdgeInsets.only(top: 180),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Sidebar
                  Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: context.bgContent,
                      border: Border(
                        right: BorderSide(
                          color: context.divider, // ← garis tipis pemisah
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: context.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: _sidebarItems.length,
                      itemBuilder: (context, index) {
                        final item = _sidebarItems[index];
                        final isActive = _selectedIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = index),
                          child: Container(
                            height: 78,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? context.primary.withOpacity(0.1)
                                  : context.transparent,

                              border: Border(
                                left: BorderSide(
                                  color: isActive
                                      ? context.primary
                                      : context.transparent,
                                  width: 3,
                                ),
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: index == 0
                                    ? Radius.circular(24)
                                    : Radius.zero,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      item.icon,
                                      size: 22,
                                      color: isActive
                                          ? context.primary
                                          : context.textSecondary,
                                    ),
                                    if (index == 4) // hanya di Status
                                      Positioned(
                                        top: -2,
                                        right: -4,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                !(_profile?.isProfileComplete ??
                                                    false)
                                                ? Colors.red
                                                : !(_profile?.isAvailable ??
                                                      false)
                                                ? Colors.orange
                                                : Colors.green,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isActive
                                        ? context.primary
                                        : context.textSecondary,
                                    fontWeight: isActive
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Right Content
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.bgContent,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: context.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Helper model
// ─────────────────────────────────────────
class _SidebarItem {
  final IconData icon;
  final String label;
  const _SidebarItem({required this.icon, required this.label});
}
