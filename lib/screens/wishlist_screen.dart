import 'package:flutter/material.dart';

import '../Model/product_model.dart';
import '../services/wishlist_service.dart';
import 'product_details_screen.dart';

class WishlistScreen extends StatefulWidget {
  final String token;

  const WishlistScreen({
    super.key,
    required this.token,
  });

  @override
  State<WishlistScreen> createState() =>
      _WishlistScreenState();
}

class _WishlistScreenState
    extends State<WishlistScreen> {
  final WishlistService wishlistService =
  WishlistService();

  late Future<List<ProductModel>> wishlistFuture;

  int? removingProductId;

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

    loadWishlist();
  }

  void loadWishlist() {
    wishlistFuture =
        wishlistService.getWishlist(
          token: widget.token,
        );
  }

  Future<void> refreshWishlist() async {
    setState(() {
      loadWishlist();
    });

    await wishlistFuture;
  }

  Future<void> removeFromWishlist(
      ProductModel product,
      ) async {
    if (removingProductId != null) {
      return;
    }

    setState(() {
      removingProductId = product.id;
    });

    try {
      final result =
      await wishlistService.removeFromWishlist(
        productId: product.id,
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
              result['message']?.toString() ??
                  'Removed from wishlist',
            ),
            backgroundColor:
            Colors.green,
          ),
        );

        setState(() {
          loadWishlist();
        });
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              result['message']?.toString() ??
                  'Could not remove product',
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
          removingProductId = null;
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
          'My Wishlist',
          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body:
      FutureBuilder<List<ProductModel>>(
        future: wishlistFuture,

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
                const EdgeInsets.all(
                  24,
                ),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color:
                      darkColor,
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    const Text(
                      'Could not load wishlist',
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
                          loadWishlist();
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

          final products =
              snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Padding(
                padding:
                EdgeInsets.all(
                  30,
                ),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,

                  children: [
                    Icon(
                      Icons
                          .favorite_border,
                      size: 80,
                      color:
                      primaryYellow,
                    ),

                    SizedBox(
                      height: 18,
                    ),

                    Text(
                      'Your wishlist is empty',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight:
                        FontWeight
                            .w800,
                        color:
                        darkColor,
                      ),
                    ),

                    SizedBox(
                      height: 8,
                    ),

                    Text(
                      'Save products you love and they will appear here.',
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
            color:
            primaryYellow,

            onRefresh:
            refreshWishlist,

            child:
            GridView.builder(
              padding:
              const EdgeInsets
                  .all(20),

              itemCount:
              products.length,

              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio:
                0.62,
              ),

              itemBuilder:
                  (context, index) {
                final product =
                products[index];

                final isRemoving =
                    removingProductId ==
                        product.id;

                return Container(
                  clipBehavior:
                  Clip.antiAlias,

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
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: product
                                  .thumbnail
                                  .isNotEmpty
                                  ? Image.network(
                                product
                                    .thumbnail,
                                fit: BoxFit
                                    .cover,

                                errorBuilder:
                                    (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return productPlaceholder();
                                },
                              )
                                  : productPlaceholder(),
                            ),

                            Positioned(
                              top: 10,
                              right: 10,

                              child:
                              Container(
                                width: 38,
                                height: 38,

                                decoration:
                                const BoxDecoration(
                                  color:
                                  Colors.white,
                                  shape:
                                  BoxShape.circle,
                                ),

                                child: isRemoving
                                    ? const Padding(
                                  padding:
                                  EdgeInsets.all(
                                    9,
                                  ),
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth:
                                    2,
                                    color:
                                    Colors.red,
                                  ),
                                )
                                    : IconButton(
                                  padding:
                                  EdgeInsets.zero,
                                  onPressed:
                                      () {
                                    removeFromWishlist(
                                      product,
                                    );
                                  },
                                  icon:
                                  const Icon(
                                    Icons.favorite,
                                    size:
                                    21,
                                    color:
                                    Colors.red,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding:
                        const EdgeInsets
                            .all(
                          12,
                        ),

                        child:
                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                          children: [
                            Text(
                              product.name,

                              maxLines:
                              2,

                              overflow:
                              TextOverflow
                                  .ellipsis,

                              style:
                              const TextStyle(
                                color:
                                darkColor,
                                fontSize:
                                14,
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),

                            const SizedBox(
                              height:
                              8,
                            ),

                            Text(
                              product
                                  .formattedPrice,

                              style:
                              const TextStyle(
                                color:
                                darkColor,
                                fontSize:
                                16,
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),

                            const SizedBox(
                              height:
                              10,
                            ),

                            SizedBox(
                              width: double
                                  .infinity,
                              height:
                              42,

                              child:
                              ElevatedButton(
                                onPressed:
                                    () {
                                  Navigator
                                      .push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (
                                          context,
                                          ) =>
                                          ProductDetailsScreen(
                                            product:
                                            product,
                                            token:
                                            widget.token,
                                          ),
                                    ),
                                  ).then(
                                        (_) {
                                      refreshWishlist();
                                    },
                                  );
                                },

                                style:
                                ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  primaryYellow,
                                  foregroundColor:
                                  darkColor,
                                  elevation:
                                  0,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                ),

                                child:
                                const Text(
                                  'View Product',
                                  style:
                                  TextStyle(
                                    fontSize:
                                    12,
                                    fontWeight:
                                    FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget productPlaceholder() {
    return Container(
      color:
      Colors.grey.shade100,

      child: const Center(
        child: Icon(
          Icons.diamond_outlined,
          size: 55,
          color:
          primaryYellow,
        ),
      ),
    );
  }
}