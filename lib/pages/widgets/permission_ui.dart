// ─────────────────────────────────────────
// Profile Page (unchanged structure, updated styling)
// ─────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:piawai/core/constants.dart';

class PermissionUI extends StatelessWidget {
  final bool isDeniedForever;
  final VoidCallback onRequest;

  const PermissionUI({
    super.key,
    required this.isDeniedForever,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.location_off_outlined,
                  size: 64,
                  color: kPrimary,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Izin Lokasi Diperlukan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                isDeniedForever
                    ? 'Izin lokasi ditolak permanen. Buka pengaturan untuk mengaktifkan.'
                    : 'Aplikasi butuh akses lokasi untuk menampilkan pekerja di sekitar Anda.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isDeniedForever
                      ? () => Geolocator.openAppSettings()
                      : onRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isDeniedForever
                        ? 'Buka Pengaturan'
                        : 'Izinkan Akses Lokasi',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
