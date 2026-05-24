import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/core/app_colors.dart';
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
      backgroundColor: context.bgOuter,
      body: SafeArea(
        child: Stack(
          children: [
            TabBarView(
              controller: _tabController,
              children: [MapPage(), SiapBantuPage()],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.bgContent,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: context.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: context.primary,
                  borderRadius: BorderRadius.circular(26),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: context.transparent,
                labelColor: context.white,
                unselectedLabelColor: context.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: [
                  Tab(text: 'cari_bantuan.title'.tr()),
                  Tab(text: 'siap_bantu.title'.tr()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
