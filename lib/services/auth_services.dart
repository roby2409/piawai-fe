import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:piawai/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // ── Google Sign In instance ──────────────────────────────────────────────
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '970494615255-5itcbkk4o6o68pleo5ur4u0j1us10oem.apps.googleusercontent.com',
  );

  // ── Email Login ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(
    String emailOrUsername,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email_or_username': emailOrUsername,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await _saveSession(data['data']);
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Login gagal');
    }
  }

  // ── Email Register ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Registrasi gagal');
    }
  }

  // ── Google Sign In ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Login Google dibatalkan');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception(
        'Gagal mendapatkan idToken. Pastikan serverClientId sudah benar.',
      );
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id_token': idToken}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _saveSession(data['data']);
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'Google login gagal');
    }
  }

  // ── Forgot Password ──────────────────────────────────────────────────────

  Future<void> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal mengirim OTP');
    }
  }

  // ── Verify OTP ───────────────────────────────────────────────────────────

  Future<String> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['data']['reset_token'] as String;
    } else {
      throw Exception(data['message'] ?? 'OTP tidak valid');
    }
  }

  // ── Reset Password ───────────────────────────────────────────────────────

  Future<void> resetPassword(
    String resetToken,
    String password,
    String passwordConfirmation,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/reset-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $resetToken',
      },
      body: jsonEncode({
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Gagal reset password');
    }
  }

  // ── Logout ───────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token'] ?? '');
    await prefs.setString('token_expired_at', data['token_expired_at'] ?? '');
    await prefs.setInt('user_id', data['user_id'] ?? 0);
    await prefs.setString('email', data['email'] ?? '');
    if (data['profile'] != null) {
      await prefs.setString('profile', jsonEncode(data['profile']));
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final expiredAt = prefs.getString('token_expired_at');

    if (token == null || token.isEmpty) return false;

    if (expiredAt != null && expiredAt.isNotEmpty) {
      final expiry = DateTime.tryParse(expiredAt);
      if (expiry != null && DateTime.now().isAfter(expiry)) {
        await prefs.clear();
        return false;
      }
    }

    return true;
  }

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_done') ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
  }
}
