import 'package:flutter/material.dart';

import '../services/profile_service.dart';

import 'cart_screen.dart';
import 'wishlist_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String token;

  const ProfileScreen({
    super.key,
    required this.token,
  });

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {
  static const Color primaryYellow =
  Color(0xFFF5C542);

  static const Color darkColor =
  Color(0xFF111111);

  static const Color backgroundColor =
  Color(0xFFF7F7F7);

  static const Color greyColor =
  Color(0xFF777777);

  final ProfileService profileService =
  ProfileService();

  late Future<Map<String, dynamic>>
  profileFuture;

  @override
  void initState() {
    super.initState();

    loadProfile();
  }

  void loadProfile() {
    profileFuture =
        profileService.getProfile(
          token: widget.token,
        );
  }

  Future<void> refreshProfile() async {
    setState(() {
      loadProfile();
    });

    await profileFuture;
  }

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
  }

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
  }

  @override
  Widget build(BuildContext context) {
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
          'Profile',

          style: TextStyle(
            fontWeight:
            FontWeight.w800,
          ),
        ),
      ),

      body:
      FutureBuilder<Map<String, dynamic>>(
        future:
        profileFuture,

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
              child:
              Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),

                child:
                Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [
                    const Icon(
                      Icons
                          .person_off_outlined,

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
                      'Could not load profile',

                      style:
                      TextStyle(
                        fontSize:
                        19,

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
                            loadProfile();
                          },
                        );
                      },

                      style:
                      ElevatedButton.styleFrom(
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

          final profile =
              snapshot.data ?? {};

          final String name =
              profile['name']
                  ?.toString() ??
                  '';

          final String email =
              profile['email']
                  ?.toString() ??
                  '';

          final String phone =
              profile['phone']
                  ?.toString() ??
                  '';

          final String username =
              profile['username']
                  ?.toString() ??
                  '';

          final String image =
              profile['image']
                  ?.toString() ??
                  '';

          return RefreshIndicator(
            color:
            primaryYellow,

            onRefresh:
            refreshProfile,

            child:
            SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),

              padding:
              const EdgeInsets.fromLTRB(
                20,
                15,
                20,
                30,
              ),

              child:
              Column(
                children: [
                  // =========================
                  // PROFILE HEADER
                  // =========================

                  Container(
                    width:
                    double.infinity,

                    padding:
                    const EdgeInsets.all(
                      24,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      Colors.white,

                      borderRadius:
                      BorderRadius.circular(
                        22,
                      ),

                      border:
                      Border.all(
                        color:
                        Colors.grey.shade200,
                      ),
                    ),

                    child:
                    Column(
                      children: [
                        Container(
                          width:
                          100,

                          height:
                          100,

                          decoration:
                          BoxDecoration(
                            color:
                            primaryYellow
                                .withValues(
                              alpha:
                              0.15,
                            ),

                            shape:
                            BoxShape.circle,

                            border:
                            Border.all(
                              color:
                              primaryYellow,

                              width:
                              2,
                            ),
                          ),

                          child:
                          ClipOval(
                            child:
                            image.isNotEmpty
                                ? Image.network(
                              image,

                              fit:
                              BoxFit.cover,

                              errorBuilder:
                                  (
                                  context,
                                  error,
                                  stackTrace,
                                  ) {
                                return const Icon(
                                  Icons.person,

                                  size:
                                  55,

                                  color:
                                  darkColor,
                                );
                              },
                            )
                                : const Icon(
                              Icons.person,

                              size:
                              55,

                              color:
                              darkColor,
                            ),
                          ),
                        ),

                        const SizedBox(
                          height:
                          16,
                        ),

                        Text(
                          name.isNotEmpty
                              ? name
                              : 'User',

                          textAlign:
                          TextAlign.center,

                          style:
                          const TextStyle(
                            color:
                            darkColor,

                            fontSize:
                            22,

                            fontWeight:
                            FontWeight.w800,
                          ),
                        ),

                        if (email.isNotEmpty) ...[
                          const SizedBox(
                            height:
                            6,
                          ),

                          Text(
                            email,

                            style:
                            const TextStyle(
                              color:
                              greyColor,

                              fontSize:
                              13,
                            ),
                          ),
                        ],

                        if (phone.isNotEmpty) ...[
                          const SizedBox(
                            height:
                            4,
                          ),

                          Text(
                            phone,

                            style:
                            const TextStyle(
                              color:
                              greyColor,

                              fontSize:
                              13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(
                    height:
                    22,
                  ),

                  // =========================
                  // ACCOUNT INFORMATION
                  // =========================

                  _sectionTitle(
                    'Account',
                  ),

                  const SizedBox(
                    height:
                    10,
                  ),

                  _infoTile(
                    icon:
                    Icons.person_outline,

                    title:
                    'Name',

                    value:
                    name.isNotEmpty
                        ? name
                        : 'Not available',
                  ),

                  _infoTile(
                    icon:
                    Icons
                        .alternate_email,

                    title:
                    'Username',

                    value:
                    username.isNotEmpty
                        ? username
                        : 'Not available',
                  ),

                  _infoTile(
                    icon:
                    Icons.email_outlined,

                    title:
                    'Email',

                    value:
                    email.isNotEmpty
                        ? email
                        : 'Not available',
                  ),

                  _infoTile(
                    icon:
                    Icons.phone_outlined,

                    title:
                    'Phone',

                    value:
                    phone.isNotEmpty
                        ? phone
                        : 'Not available',
                  ),

                  const SizedBox(
                    height:
                    22,
                  ),

                  // =========================
                  // SHOPPING
                  // =========================

                  _sectionTitle(
                    'Shopping',
                  ),

                  const SizedBox(
                    height:
                    10,
                  ),

                  _menuTile(
                    icon:
                    Icons.favorite_border,

                    title:
                    'My Wishlist',

                    onTap:
                    openWishlist,
                  ),

                  _menuTile(
                    icon:
                    Icons
                        .shopping_bag_outlined,

                    title:
                    'My Cart',

                    onTap:
                    openCart,
                  ),

                  _menuTile(
                    icon:
                    Icons
                        .location_on_outlined,

                    title:
                    'My Addresses',

                    onTap:
                        () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content:
                          Text(
                            'Addresses screen will be added next.',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height:
                    22,
                  ),

                  // =========================
                  // SETTINGS
                  // =========================

                  _sectionTitle(
                    'Settings',
                  ),

                  const SizedBox(
                    height:
                    10,
                  ),

                  _menuTile(
                    icon:
                    Icons.edit_outlined,

                    title:
                    'Edit Profile',

                    onTap:
                        () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content:
                          Text(
                            'Edit Profile will be added next.',
                          ),
                        ),
                      );
                    },
                  ),

                  _menuTile(
                    icon:
                    Icons
                        .lock_outline,

                    title:
                    'Change Password',

                    onTap:
                        () {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content:
                          Text(
                            'Change Password will be added later.',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height:
                    22,
                  ),

                  // =========================
                  // LOGOUT
                  // =========================

                  SizedBox(
                    width:
                    double.infinity,

                    child:
                    OutlinedButton.icon(
                      onPressed:
                          () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content:
                            Text(
                              'Logout will be connected after token storage.',
                            ),
                          ),
                        );
                      },

                      style:
                      OutlinedButton.styleFrom(
                        foregroundColor:
                        Colors.red,

                        side:
                        const BorderSide(
                          color:
                          Colors.red,
                        ),

                        padding:
                        const EdgeInsets.symmetric(
                          vertical:
                          16,
                        ),

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),

                      icon:
                      const Icon(
                        Icons.logout,
                      ),

                      label:
                      const Text(
                        'Logout',

                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================
  // SECTION TITLE
  // =========================

  Widget _sectionTitle(
      String title,
      ) {
    return Align(
      alignment:
      Alignment.centerLeft,

      child:
      Text(
        title,

        style:
        const TextStyle(
          color:
          darkColor,

          fontSize:
          18,

          fontWeight:
          FontWeight.w800,
        ),
      ),
    );
  }

  // =========================
  // INFO TILE
  // =========================

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom:
        10,
      ),

      padding:
      const EdgeInsets.all(
        15,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          15,
        ),

        border:
        Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),

      child:
      Row(
        children: [
          Container(
            width:
            42,

            height:
            42,

            decoration:
            BoxDecoration(
              color:
              primaryYellow
                  .withValues(
                alpha:
                0.16,
              ),

              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),

            child:
            Icon(
              icon,

              color:
              darkColor,

              size:
              21,
            ),
          ),

          const SizedBox(
            width:
            13,
          ),

          Expanded(
            child:
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                  const TextStyle(
                    color:
                    greyColor,

                    fontSize:
                    11,

                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(
                  height:
                  3,
                ),

                Text(
                  value,

                  style:
                  const TextStyle(
                    color:
                    darkColor,

                    fontSize:
                    14,

                    fontWeight:
                    FontWeight.w700,
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
  // MENU TILE
  // =========================

  Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom:
        10,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          15,
        ),

        border:
        Border.all(
          color:
          Colors.grey.shade200,
        ),
      ),

      child:
      ListTile(
        onTap:
        onTap,

        leading:
        Container(
          width:
          42,

          height:
          42,

          decoration:
          BoxDecoration(
            color:
            primaryYellow
                .withValues(
              alpha:
              0.16,
            ),

            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),

          child:
          Icon(
            icon,

            color:
            darkColor,

            size:
            21,
          ),
        ),

        title:
        Text(
          title,

          style:
          const TextStyle(
            color:
            darkColor,

            fontSize:
            14,

            fontWeight:
            FontWeight.w700,
          ),
        ),

        trailing:
        const Icon(
          Icons.chevron_right,

          color:
          greyColor,
        ),
      ),
    );
  }
}