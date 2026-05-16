// ─────────────────────────────────────────
// Profile Page (unchanged structure, updated styling)
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/core/helper.dart';

import 'models/worker_model.dart';

class ProfilePage extends StatelessWidget {
  final WorkerExploreModel worker;
  const ProfilePage({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profil Pekerja',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPrimary, width: 3),
              ),
              child: ClipOval(
                child: worker.avatarUrl != null
                    ? Image.network(
                        imageUrl(worker.avatarUrl!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(
                            '👨',
                            style: const TextStyle(fontSize: 40),
                          ),
                        ),
                      )
                    : Center(
                        child: Text('👨', style: const TextStyle(fontSize: 40)),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              worker.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              worker.services.join(', '),
              style: const TextStyle(
                color: kPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${worker.age} thn',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _InfoCard(worker: worker),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.phone_outlined),
                label: Text(
                  'Hubungi ${worker.fullName.split(' ').first}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final WorkerExploreModel worker;
  const _InfoCard({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Nomor HP',
            value: "0872387",
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.work_outline,
            label: 'Pengalaman',
            value: worker.bio ?? 'Belum ada pengalaman yang ditambahkan',
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Harga',
            value: worker.minHargaHari != null
                ? 'Rp ${worker.minHargaHari} / hari'
                : 'Harga belum tersedia',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: kPrimary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
