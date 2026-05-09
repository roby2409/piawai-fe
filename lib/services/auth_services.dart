import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://192.168.18.35/apigoogle/auth';

  // ── Google Sign In instance ──────────────────────────────────────────────
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '970494615255-5itcbkk4o6o68pleo5ur4u0j1us10oem.apps.googleusercontent.com',
  );

  // ── Email Login ──────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
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
      Uri.parse('$baseUrl/register'),
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
    // 1. Tampilkan dialog pilih akun Google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('Login Google dibatalkan');
    }

    // 2. Ambil idToken
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final String? idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception(
        'Gagal mendapatkan idToken. Pastikan serverClientId sudah benar.',
      );
    }

    // 3. Kirim idToken ke PHP backend
    final response = await http.post(
      Uri.parse('$baseUrl/google'),
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
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
