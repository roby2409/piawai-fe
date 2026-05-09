import 'package:flutter/material.dart';
import 'package:piawai/pages/auth/auth_screen.dart';
import 'package:piawai/services/auth_services.dart';

// ─────────────────────────────────────────
// PENGATURAN PAGE
// ─────────────────────────────────────────
class PengaturanPage extends StatefulWidget {
  const PengaturanPage({super.key});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
              ;
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Pengaturan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
