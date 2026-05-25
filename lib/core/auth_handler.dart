import 'package:flutter/material.dart';
import 'package:piawai/main.dart';
import 'package:piawai/pages/auth/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> handleUnauthorized() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const AuthScreen()),
    (route) => false,
  );
}
