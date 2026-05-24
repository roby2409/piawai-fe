import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:piawai/core/app_theme.dart';
import 'package:piawai/services/auth_services.dart';
import 'package:piawai/services/theme_service.dart';

import 'core/constants.dart';
import 'pages/auth/auth_screen.dart';
import 'pages/main_page.dart';
import 'pages/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ThemeService().init();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('id'),
        Locale('ar'),
        Locale('hi'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: ChangeNotifierProvider<ThemeService>(
        create: (_) => ThemeService(),
        child: const MyApp(),
      ),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        return MaterialApp(
          scaffoldMessengerKey: scaffoldMessengerKey,
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: 'Piawai',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const _AuthGate(),
        );
      },
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
