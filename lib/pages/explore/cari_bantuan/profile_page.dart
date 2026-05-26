import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:piawai/core/app_colors.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:piawai/services/worker_services.dart';
import 'models/worker_model.dart';

class ProfilePage extends StatefulWidget {
  final WorkerExploreModel worker;
  const ProfilePage({super.key, required this.worker});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedTab = 0;
  WorkerProfileModel? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await WorkerService().fetchOtherProfile(
        widget.worker.username,
      );
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgOuter,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _loadProfile();
                    },
                    child: Text('general.retry'.tr()),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        backgroundColor: context.bgContent,
                        elevation: 0,
                        pinned: true,
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back, color: context.black87),
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                        title: Text(
                          'general.worker_detail'.tr(),
                          style: TextStyle(
                            color: context.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: Icon(
                              Icons.share_outlined,
                              color: context.black87,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildProfileSection(),
                            const SizedBox(height: 20),
                            if (_profile!.services.isNotEmpty)
                              _buildServiceSection(),
                            const SizedBox(height: 20),
                            if (_profile!.bio != null) _buildAboutSection(),
                            const SizedBox(height: 20),
                            if (_profile!.areaLabel != null)
                              _buildAreaSection(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_profile!.phoneWa != null) _buildBottomButton(),
              ],
            ),
    );
  }

  Widget _buildProfileSection() {
    final profile = _profile!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 90,
              height: 110,
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: profile.avatarUrl != null
                  ? Image.network(profile.avatarUrl!, fit: BoxFit.cover)
                  : Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: context.blue,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: context.primary.withOpacity(0.85),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (profile.gender != null)
                      Icon(
                        profile.gender == 'Wanita' ? Icons.female : Icons.male,
                        color: profile.gender == 'Wanita'
                            ? const Color(0xFFFF4081)
                            : const Color(0xFFFFC107),
                        size: 16,
                      ),
                    const SizedBox(width: 4),
                    Text(
                      [
                        if (profile.gender != null) profile.gender!,
                        if (profile.age != null)
                          'general.age_display'.tr(args: ['${profile.age}']),
                      ].join(' • '),
                      style: TextStyle(fontSize: 13, color: context.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatChip(
                      Icons.check_circle_outline,
                      '${profile.services.length}',
                      'service'.tr(),
                    ),
                    const SizedBox(width: 10),
                    _buildStatChip(
                      Icons.location_on_outlined,
                      'general.radius_display'.tr(
                        args: ['${profile.radiusKm}'],
                      ),
                      'general.radius'.tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.primary),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.black87,
                ),
              ),
              Text(label, style: TextStyle(color: context.black45)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSection() {
    final services = _profile!.services;
    final selected = services[_selectedTab];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'general.services_offered'.tr(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: context.black45,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Tab Bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(services.length, (index) {
              final isSelected = _selectedTab == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? context.primary : context.bgContent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? context.primary : context.divider,
                    ),
                  ),
                  child: Text(
                    services[index].nama,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? context.white : context.black54,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 14),

        // Service Description Card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.black87),
          ),
          child: Text(
            selected.deskripsi ?? "",
            style: TextStyle(
              fontSize: 13.5,
              color: context.black87,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'about_me'.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _profile!.bio!,
            style: TextStyle(
              fontSize: 13.5,
              color: context.black54,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'siap_bantu.area_services'.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 14, color: context.primary),
                const SizedBox(width: 6),
                Text(
                  _profile!.areaLabel!,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: context.bgContent,
        boxShadow: [
          BoxShadow(
            color: context.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: launch WhatsApp with _profile!.phoneWa
          },
          icon: Icon(Icons.chat, size: 20),
          label: Text(
            'general.whatsapp'.tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}
