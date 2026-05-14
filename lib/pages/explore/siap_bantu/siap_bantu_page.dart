import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
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

  final List<_SidebarItem> _sidebarItems = const [
    _SidebarItem(icon: Icons.person_outline, label: 'Profil'),
    _SidebarItem(icon: Icons.phone_outlined, label: 'Kontak'),
    _SidebarItem(icon: Icons.work_outline, label: 'Layanan'),
    _SidebarItem(icon: Icons.location_on_outlined, label: 'Area'),
    _SidebarItem(icon: Icons.wifi, label: 'Status'),
    _SidebarItem(icon: Icons.info_outline, label: 'Tentang'),
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
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
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
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Stack(
          children: [
            Container(
              height: 180,
              alignment: Alignment.center,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              decoration: const BoxDecoration(color: Color(0xFF0d1b3e)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Mode Siap Bantu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Anda terdaftar sebagai penyedia jasa',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
            // ── Body: Sidebar + Content ──
            Container(
              padding: EdgeInsets.only(top: 160),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Sidebar
                  Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade200, // ← garis tipis pemisah
                          width: 1,
                        ),
                      ),
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
                                  ? const Color(0xFFE0F7F5)
                                  : Colors.transparent,

                              border: Border(
                                left: BorderSide(
                                  color: isActive
                                      ? kPrimary
                                      : Colors.transparent,
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
                                Icon(
                                  item.icon,
                                  size: 22,
                                  color: isActive
                                      ? kPrimary
                                      : Color(0xff9E9E9E),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isActive ? kPrimary : Colors.grey,
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(24),
                        ),
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
