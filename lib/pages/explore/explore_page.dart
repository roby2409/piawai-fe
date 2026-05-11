import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';

import 'cari_bantuan/detail_pekerja_page.dart';
import 'cari_bantuan/map_page.dart';
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
      backgroundColor: kPrimary, // background gelap
      body: SafeArea(
        child: Stack(
          children: [
            // ── Content ──
            // Positioned.fill(
            //   child: TabBarView(
            //     controller: _tabController,
            //     children: [MapPage(), SiapBantuPage()],
            //   ),
            // ),

            // ── Tab Bar ──
            // Ganti TabBar dengan ini
            TabBarView(
              controller: _tabController,
              children: [MapPage(), SiapBantuPage()],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: kSecondary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(26),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Color(0xFF04a5ba),
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Cari Bantuan'),
                  Tab(text: 'Siap Bantu'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
