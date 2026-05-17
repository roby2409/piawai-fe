import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'explore/explore_page.dart';
import 'settings/pengaturan_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  int _historyRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    return Scaffold(
      body: // MainPage
      IndexedStack(
        index: _currentIndex,
        children: [
          ExplorePage(
            key: ValueKey('history_${locale.languageCode}_$_historyRefreshKey'),
          ),
          PengaturanPage(key: ValueKey(locale.languageCode)),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          elevation: 0, // ← matiin shadow default, pakai shadow dari Container
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              if (index == 1)
                _historyRefreshKey++; // ← increment tiap buka history
              _currentIndex = index;
            });
          },
          selectedItemColor: kPrimary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Eksplor',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
