import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:piawai/services/auth_services.dart';

import 'core/constants.dart';
import 'pages/auth/auth_screen.dart';
import 'pages/main_page.dart';
import 'pages/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ← wajib kalau ada async di main
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ← tambah ini
      debugShowCheckedModeBanner: false,
      title: 'Piawai',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme(), // ← semua text pakai Poppins
      ),
      home: const _AuthGate(),
    );
  }
}

// ─────────────────────────────────────────
// AUTH GATE — cek session saat app buka
// ─────────────────────────────────────────
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  // Di _AuthGate, update bagian onboarding:
  Future<void> _checkSession() async {
    final auth = AuthService();
    final onboardingDone = await auth.isOnboardingDone();

    if (!mounted) return; // ← cek mounted setelah setiap await

    if (!onboardingDone) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OnboardingScreen(
            onFinish: () async {
              await auth.setOnboardingDone();
              // ← JANGAN pakai context dari sini, pakai navigatorKey
              navigatorKey.currentState?.pushReplacement(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    final isLoggedIn = await auth.isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => isLoggedIn ? const MainPage() : const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Splash screen sementara nunggu cek session
    return const Scaffold(
      backgroundColor: kBgOuter,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
