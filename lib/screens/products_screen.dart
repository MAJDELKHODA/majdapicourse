import 'package:flutter/material.dart';

import '../Model/product_model.dart';
import '../services/product_service.dart';
import '../services/wishlist_service.dart';

import 'product_details_screen.dart';
import 'wishlist_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String token;

  const ProductsScreen({
    super.key,
    required this.token,
  });

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  static const Color primaryYellow =
  Color(0xFFF5C542);

  static const Color darkColor =
  Color(0xFF111111);

  static const Color backgroundColor =
  Color(0xFFF7F7F7);

  static const Color greyColor =
  Color(0xFF777777);

  final ProductService productService =
  ProductService();

  final TextEditingController searchController =
  TextEditingController();

  late Future<List<ProductModel>> productsFuture;

  String searchQuery = '';

  int? selectedCategoryId;

  // =========================
  // CATEGORIES
  // =========================

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'All',
      'id': null,
    },
    {
      'name': 'Rings',
      'id': 268,
    },
    {
      'name': 'Necklaces',
      'id': 267,
    },
    {
      'name': 'Bracelets',
      'id': 266,
    },
  ];

  @override
  void initState() {
    super.initState();

    loadProducts();
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  // =========================
  // LOAD PRODUCTS
  // =========================

  void loadProducts() {
    productsFuture =
        _loadProductsForCategory(
          selectedCategoryId,
        );
  }

  Future<List<ProductModel>>
  _loadProductsForCategory(
      int? categoryId,
      ) async {
    // =========================
    // ALL PRODUCTS
    // =========================

    if (categoryId == null) {
      final results =
      await Future.wait([
        productService.getProducts(
          categoryId: 265,
        ),
        productService.getProducts(
          categoryId: 268,
        ),
        productService.getProducts(
          categoryId: 267,
        ),
        productService.getProducts(
          categoryId: 266,
        ),
      ]);

      // إزالة المنتجات المكررة حسب ID
      final Map<int, ProductModel>
      uniqueProducts = {};

      for (final list in results) {
        for (final product in list) {
          uniqueProducts[product.id] =
              product;
        }
      }

      return uniqueProducts.values.toList();
    }

    // =========================
    // SPECIFIC CATEGORY
    // =========================

    return productService.getProducts(
      categoryId: categoryId,
    );
  }

  // =========================
  // REFRESH PRODUCTS
  // =========================

  Future<void> refreshProducts() async {
    setState(() {
      loadProducts();
    });

    await productsFuture;
  }

  // =========================
  // SELECT CATEGORY
  // =========================

  void selectCategory(
      int? categoryId,
      ) {
    if (selectedCategoryId ==
        categoryId) {
      return;
    }

    setState(() {
      selectedCategoryId =
          categoryId;

      searchQuery = '';

      searchController.clear();

      loadProducts();
    });
  }

  // =========================
  // OPEN WISHLIST
  // =========================

  Future<void> openWishlist() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WishlistScreen(
              token: widget.token,
            ),
      ),
    );

    if (!mounted) return;

    await refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      backgroundColor,

      // =========================
      // APP BAR
      // =========================

      appBar: AppBar(
        backgroundColor:
        backgroundColor,

        elevation: 0,

        foregroundColor:
        darkColor,

        title: const Text(
          'Products',

          style: TextStyle(
            color:
            darkColor,

            fontSize:
            21,

            fontWeight:
            FontWeight.w800,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
            openWishlist,

            icon:
            const Icon(
              Icons.favorite_border,

              color:
              darkColor,
            ),
          ),

          const SizedBox(
            width:
            6,
          ),
        ],
      ),

      body:
      FutureBuilder<List<ProductModel>>(
        future:
        productsFuture,

        builder:
            (
            context,
            snapshot,
            ) {
          // =========================
          // LOADING
          // =========================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return Column(
              children: [
                _buildTopSection(),

                const Expanded(
                  child:
                  Center(
                    child:
                    CircularProgressIndicator(
                      color:
                      primaryYellow,
                    ),
                  ),
                ),
              ],
            );
          }

          // =========================
          // ERROR
          // =========================

          if (snapshot.hasError) {
            return Column(
              children: [
                _buildTopSection(),

                Expanded(
                  child:
                  Center(
                    child:
                    Padding(
                      padding:
                      const EdgeInsets
                          .all(
                        24,
                      ),

                      child:
                      Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                        children: [
                          const Icon(
                            Icons
                                .error_outline,

                            size:
                            60,

                            color:
                            darkColor,
                          ),

                          const SizedBox(
                            height:
                            15,
                          ),

                          const Text(
                            'Could not load products',

                            style:
                            TextStyle(
                              fontSize:
                              18,

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
                            snapshot.error
                                .toString(),

                            textAlign:
                            TextAlign
                                .center,

                            style:
                            const TextStyle(
                              color:
                              greyColor,

                              fontSize:
                              12,
                            ),
                          ),

                          const SizedBox(
                            height:
                            20,
                          ),

                          ElevatedButton(
                            onPressed:
                                () {
                              setState(
                                    () {
                                  loadProducts();
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
                            ),

                            child:
                            const Text(
                              'Try Again',

                              style:
                              TextStyle(
                                fontWeight:
                                FontWeight
                                    .w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }

          final allProducts =
              snapshot.data ?? [];

          final products =
          allProducts.where(
                (product) {
              return product.name
                  .toLowerCase()
                  .contains(
                searchQuery
                    .toLowerCase(),
              );
            },
          ).toList();

          return RefreshIndicator(
            color:
            primaryYellow,

            onRefresh:
            refreshProducts,

            child:
            CustomScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),

              slivers: [
                SliverToBoxAdapter(
                  child:
                  _buildTopSection(),
                ),

                // =========================
                // PRODUCTS COUNT
                // =========================

                SliverToBoxAdapter(
                  child:
                  Padding(
                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      20,
                      5,
                      20,
                      14,
                    ),

                    child:
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,

                      children: [
                        Text(
                          _selectedCategoryName(),

                          style:
                          const TextStyle(
                            color:
                            darkColor,

                            fontSize:
                            18,

                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),

                        Text(
                          '${products.length} Products',

                          style:
                          const TextStyle(
                            color:
                            greyColor,

                            fontSize:
                            12,

                            fontWeight:
                            FontWeight
                                .w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // =========================
                // EMPTY CATEGORY
                // =========================

                if (products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody:
                    false,

                    child:
                    Center(
                      child:
                      Padding(
                        padding:
                        const EdgeInsets
                            .all(
                          30,
                        ),

                        child:
                        Column(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                          children: [
                            Container(
                              width:
                              85,

                              height:
                              85,

                              decoration:
                              const BoxDecoration(
                                color:
                                Colors.white,

                                shape:
                                BoxShape
                                    .circle,
                              ),

                              child:
                              const Icon(
                                Icons
                                    .diamond_outlined,

                                size:
                                42,

                                color:
                                primaryYellow,
                              ),
                            ),

                            const SizedBox(
                              height:
                              18,
                            ),

                            const Text(
                              'No products available',

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
                              height:
                              7,
                            ),

                            Text(
                              searchQuery.isNotEmpty
                                  ? 'No products match your search.'
                                  : 'No products available in this category yet.',

                              textAlign:
                              TextAlign
                                  .center,

                              style:
                              const TextStyle(
                                color:
                                greyColor,

                                fontSize:
                                13,

                                height:
                                1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                // =========================
                // PRODUCTS GRID
                // =========================

                  SliverPadding(
                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      20,
                      0,
                      20,
                      30,
                    ),

                    sliver:
                    SliverGrid(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                        2,

                        crossAxisSpacing:
                        14,

                        mainAxisSpacing:
                        14,

                        childAspectRatio:
                        0.63,
                      ),

                      delegate:
                      SliverChildBuilderDelegate(
                            (
                            context,
                            index,
                            ) {
                          final product =
                          products[index];

                          return ProductsProductCard(
                            product:
                            product,

                            token:
                            widget.token,

                            onRefresh:
                            refreshProducts,
                          );
                        },

                        childCount:
                        products.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      // =========================
      // BOTTOM NAVIGATION
      // =========================

      bottomNavigationBar:
      BottomNavigationBar(
        type:
        BottomNavigationBarType
            .fixed,

        currentIndex:
        1,

        selectedItemColor:
        darkColor,

        unselectedItemColor:
        greyColor,

        selectedLabelStyle:
        const TextStyle(
          fontWeight:
          FontWeight.w700,
        ),

        onTap:
            (index) {
          if (index ==
              0) {
            Navigator.pop(
              context,
            );
          }

          if (index ==
              2) {
            openWishlist();
          }
        },

        items:
        const [
          BottomNavigationBarItem(
            icon:
            Icon(
              Icons
                  .home_outlined,
            ),

            label:
            'Home',
          ),

          BottomNavigationBarItem(
            icon:
            Icon(
              Icons
                  .grid_view_outlined,
            ),

            activeIcon:
            Icon(
              Icons
                  .grid_view,
            ),

            label:
            'Products',
          ),

          BottomNavigationBarItem(
            icon:
            Icon(
              Icons
                  .favorite_border,
            ),

            label:
            'Wishlist',
          ),

          BottomNavigationBarItem(
            icon:
            Icon(
              Icons
                  .person_outline,
            ),

            label:
            'Profile',
          ),
        ],
      ),
    );
  }

  // =========================
  // TOP SECTION
  // =========================

  Widget _buildTopSection() {
    return Padding(
      padding:
      const EdgeInsets
          .fromLTRB(
        20,
        15,
        20,
        20,
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          // =========================
          // SEARCH
          // =========================

          Container(
            decoration:
            BoxDecoration(
              color:
              Colors.white,

              borderRadius:
              BorderRadius
                  .circular(
                16,
              ),

              border:
              Border.all(
                color:
                Colors.grey
                    .shade300,
              ),
            ),

            child:
            TextField(
              controller:
              searchController,

              onChanged:
                  (value) {
                setState(
                      () {
                    searchQuery =
                        value;
                  },
                );
              },

              decoration:
              const InputDecoration(
                hintText:
                'Search jewelry...',

                hintStyle:
                TextStyle(
                  color:
                  greyColor,
                ),

                prefixIcon:
                Icon(
                  Icons.search,

                  color:
                  darkColor,
                ),

                border:
                InputBorder
                    .none,

                contentPadding:
                EdgeInsets
                    .symmetric(
                  horizontal:
                  16,

                  vertical:
                  16,
                ),
              ),
            ),
          ),

          const SizedBox(
            height:
            20,
          ),

          // =========================
          // CATEGORIES
          // =========================

          const Text(
            'Categories',

            style:
            TextStyle(
              color:
              darkColor,

              fontSize:
              17,

              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height:
            12,
          ),

          SizedBox(
            height:
            44,

            child:
            ListView.separated(
              scrollDirection:
              Axis.horizontal,

              itemCount:
              categories.length,

              separatorBuilder:
                  (
                  context,
                  index,
                  ) =>
              const SizedBox(
                width:
                9,
              ),

              itemBuilder:
                  (
                  context,
                  index,
                  ) {
                final category =
                categories[index];

                final int?
                categoryId =
                category['id'];

                final bool
                selected =
                    selectedCategoryId ==
                        categoryId;

                return ChoiceChip(
                  label:
                  Text(
                    category['name']
                        .toString(),
                  ),

                  selected:
                  selected,

                  onSelected:
                      (_) {
                    selectCategory(
                      categoryId,
                    );
                  },

                  selectedColor:
                  primaryYellow,

                  backgroundColor:
                  Colors.white,

                  side:
                  BorderSide(
                    color:
                    selected
                        ? primaryYellow
                        : Colors
                        .grey
                        .shade300,
                  ),

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      14,
                    ),
                  ),

                  labelStyle:
                  TextStyle(
                    color:
                    darkColor,

                    fontWeight:
                    selected
                        ? FontWeight
                        .w800
                        : FontWeight
                        .w600,
                  ),

                  showCheckmark:
                  false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // SELECTED CATEGORY NAME
  // =========================

  String _selectedCategoryName() {
    if (selectedCategoryId ==
        null) {
      return 'All Products';
    }

    for (final category
    in categories) {
      if (category['id'] ==
          selectedCategoryId) {
        return category['name']
            .toString();
      }
    }

    return 'Products';
  }
}

// =====================================================
// PRODUCT CARD
// =====================================================

class ProductsProductCard
    extends StatefulWidget {
  final ProductModel product;

  final String token;

  final Future<void> Function()
  onRefresh;

  const ProductsProductCard({
    super.key,
    required this.product,
    required this.token,
    required this.onRefresh,
  });

  @override
  State<ProductsProductCard>
  createState() =>
      _ProductsProductCardState();
}

class _ProductsProductCardState
    extends State<ProductsProductCard> {
  // =========================
  // COLORS
  // =========================
  //
  // مهم:
  // هذا الكلاس مستقل عن ProductsScreen
  // لذلك لازم تكون الألوان معرفة هنا أيضًا.
  //

  static const Color primaryYellow =
  Color(0xFFF5C542);

  static const Color darkColor =
  Color(0xFF111111);

  static const Color greyColor =
  Color(0xFF777777);

  final WishlistService
  wishlistService =
  WishlistService();

  late bool isFavorite;

  bool isWishlistLoading =
  false;

  @override
  void initState() {
    super.initState();

    isFavorite =
        widget.product.isFavorite;
  }

  @override
  void didUpdateWidget(
      covariant ProductsProductCard
      oldWidget,
      ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (oldWidget.product.id !=
        widget.product.id) {
      isFavorite =
          widget.product.isFavorite;

      return;
    }

    if (!isWishlistLoading) {
      isFavorite =
          widget.product.isFavorite;
    }
  }

  // =========================
  // TOGGLE WISHLIST
  // =========================

  Future<void>
  toggleWishlist() async {
    if (isWishlistLoading) {
      return;
    }

    setState(() {
      isWishlistLoading =
      true;
    });

    try {
      Map<String, dynamic>
      result;

      if (isFavorite) {
        result =
        await wishlistService
            .removeFromWishlist(
          productId:
          widget.product.id,

          token:
          widget.token,
        );
      } else {
        result =
        await wishlistService
            .addToWishlist(
          productId:
          widget.product.id,

          token:
          widget.token,
        );
      }

      if (!mounted) return;

      final status =
      result['status'];

      final message =
          result['message']
              ?.toString() ??
              '';

      if (status ==
          true ||
          status ==
              1) {
        setState(() {
          isFavorite =
          !isFavorite;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content:
            Text(
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
            .contains(
          'already',
        )) {
          setState(() {
            isFavorite =
            true;
          });
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          SnackBar(
            content:
            Text(
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content:
          Text(
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

  // =========================
  // OPEN PRODUCT DETAILS
  // =========================

  Future<void>
  openProduct() async {
    await Navigator.push(
      context,

      MaterialPageRoute(
        builder:
            (context) =>
            ProductDetailsScreen(
              product:
              widget.product,

              token:
              widget.token,
            ),
      ),
    );

    if (!mounted) return;

    await widget.onRefresh();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    final product =
        widget.product;

    return Container(
      clipBehavior:
      Clip.antiAlias,

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          20,
        ),

        border:
        Border.all(
          color:
          Colors.grey.shade200,
        ),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black
                .withValues(
              alpha:
              0.04,
            ),

            blurRadius:
            12,

            offset:
            const Offset(
              0,
              5,
            ),
          ),
        ],
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          Expanded(
            child:
            Stack(
              children: [
                // =========================
                // IMAGE
                // =========================

                Positioned.fill(
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
                      return productPlaceholder();
                    },
                  )
                      : productPlaceholder(),
                ),

                // =========================
                // FAVORITE BUTTON
                // =========================

                Positioned(
                  top:
                  10,

                  right:
                  10,

                  child:
                  Container(
                    width:
                    38,

                    height:
                    38,

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,

                      shape:
                      BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color:
                          Colors.black
                              .withValues(
                            alpha:
                            0.08,
                          ),

                          blurRadius:
                          8,
                        ),
                      ],
                    ),

                    child:
                    isWishlistLoading
                        ? const Padding(
                      padding:
                      EdgeInsets.all(
                        10,
                      ),

                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,

                        color:
                        primaryYellow,
                      ),
                    )
                        : IconButton(
                      padding:
                      EdgeInsets.zero,

                      onPressed:
                      toggleWishlist,

                      icon:
                      Icon(
                        isFavorite
                            ? Icons.favorite
                            : Icons
                            .favorite_border,

                        size:
                        20,

                        color:
                        isFavorite
                            ? Colors.red
                            : darkColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // =========================
          // PRODUCT INFO
          // =========================

          Padding(
            padding:
            const EdgeInsets.all(
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
                    fontSize:
                    14,

                    height:
                    1.3,

                    fontWeight:
                    FontWeight.w700,

                    color:
                    darkColor,
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
                    fontSize:
                    16,

                    fontWeight:
                    FontWeight.w800,

                    color:
                    darkColor,
                  ),
                ),

                const SizedBox(
                  height:
                  6,
                ),

                // =========================
                // STOCK
                // =========================

                Row(
                  children: [
                    Container(
                      width:
                      7,

                      height:
                      7,

                      decoration:
                      BoxDecoration(
                        color:
                        product.currentStock >
                            0
                            ? Colors.green
                            : Colors.red,

                        shape:
                        BoxShape.circle,
                      ),
                    ),

                    const SizedBox(
                      width:
                      6,
                    ),

                    Expanded(
                      child:
                      Text(
                        product.stockStatus,

                        maxLines:
                        1,

                        overflow:
                        TextOverflow
                            .ellipsis,

                        style:
                        const TextStyle(
                          fontSize:
                          11,

                          color:
                          greyColor,

                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height:
                  10,
                ),

                // =========================
                // VIEW PRODUCT
                // =========================

                SizedBox(
                  width:
                  double.infinity,

                  height:
                  42,

                  child:
                  ElevatedButton(
                    onPressed:
                    openProduct,

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
  }

  // =========================
  // PLACEHOLDER
  // =========================

  Widget productPlaceholder() {
    return Container(
      color:
      Colors.grey.shade100,

      child:
      const Center(
        child:
        Icon(
          Icons.diamond_outlined,

          size:
          55,

          color:
          primaryYellow,
        ),
      ),
    );
  }
}