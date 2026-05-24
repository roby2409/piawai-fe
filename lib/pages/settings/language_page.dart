import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:piawai/core/app_colors.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'flag': '🇺🇸', 'key': 'language.english'},
    {'code': 'id', 'flag': '🇮🇩', 'key': 'language.indonesia'},
    {'code': 'ar', 'flag': '🇸🇦', 'key': 'language.arabic'},
    {'code': 'hi', 'flag': '🇮🇳', 'key': 'language.hindi'},
  ];

  List<Map<String, String>> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _languages;
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _languages.where((lang) {
        return lang['key']!.tr().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentCode = context.locale.languageCode;

    return Scaffold(
      backgroundColor: context.bgOuter,
      appBar: AppBar(
        backgroundColor: context.bgContent,
        title: Text(
          'language.title'.tr(),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'language.search_hint'.tr(),
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Language list
            Container(
              decoration: BoxDecoration(
                color: context.bgCard,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 56),
                itemBuilder: (context, index) {
                  final lang = _filtered[index];
                  final isSelected = lang['code'] == currentCode;

                  return ListTile(
                    onTap: () {
                      // ← INI YANG GANTI BAHASA, cukup 1 baris!
                      context.setLocale(Locale(lang['code']!)); // set dulu
                      Navigator.pop(context);
                    },
                    leading: Text(
                      lang['flag']!,
                      style: const TextStyle(fontSize: 28),
                    ),
                    title: Text(
                      lang['key']!.tr(),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle_outline,
                            color: Color(0xFF25D366),
                          )
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
