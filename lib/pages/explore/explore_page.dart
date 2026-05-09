import 'package:flutter/material.dart';

import 'cari_bantuan/detail_pekerja_page.dart';
import 'siap_bantu/siap_bantu_page.dart';

// ─────────────────────────────────────────
// EXPLORE PAGE — 2 tab swipeable
// ─────────────────────────────────────────
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1b3e), // background gelap
      body: SafeArea(
        child: Column(
          children: [
            // ── Tab Bar ──
            // Ganti TabBar dengan ini
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15), // background pill
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF1a56db), // active pill biru
                  borderRadius: BorderRadius.circular(26),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                tabs: const [
                  Tab(text: 'Cari Bantuan'),
                  Tab(text: 'Siap Bantu'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Content ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1 — Cari Bantuan (nanti diganti)
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailPekerjaPage(
                              pekerja: PekerjaDetail(
                                nama: 'Budi Santoso',
                                jenisKelamin: 'Pria',
                                usia: 34,
                                fotoUrl: null,
                                tentang:
                                    'Spesialis teknisi listrik bersertifikat...',
                                noWa: '6281234567890',
                                area: 'Jakarta Selatan & Sekitarnya',
                                layananList: [
                                  LayananDetail(
                                    nama: 'Instalasi Listrik',
                                    hargaJam: 'Rp 50.000',
                                    hargaHari: 'Rp 350.000',
                                    hargaProyek: 'Rp 500.000',
                                  ),
                                  LayananDetail(
                                    nama: 'Service AC',
                                    hargaJam: 'Rp 75.000',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Cari Bantuan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Tab 2 — Siap Bantu dengan rounded card
                  SiapBantuPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
