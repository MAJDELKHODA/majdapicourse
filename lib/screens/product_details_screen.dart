import 'package:flutter/material.dart';

import '../Model/product_model.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;
  final String token;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.token,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  static const Color primaryYellow =
  Color(0xFFF5C542);

  static const Color darkColor =
  Color(0xFF111111);

  static const Color backgroundColor =
  Color(0xFFF7F7F7);

  static const Color greyColor =
  Color(0xFF777777);

  final Map<String, String> selectedOptions = {};

  ProductVariation? selectedVariation;

  final CartService cartService = CartService();

  final WishlistService wishlistService =
  WishlistService();

  bool isAddingToCart = false;

  bool isWishlistLoading = false;

  late bool isFavorite;

  @override
  void initState() {
    super.initState();

    isFavorite = widget.product.isFavorite;

    for (final option in widget.product.choiceOptions) {
      if (option.options.isNotEmpty) {
        selectedOptions[option.name] =
            option.options.first;
      }
    }

    _updateSelectedVariation();
  }

  // =========================
  // UPDATE SELECTED VARIATION
  // =========================

  void _updateSelectedVariation() {
    if (!widget.product.hasVariations ||
        widget.product.variations.isEmpty) {
      selectedVariation = null;
      return;
    }

    for (final variation
    in widget.product.variations) {
      bool matches = true;

      for (final entry
      in selectedOptions.entries) {
        final normalizedValue =
        entry.value.replaceAll(' ', '');

        if (!variation.type
            .toLowerCase()
            .contains(
          normalizedValue.toLowerCase(),
        )) {
          matches = false;
          break;
        }
      }

      if (matches) {
        selectedVariation = variation;
        return;
      }
    }

    selectedVariation =
        widget.product.variations.first;
  }

  // =========================
  // ADD TO CART
  // =========================

  Future<void> addToCart() async {
    if (isAddingToCart) return;

    setState(() {
      isAddingToCart = true;
    });

    try {
      final result =
      await cartService.addToCart(
        productId: widget.product.id,
        quantity: 1,
        token: widget.token,
      );

      if (!mounted) return;

      if (result['status'] == 1 ||
          result['status'] == true) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ??
                  'Successfully added!',
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
              result['message'] ??
                  'Could not add product to cart',
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
          isAddingToCart = false;
        });
      }
    }
  }

  // =========================
  // TOGGLE WISHLIST
  // =========================

  Future<void> toggleWishlist() async {
    if (isWishlistLoading) return;

    setState(() {
      isWishlistLoading = true;
    });

    try {
      Map<String, dynamic> result;

      if (isFavorite) {
        result =
        await wishlistService
            .removeFromWishlist(
          productId: widget.product.id,
          token: widget.token,
        );
      } else {
        result =
        await wishlistService
            .addToWishlist(
          productId: widget.product.id,
          token: widget.token,
        );
      }

      if (!mounted) return;

      final status = result['status'];

      final message =
          result['message']
              ?.toString() ??
              '';

      if (status == true ||
          status == 1) {
        setState(() {
          isFavorite = !isFavorite;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              message.isNotEmpty
                  ? message
                  : isFavorite
                  ? 'Added to wishlist'
                  : 'Removed from wishlist',
            ),
            backgroundColor:
            Colors.green,
          ),
        );
      } else {
        if (message
            .toLowerCase()
            .contains('already')) {
          setState(() {
            isFavorite = true;
          });
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              message.isNotEmpty
                  ? message
                  : 'Wishlist operation failed',
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
          isWishlistLoading =
          false;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final product =
        widget.product;

    final int availableQty =
        selectedVariation?.qty ??
            product.currentStock;

    final bool inStock =
        availableQty > 0;

    return Scaffold(
      backgroundColor:
      backgroundColor,

      appBar: AppBar(
        backgroundColor:
        backgroundColor,

        elevation: 0,

        foregroundColor:
        darkColor,

        title: const Text(
          'Product Details',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
            isWishlistLoading
                ? null
                : toggleWishlist,

            icon:
            isWishlistLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color:
                darkColor,
              ),
            )
                : Icon(
              isFavorite
                  ? Icons.favorite
                  : Icons
                  .favorite_border,

              color:
              isFavorite
                  ? Colors.red
                  : darkColor,
            ),
          ),
        ],
      ),

      body:
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment
              .start,

          children: [
            // =========================
            // PRODUCT IMAGE
            // =========================

            Container(
              width:
              double.infinity,

              height: 380,

              color:
              Colors.white,

              child:
              product.thumbnail
                  .isNotEmpty
                  ? Image.network(
                product.thumbnail,

                fit:
                BoxFit.cover,

                errorBuilder:
                    (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return const Center(
                    child:
                    Icon(
                      Icons
                          .diamond_outlined,
                      size:
                      90,
                      color:
                      primaryYellow,
                    ),
                  );
                },
              )
                  : const Center(
                child:
                Icon(
                  Icons
                      .diamond_outlined,
                  size: 90,
                  color:
                  primaryYellow,
                ),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets
                  .all(22),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  // =========================
                  // PRODUCT NAME
                  // =========================

                  Text(
                    product.name,

                    style:
                    const TextStyle(
                      color:
                      darkColor,

                      fontSize:
                      26,

                      height:
                      1.2,

                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // =========================
                  // PRICE
                  // =========================

                  Text(
                    product
                        .formattedPrice,

                    style:
                    const TextStyle(
                      color:
                      darkColor,

                      fontSize:
                      22,

                      fontWeight:
                      FontWeight
                          .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =========================
                  // STOCK
                  // =========================

                  Row(
                    children: [
                      Container(
                        width:
                        9,

                        height:
                        9,

                        decoration:
                        BoxDecoration(
                          color:
                          inStock
                              ? Colors
                              .green
                              : Colors
                              .red,

                          shape:
                          BoxShape
                              .circle,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      Text(
                        inStock
                            ? 'In Stock'
                            : 'Out of Stock',

                        style:
                        TextStyle(
                          color:
                          inStock
                              ? Colors
                              .green
                              : Colors
                              .red,

                          fontWeight:
                          FontWeight
                              .w700,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Text(
                        '$availableQty available',

                        style:
                        const TextStyle(
                          color:
                          greyColor,

                          fontSize:
                          13,
                        ),
                      ),
                    ],
                  ),

                  // =========================
                  // OPTIONS
                  // =========================

                  if (product
                      .hasVariations &&
                      product
                          .choiceOptions
                          .isNotEmpty) ...[
                    const SizedBox(
                      height: 28,
                    ),

                    const Text(
                      'Options',

                      style:
                      TextStyle(
                        color:
                        darkColor,

                        fontSize:
                        18,

                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    ...product
                        .choiceOptions
                        .map(
                          (option) {
                        return Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            bottom:
                            18,
                          ),

                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                            children: [
                              Text(
                                option.name
                                    .toUpperCase(),

                                style:
                                const TextStyle(
                                  color:
                                  darkColor,

                                  fontSize:
                                  13,

                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),

                              const SizedBox(
                                height:
                                10,
                              ),

                              Wrap(
                                spacing:
                                10,

                                runSpacing:
                                10,

                                children:
                                option
                                    .options
                                    .map(
                                      (
                                      value,
                                      ) {
                                    final isSelected =
                                        selectedOptions[
                                        option.name] ==
                                            value;

                                    return ChoiceChip(
                                      label:
                                      Text(
                                        value,
                                      ),

                                      selected:
                                      isSelected,

                                      selectedColor:
                                      primaryYellow,

                                      backgroundColor:
                                      Colors
                                          .white,

                                      side:
                                      BorderSide(
                                        color:
                                        isSelected
                                            ? primaryYellow
                                            : Colors
                                            .grey
                                            .shade300,
                                      ),

                                      labelStyle:
                                      TextStyle(
                                        color:
                                        darkColor,

                                        fontWeight:
                                        isSelected
                                            ? FontWeight
                                            .w800
                                            : FontWeight
                                            .w500,
                                      ),

                                      onSelected:
                                          (_) {
                                        setState(
                                              () {
                                            selectedOptions[
                                            option.name] =
                                                value;

                                            _updateSelectedVariation();
                                          },
                                        );
                                      },
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],

                  // =========================
                  // SHORT DESCRIPTION
                  // =========================

                  if (product
                      .shortDescription
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'About this product',

                      style:
                      TextStyle(
                        color:
                        darkColor,

                        fontSize:
                        18,

                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      product
                          .shortDescription,

                      style:
                      const TextStyle(
                        color:
                        greyColor,

                        fontSize:
                        14,

                        height:
                        1.6,
                      ),
                    ),
                  ],

                  // =========================
                  // DESCRIPTION
                  // =========================

                  if (product
                      .details
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 24,
                    ),

                    const Text(
                      'Description',

                      style:
                      TextStyle(
                        color:
                        darkColor,

                        fontSize:
                        18,

                        fontWeight:
                        FontWeight
                            .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Text(
                      _removeHtmlTags(
                        product.details,
                      ),

                      style:
                      const TextStyle(
                        color:
                        greyColor,

                        fontSize:
                        14,

                        height:
                        1.6,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 28,
                  ),

                  // =========================
                  // SELECTED VARIANT
                  // =========================

                  if (selectedVariation !=
                      null) ...[
                    Container(
                      width:
                      double.infinity,

                      padding:
                      const EdgeInsets
                          .all(14),

                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,

                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),

                        border:
                        Border.all(
                          color:
                          Colors
                              .grey
                              .shade200,
                        ),
                      ),

                      child:
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                        children: [
                          const Text(
                            'Selected Variant',

                            style:
                            TextStyle(
                              color:
                              greyColor,

                              fontSize:
                              12,
                            ),
                          ),

                          const SizedBox(
                            height:
                            5,
                          ),

                          Text(
                            selectedVariation!
                                .type,

                            style:
                            const TextStyle(
                              color:
                              darkColor,

                              fontWeight:
                              FontWeight
                                  .w800,
                            ),
                          ),

                          const SizedBox(
                            height:
                            5,
                          ),

                          Text(
                            'SKU: ${selectedVariation!.sku}',

                            style:
                            const TextStyle(
                              color:
                              greyColor,

                              fontSize:
                              12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height:
                      20,
                    ),
                  ],

                  // =========================
                  // ADD TO CART BUTTON
                  // =========================

                  SizedBox(
                    width:
                    double.infinity,

                    child:
                    ElevatedButton
                        .icon(
                      onPressed:
                      inStock &&
                          !isAddingToCart
                          ? addToCart
                          : null,

                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        primaryYellow,

                        foregroundColor:
                        darkColor,

                        disabledBackgroundColor:
                        Colors
                            .grey
                            .shade300,

                        elevation:
                        0,

                        padding:
                        const EdgeInsets
                            .symmetric(
                          vertical:
                          16,
                        ),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            15,
                          ),
                        ),
                      ),

                      icon:
                      isAddingToCart
                          ? const SizedBox(
                        width:
                        20,

                        height:
                        20,

                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          2,

                          color:
                          darkColor,
                        ),
                      )
                          : const Icon(
                        Icons
                            .shopping_bag_outlined,
                      ),

                      label:
                      Text(
                        isAddingToCart
                            ? 'Adding...'
                            : 'Add to Cart',

                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight
                              .w800,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                    25,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _removeHtmlTags(
      String htmlText,
      ) {
    final RegExp exp =
    RegExp(
      r'<[^>]*>',
      multiLine:
      true,
      caseSensitive:
      true,
    );

    return htmlText
        .replaceAll(
      exp,
      '',
    )
        .trim();
  }
}