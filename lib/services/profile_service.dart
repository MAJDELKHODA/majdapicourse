import 'dart:convert';

import 'package:http/http.dart' as http;

class ProfileService {
  final String baseUrl =
      'https://tullana.toldpath.com/api';

  // =========================
  // GET PROFILE
  // =========================

  Future<Map<String, dynamic>> getProfile({
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/customer/profile/info',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.body.isEmpty) {
      throw Exception(
        'Empty response from server',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data['status'] == true ||
          data['status'] == 1) {
        return Map<String, dynamic>.from(
          data['user'] ?? {},
        );
      }

      throw Exception(
        data['message']?.toString() ??
            'Failed to load profile',
      );
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Session expired. Please login again.',
      );
    }

    throw Exception(
      'Failed to load profile. Status code: ${response.statusCode}',
    );
  }
}