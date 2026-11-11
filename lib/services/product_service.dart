import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Model/product_model.dart';

class ProductService {
  final String baseUrl =
      'https://tullana.toldpath.com/api';

  // =========================
  // GET PRODUCTS
  // =========================
  //
  // إذا ما مررنا categoryId:
  // يرجع منتجات المتجر الرئيسي 265
  //
  // إذا مررنا categoryId:
  // يرجع منتجات التصنيف المحدد
  //

  Future<List<ProductModel>> getProducts({
    int categoryId = 265,
  }) async {
    final url = Uri.parse(
      '$baseUrl/customer/categories/products/$categoryId',
    );

    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
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

        return productsJson
            .map(
              (product) =>
              ProductModel.fromJson(
                Map<String, dynamic>.from(
                  product,
                ),
              ),
        )
            .toList();
      } else {
        throw Exception(
          data['message']?.toString() ??
              'Failed to load products',
        );
      }
    }

    throw Exception(
      'Failed to load products. Status code: ${response.statusCode}',
    );
  }

  // =========================
  // MAIN STORE PRODUCTS
  // =========================

  Future<List<ProductModel>>
  getStoreProducts() {
    return getProducts(
      categoryId: 265,
    );
  }

  // =========================
  // RINGS
  // =========================

  Future<List<ProductModel>>
  getRings() {
    return getProducts(
      categoryId: 268,
    );
  }

  // =========================
  // NECKLACES
  // =========================

  Future<List<ProductModel>>
  getNecklaces() {
    return getProducts(
      categoryId: 267,
    );
  }

  // =========================
  // BRACELETS & BANGLES
  // =========================

  Future<List<ProductModel>>
  getBracelets() {
    return getProducts(
      categoryId: 266,
    );
  }
}