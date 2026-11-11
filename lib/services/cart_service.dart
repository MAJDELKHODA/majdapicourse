import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Model/cart_model.dart';

class CartService {
  final String baseUrl = 'https://tullana.toldpath.com/api';

  // =========================
  // ADD TO CART
  // =========================

  Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/customer/cart/add',
    );

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields.addAll({
      'product_id': productId.toString(),
      'quantity': quantity.toString(),
    });

    final streamedResponse = await request.send();

    final responseBody =
    await streamedResponse.stream.bytesToString();

    if (responseBody.isEmpty) {
      throw Exception(
        'Empty response from server',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(responseBody);

    return data;
  }

  // =========================
  // GET CART
  // =========================

  Future<CartResponse> getCart({
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/customer/cart',
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

      final status = data['status'];

      if (status == true ||
          status == 1 ||
          data['cart'] != null) {
        return CartResponse.fromJson(data);
      }

      throw Exception(
        data['message']?.toString() ??
            'Failed to load cart',
      );
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Session expired. Please login again.',
      );
    }

    throw Exception(
      'Failed to load cart. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // UPDATE CART ITEM
  // =========================

  Future<Map<String, dynamic>> updateCartItem({
    required int cartId,
    required int quantity,
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/customer/cart/update',
    );

    final response = await http.put(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'key': cartId.toString(),
        'quantity': quantity,
      }),
    );

    if (response.body.isEmpty) {
      throw Exception(
        'Empty response from server',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return data;
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Session expired. Please login again.',
      );
    }

    throw Exception(
      data['message']?.toString() ??
          'Failed to update cart item',
    );
  }

  // =========================
  // REMOVE ITEM
  // =========================

  Future<Map<String, dynamic>> removeItem({
    required int cartId,
    required String token,
  }) async {
    final url = Uri.parse(
      '$baseUrl/customer/cart/remove',
    );

    final response = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'key': cartId,
      }),
    );

    if (response.body.isEmpty) {
      throw Exception(
        'Empty response from server',
      );
    }

    final Map<String, dynamic> data =
    jsonDecode(response.body);

    if (response.statusCode == 200 ||
        response.statusCode == 201) {
      return data;
    }

    if (response.statusCode == 401) {
      throw Exception(
        'Session expired. Please login again.',
      );
    }

    throw Exception(
      data['message']?.toString() ??
          'Failed to remove item',
    );
  }
}