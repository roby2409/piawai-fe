import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/explore/siap_bantu/models/worker_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerService {
  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data['data']; // bisa null (misal delete), bisa Map, bisa List
    }
    print('createService status: ${response.statusCode}');
    throw Exception(data['message'] ?? 'Terjadi kesalahan');
  }

  // ═══════════════════════════════════════════════════════════════
  // PROFILE — fetch semua data sekaligus (untuk initial load)
  // ═══════════════════════════════════════════════════════════════

  Future<WorkerProfileModel> fetchProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return WorkerProfileModel.fromJson(data);
  }

  Future<WorkerProfileModel> fetchOtherProfile(String username) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/$username'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return WorkerProfileModel.fromJson(data);
  }

  Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> uploadAvatar(Uint8List imageBytes) async {
    final uri = Uri.parse('$baseUrl/profile/avatar');
    final headers = await _authHeaders();

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile.fromBytes(
          'avatar', // ← nama field harus sama dengan PHP
          imageBytes,
          filename: 'avatar.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  // ═══════════════════════════════════════════════════════════════
  // LAYANAN — CRUD
  // ═══════════════════════════════════════════════════════════════

  Future<List<Map<String, dynamic>>> fetchServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/services'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> createService(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/profile/services'),
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateService(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile/services/$id'),
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );
    return _handleResponse(response);
  }

  Future<void> deleteService(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/profile/services/$id'),
      headers: await _authHeaders(),
    );
    _handleResponse(response); // data null, tapi tetap cek statusCode
  }

  // ═══════════════════════════════════════════════════════════════
  // KONTAK
  // ═══════════════════════════════════════════════════════════════

  Future<Map<String, dynamic>> updateKontak(
    Map<String, dynamic> payload,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/contact'),
      headers: await _authHeaders(),
      body: jsonEncode(payload),
    );
    return _handleResponse(response);
  }
}
