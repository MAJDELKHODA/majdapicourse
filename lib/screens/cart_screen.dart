import 'package:flutter/material.dart';

import '../Model/cart_model.dart';
import '../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  final String token;

  const CartScreen({
    super.key,
    required this.token,
  });

  @override
  State<CartScreen> createState() =>
      _CartScreenState();
}

class _CartScreenState
    extends State<CartScreen> {
  final CartService cartService =
  CartService();

  late Future<CartResponse> cartFuture;

  int? deletingCartId;
  int? updatingCartId;

  static const Color primaryYellow =
  Color(0xFFF5C542);

  static const Color darkColor =
  Color(0xFF111111);

  static const Color backgroundColor =
  Color(0xFFF7F7F7);

  static const Color greyColor =
  Color(0xFF777777);

  @override
  void initState() {
    super.initState();

    loadCart();
  }

  void loadCart() {
    cartFuture = cartService.getCart(
      token: widget.token,
    );
  }

  Future<void> refreshCart() async {
    setState(() {
      loadCart();
    });

    await cartFuture;
  }

  // =========================
  // UPDATE QUANTITY
  // =========================

  Future<void> updateQuantity({
    required CartItem item,
    required int newQuantity,
  }) async {
    if (updatingCartId != null) {
      return;
    }

    if (newQuantity < 1) {
      return;
    }

    setState(() {
      updatingCartId = item.id;
    });

    try {
      final result =
      await cartService.updateCartItem(
        cartId: item.id,
        quantity: newQuantity,
        token: widget.token,
      );

      if (!mounted) return;

      final status = result['status'];

      debugPrint(
        'UPDATE CART RESULT: $result',
      );

      if (status == true ||
          status == 1) {
        setState(() {
          loadCart();
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              result['message']
                  ?.toString() ??
                  'Quantity updated successfully',
            ),
            backgroundColor:
            Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              result['message']
                  ?.toString() ??
                  'Could not update quantity',
            ),
            backgroundColor:
            Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
          backgroundColor:
          Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          updatingCartId = null;
        });
      }
    }
  }

  // =========================
  // CONFIRM DELETE
  // =========================

  Future<void> confirmRemoveItem(
      CartItem item,
      ) async {
    final bool? confirm =
    await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
          Colors.white,

          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(
              20,
            ),
          ),

          title: const Text(
            'Remove Item',
            style: TextStyle(
              color: darkColor,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          content: Text(
            'Are you sure you want to remove "${item.productName}" from your cart?',
            style: const TextStyle(
              color: greyColor,
              height: 1.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
              const Text(
                'Cancel',
                style: TextStyle(
                  color: greyColor,
                  fontWeight:
                  FontWeight
                      .w700,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },

              style:
              ElevatedButton
                  .styleFrom(
                backgroundColor:
                Colors.red,
                foregroundColor:
                Colors.white,
                elevation: 0,
              ),

              child:
              const Text(
                'Remove',
                style: TextStyle(
                  fontWeight:
                  FontWeight
                      .w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await removeItem(item);
    }
  }

  // =========================
  // DELETE ITEM
  // =========================

  Future<void> removeItem(
      CartItem item,
      ) async {
    if (deletingCartId != null) {
      return;
    }

    setState(() {
      deletingCartId = item.id;
    });

    try {
      final result =
      await cartService.removeItem(
        cartId: item.id,
        token: widget.token,
      );

      if (!mounted) return;

      final status = result['status'];

      if (status == true ||
          status == 1) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              result['message']
                  ?.toString() ??
                  'Item removed successfully',
            ),
            backgroundColor:
            Colors.green,
          ),
        );

        setState(() {
          loadCart();
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              result['message']
                  ?.toString() ??
                  'Could not remove item',
            ),
            backgroundColor:
            Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
          ),
          backgroundColor:
          Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          deletingCartId = null;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      backgroundColor,

      appBar: AppBar(
        backgroundColor:
        backgroundColor,
        foregroundColor:
        darkColor,
        elevation: 0,

        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body:
      FutureBuilder<CartResponse>(
        future: cartFuture,

        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
              CircularProgressIndicator(
                color:
                primaryYellow,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets
                    .all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    const Icon(
                      Icons
                          .error_outline,
                      size: 65,
                      color:
                      darkColor,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      'Could not load cart',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      snapshot.error
                          .toString(),
                      textAlign:
                      TextAlign
                          .center,
                      style:
                      const TextStyle(
                        color:
                        greyColor,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          loadCart();
                        });
                      },
                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        primaryYellow,
                        foregroundColor:
                        darkColor,
                      ),
                      child:
                      const Text(
                        'Try Again',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final cart =
          snapshot.data!;

          if (cart.items.isEmpty) {
            return Center(
              child: Padding(
                padding:
                const EdgeInsets
                    .all(30),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,
                        shape:
                        BoxShape.circle,
                        border:
                        Border.all(
                          color: Colors
                              .grey
                              .shade200,
                        ),
                      ),
                      child:
                      const Icon(
                        Icons
                            .shopping_bag_outlined,
                        size: 50,
                        color:
                        primaryYellow,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      'Your cart is empty',
                      style: TextStyle(
                        color:
                        darkColor,
                        fontSize: 21,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Add some jewelry to your cart and it will appear here.',
                      textAlign:
                      TextAlign
                          .center,
                      style:
                      TextStyle(
                        color:
                        greyColor,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: primaryYellow,
            onRefresh: refreshCart,

            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),

              padding:
              const EdgeInsets
                  .all(20),

              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
                  children: [
                    const Text(
                      'Cart Items',
                      style: TextStyle(
                        color:
                        darkColor,
                        fontSize: 20,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    Text(
                      '${cart.items.length} items',
                      style:
                      const TextStyle(
                        color:
                        greyColor,
                        fontWeight:
                        FontWeight
                            .w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 18,
                ),

                ...cart.items.map(
                      (item) {
                    return CartItemCard(
                      item: item,

                      isDeleting:
                      deletingCartId ==
                          item.id,

                      isUpdating:
                      updatingCartId ==
                          item.id,

                      onDelete: () {
                        confirmRemoveItem(
                          item,
                        );
                      },

                      onIncrease: () {
                        updateQuantity(
                          item: item,
                          newQuantity:
                          item.quantity +
                              1,
                        );
                      },

                      onDecrease: () {
                        if (item.quantity >
                            1) {
                          updateQuantity(
                            item: item,
                            newQuantity:
                            item.quantity -
                                1,
                          );
                        }
                      },
                    );
                  },
                ),

                const SizedBox(
                  height: 10,
                ),

                // =========================
                // ORDER SUMMARY
                // =========================

                Container(
                  padding:
                  const EdgeInsets
                      .all(20),

                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,

                    borderRadius:
                    BorderRadius
                        .circular(
                      20,
                    ),

                    border:
                    Border.all(
                      color: Colors
                          .grey
                          .shade200,
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      const Text(
                        'Order Summary',
                        style: TextStyle(
                          color:
                          darkColor,
                          fontSize: 18,
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      SummaryRow(
                        title:
                        'Subtotal',
                        value:
                        '${cart.details.subTotal.toStringAsFixed(2)} KWD',
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      SummaryRow(
                        title: 'Tax',
                        value:
                        '${cart.details.tax.toStringAsFixed(2)} KWD',
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      SummaryRow(
                        title:
                        'Delivery',
                        value:
                        '${cart.details.deliveryFee.toStringAsFixed(2)} KWD',
                      ),

                      if (cart.details
                          .totalDiscount >
                          0) ...[
                        const SizedBox(
                          height: 14,
                        ),

                        SummaryRow(
                          title:
                          'Discount',
                          value:
                          '-${cart.details.totalDiscount.toStringAsFixed(2)} KWD',
                        ),
                      ],

                      const Divider(
                        height: 32,
                      ),

                      SummaryRow(
                        title: 'Total',
                        value:
                        '${cart.details.totalCost.toStringAsFixed(2)} KWD',
                        bold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  height: 56,

                  child:
                  ElevatedButton(
                    onPressed: () {
                      // Checkout لاحقًا
                    },

                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      primaryYellow,
                      foregroundColor:
                      darkColor,
                      elevation: 0,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          16,
                        ),
                      ),
                    ),

                    child:
                    const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===========================================
// CART ITEM CARD
// ===========================================

class CartItemCard
    extends StatelessWidget {
  final CartItem item;

  final bool isDeleting;
  final bool isUpdating;

  final VoidCallback onDelete;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isDeleting,
    required this.isUpdating,
    required this.onDelete,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 14,
      ),

      padding:
      const EdgeInsets.all(
        12,
      ),

      decoration:
      BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border: Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),

      child: Row(
        children: [
          ClipRRect(
            borderRadius:
            BorderRadius
                .circular(14),

            child: item
                .thumbnail.isNotEmpty
                ? Image.network(
              item.thumbnail,
              width: 92,
              height: 92,
              fit:
              BoxFit.cover,

              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return productPlaceholder();
              },
            )
                : productPlaceholder(),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,

              children: [
                Text(
                  item.productName,

                  maxLines: 2,

                  overflow:
                  TextOverflow
                      .ellipsis,

                  style:
                  const TextStyle(
                    color: Color(
                      0xFF111111,
                    ),
                    fontSize: 15,
                    fontWeight:
                    FontWeight
                        .w800,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  item.formattedPrice,

                  style:
                  const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight
                        .w700,
                    color: Color(
                      0xFF111111,
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Row(
                  children: [
                    InkWell(
                      onTap:
                      item.quantity >
                          1 &&
                          !isUpdating
                          ? onDecrease
                          : null,

                      borderRadius:
                      BorderRadius
                          .circular(8),

                      child:
                      Container(
                        width: 32,
                        height: 32,

                        decoration:
                        BoxDecoration(
                          color: Colors
                              .grey
                              .shade100,

                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),

                        child:
                        Icon(
                          Icons.remove,
                          size: 18,
                          color:
                          item.quantity >
                              1
                              ? const Color(
                            0xFF111111,
                          )
                              : Colors
                              .grey,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    isUpdating
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                        color:
                        Color(
                          0xFFF5C542,
                        ),
                      ),
                    )
                        : Text(
                      '${item.quantity}',
                      style:
                      const TextStyle(
                        fontSize:
                        16,
                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    InkWell(
                      onTap:
                      !isUpdating
                          ? onIncrease
                          : null,

                      borderRadius:
                      BorderRadius
                          .circular(8),

                      child:
                      Container(
                        width: 32,
                        height: 32,

                        decoration:
                        BoxDecoration(
                          color:
                          const Color(
                            0xFFF5C542,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),

                        child:
                        const Icon(
                          Icons.add,
                          size: 18,
                          color:
                          Color(
                            0xFF111111,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 5,
          ),

          isDeleting
              ? const Padding(
            padding:
            EdgeInsets.all(
              12,
            ),
            child: SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color:
                Colors.red,
              ),
            ),
          )
              : IconButton(
            onPressed:
            onDelete,
            tooltip:
            'Remove item',
            icon:
            const Icon(
              Icons
                  .delete_outline,
              color:
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  static Widget
  productPlaceholder() {
    return Container(
      width: 92,
      height: 92,

      color:
      Colors.grey.shade100,

      child: const Icon(
        Icons.diamond_outlined,
        color:
        Color(0xFFF5C542),
        size: 40,
      ),
    );
  }
}

// ===========================================
// SUMMARY ROW
// ===========================================

class SummaryRow
    extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const SummaryRow({
    super.key,
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment
          .spaceBetween,

      children: [
        Text(
          title,

          style: TextStyle(
            color: bold
                ? const Color(
              0xFF111111,
            )
                : const Color(
              0xFF777777,
            ),

            fontSize:
            bold ? 17 : 14,

            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w500,
          ),
        ),

        Text(
          value,

          style: TextStyle(
            color:
            const Color(
              0xFF111111,
            ),

            fontSize:
            bold ? 18 : 14,

            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}