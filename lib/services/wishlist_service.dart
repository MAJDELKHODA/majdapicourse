import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Model/product_model.dart';

class WishlistService {
  final String baseUrl =
      'https://tullana.toldpath.com/api';

  // =========================
  // GET WISHLIST
  // =========================

  Future<List<ProductModel>> getWishlist({
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/customer/favorites',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data =
      jsonDecode(response.body);

      if (data['status'] == true ||
          data['status'] == 1) {
        final List productsJson =
        data['data'] is List
            ? data['data']
            : [];

        final products = productsJson
            .map(
              (item) =>
              ProductModel.fromJson(
                Map<String, dynamic>.from(
                  item,
                ),
              ),
        )
            .toList();
        // ترجع كل المنتجات المفضله سواء من متجري او غيرو لو بدي من متجري بنعمل فلتره

        return products;
      }

      throw Exception(
        data['message']?.toString() ??
            'Failed to load wishlist',
      );
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Session expired. Please login again.',
      );
    }

    throw Exception(
      'Failed to load wishlist. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // ADD TO WISHLIST
  // =========================

  Future<Map<String, dynamic>> addToWishlist({
    required int productId,
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/customer/favorites/add',
    );

    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'product_id': productId,
      }),
    );

    if (response.body.isEmpty) {
      throw Exception(
        'Empty response from server',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    return data;
  }

  // =========================
  // REMOVE FROM WISHLIST
  // =========================

  Future<Map<String, dynamic>>
  removeFromWishlist({
    required int productId,
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/customer/favorites/remove',
    );

    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'product_id': [
          productId,
        ],
      }),
    );

    if (response.body.isEmpty) {
      throw Exception(
        'Empty response from server',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    return data;
  }
}