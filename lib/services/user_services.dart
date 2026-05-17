import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:piawai/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
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
      return data;
    }
    throw Exception(data['message'] ?? 'Terjadi kesalahan');
  }

  // GET /user/me → ambil info akun + has_password
  Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/me'),
      headers: await _authHeaders(),
    );
    final data = _handleResponse(response);
    return data['data'] as Map<String, dynamic>;
  }

  // PUT /user/username
  Future<void> updateUsername(String username) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/username'),
      headers: await _authHeaders(),
      body: jsonEncode({'username': username}),
    );
    _handleResponse(response);
  }

  // PUT /user/password
  // oldPassword null → Google user (first time set password)
  Future<void> updatePassword({
    String? oldPassword,
    required String newPassword,
  }) async {
    final body = <String, String>{'new_password': newPassword};
    if (oldPassword != null && oldPassword.isNotEmpty) {
      body['old_password'] = oldPassword;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/user/password'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    _handleResponse(response);
  }
}
