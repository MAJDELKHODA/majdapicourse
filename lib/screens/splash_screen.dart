import 'dart:async';

import 'package:flutter/material.dart';

import '../auth/login_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  static const Color primaryYellow =
  Color(0xFFF5C542);

  static const Color darkColor =
  Color(0xFF111111);

  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
          () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const LoginScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      darkColor,

      body:
      SafeArea(
        child:
        Center(
          child:
          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 30,
            ),

            child:
            Column(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [
                Container(
                  width:
                  110,

                  height:
                  110,

                  decoration:
                  BoxDecoration(
                    color:
                    primaryYellow,

                    borderRadius:
                    BorderRadius.circular(
                      30,
                    ),
                  ),

                  child:
                  const Icon(
                    Icons.diamond_outlined,

                    color:
                    darkColor,

                    size:
                    62,
                  ),
                ),

                const SizedBox(
                  height:
                  28,
                ),

                const Text(
                  'Gold Jewelry Majd',

                  textAlign:
                  TextAlign.center,

                  style:
                  TextStyle(
                    color:
                    Colors.white,

                    fontSize:
                    28,

                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height:
                  10,
                ),

                const Text(
                  'Timeless elegance, made for you',

                  textAlign:
                  TextAlign.center,

                  style:
                  TextStyle(
                    color:
                    Colors.white70,

                    fontSize:
                    14,

                    fontWeight:
                    FontWeight.w400,
                  ),
                ),

                const SizedBox(
                  height:
                  45,
                ),

                const SizedBox(
                  width:
                  26,

                  height:
                  26,

                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2.5,

                    color:
                    primaryYellow,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}