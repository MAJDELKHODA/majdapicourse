class CartItem {
  final int id;
  final int productId;
  final int quantity;
  final String thumbnail;
  final String productName;
  final String formattedPrice;

  CartItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.thumbnail,
    required this.productName,
    required this.formattedPrice,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    String formattedPrice = '0.00 KWD';

    final gulfPrices = json['gulf_prices'];

    if (gulfPrices is List && gulfPrices.isNotEmpty) {
      final firstPrice = gulfPrices.first;

      if (firstPrice is Map<String, dynamic>) {
        formattedPrice =
            firstPrice['formatted_price']?.toString() ?? '0.00 KWD';
      }
    }

    final product = json['product'] is Map<String, dynamic>
        ? json['product'] as Map<String, dynamic>
        : <String, dynamic>{};

    return CartItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      thumbnail: json['thumbnail']?.toString() ?? '',
      productName: product['name']?.toString() ?? '',
      formattedPrice: formattedPrice,
    );
  }
}

class CartDetails {
  final double subTotal;
  final double tax;
  final double deliveryFee;
  final double totalDiscount;
  final double totalCost;

  CartDetails({
    required this.subTotal,
    required this.tax,
    required this.deliveryFee,
    required this.totalDiscount,
    required this.totalCost,
  });

  factory CartDetails.fromJson(Map<String, dynamic> json) {
    return CartDetails(
      subTotal: double.tryParse(
        json['sub_total']?.toString() ?? '0',
      ) ??
          0,
      tax: double.tryParse(
        json['tax']?.toString() ?? '0',
      ) ??
          0,
      deliveryFee: double.tryParse(
        json['delivery_fee']?.toString() ?? '0',
      ) ??
          0,
      totalDiscount: double.tryParse(
        json['total_discount']?.toString() ?? '0',
      ) ??
          0,
      totalCost: double.tryParse(
        json['total_cost']?.toString() ?? '0',
      ) ??
          0,
    );
  }
}

class CartResponse {
  final List<CartItem> items;
  final CartDetails details;

  CartResponse({
    required this.items,
    required this.details,
  });

  factory CartResponse.fromJson(Map<String, dynamic> json) {
    final cartJson = json['cart'] is List
        ? json['cart'] as List
        : [];

    final cartDetailsJson =
    json['cart_details'] is Map<String, dynamic>
        ? json['cart_details'] as Map<String, dynamic>
        : <String, dynamic>{};

    return CartResponse(
      items: cartJson
          .map(
            (item) => CartItem.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList(),
      details: CartDetails.fromJson(cartDetailsJson),
    );
  }
}