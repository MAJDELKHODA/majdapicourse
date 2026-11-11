class ChoiceOption {
  final int id;
  final String name;
  final List<String> options;

  ChoiceOption({
    required this.id,
    required this.name,
    required this.options,
  });

  factory ChoiceOption.fromJson(Map<String, dynamic> json) {
    return ChoiceOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      options: (json['options'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
    );
  }
}

class ProductVariation {
  final String type;
  final double price;
  final String sku;
  final int qty;

  ProductVariation({
    required this.type,
    required this.price,
    required this.sku,
    required this.qty,
  });

  factory ProductVariation.fromJson(Map<String, dynamic> json) {
    return ProductVariation(
      type: json['type']?.toString() ?? '',
      price: double.tryParse(
        json['price']?.toString() ?? '0',
      ) ??
          0,
      sku: json['sku']?.toString() ?? '',
      qty: int.tryParse(
        json['qty']?.toString() ?? '0',
      ) ??
          0,
    );
  }
}

class ProductModel {
  final int id;
  final String code;
  final String name;
  final String shortDescription;
  final String details;
  final String thumbnail;

  final double price;
  final String formattedPrice;

  final int currentStock;
  final int totalStock;
  final String stockStatus;

  final bool isFavorite;

  final bool hasVariations;
  final List<ChoiceOption> choiceOptions;
  final List<ProductVariation> variations;

  ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.shortDescription,
    required this.details,
    required this.thumbnail,
    required this.price,
    required this.formattedPrice,
    required this.currentStock,
    required this.totalStock,
    required this.stockStatus,
    required this.isFavorite,
    required this.hasVariations,
    required this.choiceOptions,
    required this.variations,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    double productPrice = 0;
    String formattedProductPrice = '0.00 KWD';

    final unitPrice = json['unit_price'];

    if (unitPrice is List && unitPrice.isNotEmpty) {
      final priceData = unitPrice.first;

      if (priceData is Map<String, dynamic>) {
        productPrice = double.tryParse(
          priceData['price']?.toString() ?? '0',
        ) ??
            0;

        formattedProductPrice =
            priceData['formatted_price']?.toString() ??
                '${productPrice.toStringAsFixed(2)} KWD';
      }
    }

    final choiceOptionsJson =
        json['choice_options'] as List? ?? [];

    final variationsJson =
        json['variations'] as List? ?? [];

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      shortDescription:
      json['short_description']?.toString() ?? '',
      details: json['details']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      price: productPrice,
      formattedPrice: formattedProductPrice,
      currentStock:
      (json['current_stock'] as num?)?.toInt() ?? 0,
      totalStock:
      (json['total_stock'] as num?)?.toInt() ?? 0,
      stockStatus:
      json['availability_instock']?.toString() ?? '',
      isFavorite: json['is_favorite'] == true,
      hasVariations: json['has_variations'] == true,
      choiceOptions: choiceOptionsJson
          .map(
            (item) => ChoiceOption.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
      variations: variationsJson
          .map(
            (item) => ProductVariation.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}