import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:piawai/core/constants.dart';
import 'package:piawai/pages/explore/cari_bantuan/models/explore_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreService {
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

  Future<ExploreModel> fetchWorkerExplore({
    required double lat,
    required double lng,
    double radius = 5,
    String? q,
    String? gender,
    int? ageMin,
    int? ageMax,
  }) async {
    // Build query params — hanya tambahkan yang tidak null
    final queryParams = <String, String>{
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radius': radius.toString(),
      if (q != null && q.isNotEmpty) 'q': q,
      if (gender != null && gender != 'Semua') 'gender': gender,
      if (ageMin != null) 'age_min': ageMin.toString(),
      if (ageMax != null) 'age_max': ageMax.toString(),
    };

    final uri = Uri.parse(
      '$baseUrl/explore',
    ).replace(queryParameters: queryParams);
    debugPrint('fetchWorkerExplore with params: $uri');

    final response = await http.get(uri, headers: await _authHeaders());
    final data = _handleResponse(response);
    return ExploreModel.fromJson(data);
  }

  // Tambah method ini di ExploreService

  Future<List<String>> fetchSuggestions({String q = '', int limit = 8}) async {
    final queryParams = <String, String>{
      if (q.isNotEmpty) 'q': q,
      'limit': limit.toString(),
    };

    final uri = Uri.parse(
      '$baseUrl/explore/suggest',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: await _authHeaders());
    final data = _handleResponse(response);

    // Response: { "suggestions": ["Tukang Cuci", "Tukang Listrik", ...] }
    final list = data['suggestions'] as List<dynamic>? ?? [];
    return list.map((e) => e.toString()).toList();
  }
}
