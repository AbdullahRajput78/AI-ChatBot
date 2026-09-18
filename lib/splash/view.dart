import 'package:chatbot/home/view.dart';
import 'package:chatbot/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SplashLogic logic = Get.put(SplashLogic());

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.off(() => HomePage());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/splash1.png',
              height: height * 0.27,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/splash2.png',
              height: height * 0.25,
            ),
          ),
          Center(
            child: Text(
              'Chatbot',
              style: TextStyle(
                fontFamily: SfProDisplay,
                fontSize: 50,
                fontWeight: SfProBold,
                color: textColorLavender,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
