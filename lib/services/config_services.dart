import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:piawai/core/auth_handler.dart';
import 'package:piawai/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      handleUnauthorized();
      throw Exception('Unauthorized');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    throw Exception(data['message'] ?? 'Terjadi kesalahan');
  }

  Future<Map<String, dynamic>> getConfig() async {
    final response = await http.get(
      Uri.parse('$baseUrl/app-config'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getConfigKeys() async {
    final response = await http.get(
      Uri.parse('$baseUrl/app-config/keys'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data['data'] as Map<String, dynamic>;
  }
}
