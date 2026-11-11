import 'package:flutter/material.dart';

import 'package:majdapicourse/screens/product_details_screen.dart';
import 'package:majdapicourse/screens/cart_screen.dart';
import 'package:majdapicourse/screens/wishlist_screen.dart';
import 'package:majdapicourse/screens/products_screen.dart';
import 'package:majdapicourse/screens/profile_screen.dart';

import '../Model/product_model.dart';
import '../services/product_service.dart';
import '../services/wishlist_service.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({
    super.key,
    required this.token,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService productService =
  ProductService();

  late Future<List<ProductModel>> productsFuture;

  final TextEditingController searchController =
  TextEditingController();

  String searchQuery = '';

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
    loadProducts();
  }

  // =========================
  // LOAD PRODUCTS
  // =========================

  void loadProducts() {
    productsFuture =
        productService.getProducts();
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================
  // OPEN PRODUCTS
  // =========================

  Future<void> openProducts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductsScreen(
              token: widget.token,
            ),
      ),
    );

    if (!mounted) return;

    await refreshProducts();
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

  // =========================
  // OPEN CART
  // =========================

  Future<void> openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CartScreen(
              token: widget.token,
            ),
      ),
    );

    if (!mounted) return;

    await refreshProducts();
  }

  // =========================
  // OPEN PROFILE
  // =========================

  Future<void> openProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProfileScreen(
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

        automaticallyImplyLeading:
        false,

        title: const Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Text(
              'Gold Jewelry Majd',

              style: TextStyle(
                color:
                darkColor,

                fontSize:
                20,

                fontWeight:
                FontWeight.w800,
              ),
            ),

            SizedBox(
              height: 2,
            ),

            Text(
              'Timeless elegance, made for you',

              style: TextStyle(
                color:
                greyColor,

                fontSize:
                12,

                fontWeight:
                FontWeight.w400,
              ),
            ),
          ],
        ),

        actions: [
          // =========================
          // WISHLIST
          // =========================

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

          // =========================
          // CART
          // =========================

          IconButton(
            onPressed:
            openCart,

            icon:
            const Icon(
              Icons.shopping_bag_outlined,

              color:
              darkColor,
            ),
          ),

          const SizedBox(
            width: 6,
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================

      body:
      FutureBuilder<List<ProductModel>>(
        future:
        productsFuture,

        builder:
            (
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
                  MainAxisAlignment.center,

                  children: [
                    const Icon(
                      Icons.error_outline,

                      size:
                      65,

                      color:
                      darkColor,
                    ),

                    const SizedBox(
                      height:
                      16,
                    ),

                    const Text(
                      'Could not load products',

                      style:
                      TextStyle(
                        fontSize:
                        20,

                        fontWeight:
                        FontWeight.w800,
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
                      TextAlign.center,

                      style:
                      const TextStyle(
                        color:
                        greyColor,
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

                        padding:
                        const EdgeInsets.symmetric(
                          horizontal:
                          28,

                          vertical:
                          14,
                        ),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      child:
                      const Text(
                        'Try Again',

                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),

              padding:
              const EdgeInsets.symmetric(
                horizontal:
                20,

                vertical:
                14,
              ),

              child:
              Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

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
                      BorderRadius.circular(
                        16,
                      ),

                      border:
                      Border.all(
                        color:
                        Colors.grey.shade300,
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
                        InputBorder.none,

                        contentPadding:
                        EdgeInsets.symmetric(
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
                    24,
                  ),

                  // =========================
                  // BANNER
                  // =========================

                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.all(
                      22,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      darkColor,

                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),
                    ),

                    child:
                    Row(
                      children: [
                        const Expanded(
                          child:
                          Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,

                            children: [
                              Text(
                                'MAJD JEWELRY',

                                style:
                                TextStyle(
                                  color:
                                  primaryYellow,

                                  fontSize:
                                  13,

                                  fontWeight:
                                  FontWeight.w800,

                                  letterSpacing:
                                  1.3,
                                ),
                              ),

                              SizedBox(
                                height:
                                10,
                              ),

                              Text(
                                'Discover elegance\nin every detail.',

                                style:
                                TextStyle(
                                  color:
                                  Colors.white,

                                  fontSize:
                                  24,

                                  height:
                                  1.25,

                                  fontWeight:
                                  FontWeight.w800,
                                ),
                              ),

                              SizedBox(
                                height:
                                10,
                              ),

                              Text(
                                'Explore our luxury jewelry collection.',

                                style:
                                TextStyle(
                                  color:
                                  Colors.white70,

                                  fontSize:
                                  13,

                                  height:
                                  1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          width:
                          14,
                        ),

                        Container(
                          width:
                          82,

                          height:
                          82,

                          decoration:
                          BoxDecoration(
                            color:
                            primaryYellow,

                            borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                          ),

                          child:
                          const Icon(
                            Icons.diamond_outlined,

                            color:
                            darkColor,

                            size:
                            45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height:
                    28,
                  ),

                  // =========================
                  // PRODUCTS TITLE
                  // =========================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        'Our Products',

                        style:
                        TextStyle(
                          fontSize:
                          21,

                          fontWeight:
                          FontWeight.w800,

                          color:
                          darkColor,
                        ),
                      ),

                      Text(
                        '${allProducts.length} Products',

                        style:
                        const TextStyle(
                          color:
                          greyColor,

                          fontSize:
                          13,

                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                    16,
                  ),

                  // =========================
                  // EMPTY SEARCH
                  // =========================

                  if (products.isEmpty)
                    const Padding(
                      padding:
                      EdgeInsets.symmetric(
                        vertical:
                        60,
                      ),

                      child:
                      Center(
                        child:
                        Column(
                          children: [
                            Icon(
                              Icons.search_off_outlined,

                              size:
                              55,

                              color:
                              greyColor,
                            ),

                            SizedBox(
                              height:
                              12,
                            ),

                            Text(
                              'No products found',

                              style:
                              TextStyle(
                                fontSize:
                                16,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else

                  // =========================
                  // PRODUCTS GRID
                  // =========================

                    GridView.builder(
                      shrinkWrap:
                      true,

                      physics:
                      const NeverScrollableScrollPhysics(),

                      itemCount:
                      products.length,

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

                      itemBuilder:
                          (
                          context,
                          index,
                          ) {
                        final product =
                        products[index];

                        return ProductCard(
                          product:
                          product,

                          token:
                          widget.token,

                          onRefresh:
                          refreshProducts,
                        );
                      },
                    ),

                  const SizedBox(
                    height:
                    25,
                  ),
                ],
              ),
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
        BottomNavigationBarType.fixed,

        currentIndex:
        0,

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
            (index) async {
          // HOME
          if (index ==
              0) {
            return;
          }

          // PRODUCTS
          if (index ==
              1) {
            await openProducts();
          }

          // WISHLIST
          if (index ==
              2) {
            await openWishlist();
          }

          // PROFILE
          if (index ==
              3) {
            await openProfile();
          }
        },

        items:
        const [
          BottomNavigationBarItem(
            icon:
            Icon(
              Icons.home_outlined,
            ),

            activeIcon:
            Icon(
              Icons.home,
            ),

            label:
            'Home',
          ),

          BottomNavigationBarItem(
            icon:
            Icon(
              Icons.grid_view_outlined,
            ),

            activeIcon:
            Icon(
              Icons.grid_view,
            ),

            label:
            'Products',
          ),

          BottomNavigationBarItem(
            icon:
            Icon(
              Icons.favorite_border,
            ),

            activeIcon:
            Icon(
              Icons.favorite,
            ),

            label:
            'Wishlist',
          ),

          BottomNavigationBarItem(
            icon:
            Icon(
              Icons.person_outline,
            ),

            activeIcon:
            Icon(
              Icons.person,
            ),

            label:
            'Profile',
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PRODUCT CARD
// =====================================================

class ProductCard extends StatefulWidget {
  final ProductModel product;

  final String token;

  final Future<void> Function()
  onRefresh;

  const ProductCard({
    super.key,
    required this.product,
    required this.token,
    required this.onRefresh,
  });

  @override
  State<ProductCard> createState() =>
      _ProductCardState();
}

class _ProductCardState
    extends State<ProductCard> {
  static const Color primaryYellow =
  Color(0xFFF5C542);

  static const Color darkColor =
  Color(0xFF111111);

  static const Color greyColor =
  Color(0xFF777777);

  final WishlistService wishlistService =
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
      covariant ProductCard oldWidget,
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

  Future<void> toggleWishlist() async {
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
  // OPEN PRODUCT
  // =========================

  Future<void> openProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
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
            Colors.black.withValues(
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
        CrossAxisAlignment.start,

        children: [
          Expanded(
            child:
            Stack(
              children: [
                Positioned.fill(
                  child:
                  product.thumbnail.isNotEmpty
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
                // FAVORITE
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
                          Colors.black.withValues(
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
                            : Icons.favorite_border,

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

          Padding(
            padding:
            const EdgeInsets.all(
              12,
            ),

            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  product.name,

                  maxLines:
                  2,

                  overflow:
                  TextOverflow.ellipsis,

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
                  product.formattedPrice,

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
                        TextOverflow.ellipsis,

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
                    ElevatedButton.styleFrom(
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