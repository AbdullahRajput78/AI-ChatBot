import 'package:chatbot/essay_letter/view.dart';
import 'package:chatbot/grammar/view.dart';
import 'package:chatbot/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'logic.dart';

class AitoolsPage extends StatelessWidget {
  AitoolsPage({Key? key}) : super(key: key);

  final AitoolsLogic logic = Get.put(AitoolsLogic());

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              offset: const Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(30),
                          color: appContainerColor(context),
                        ),
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI Tools',
                      style: TextStyle(
                        color: appTextColor(context),
                        fontFamily: SfProDisplay,
                        fontWeight: SfProRegular,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),

                //-------------------------- Row 1 Essay writing  -----------------------
                SizedBox(height: height * 0.026),
                GestureDetector(
                  onTap: () {
                    Get.to(Essay_letterPage(title: 'Essay Writing', subtitle: 'Essay'));
                  },
                  child: Container(
                    height: height * 0.13,
                    decoration: BoxDecoration(
                      color: appAccentContainerColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 13),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: height * 0.075,
                              width: width * 0.16,
                              decoration: BoxDecoration(
                                color: purpleBackground,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/essay.svg',
                                  height: height * 0.038,
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Essay Writing',
                                        style: TextStyle(
                                          color: appTextColor(context),
                                          fontFamily: 'SfProDisplay',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
                                        ),
                                      ),
                                      Container(
                                        height: height * 0.030,
                                        width: width * 0.070,
                                        decoration: BoxDecoration(
                                          color: purpleBackground,
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/upperrightarrow.svg',
                                            height: height * 0.017,
                                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Generate well-organized, insightful essays on various topics.',
                                      style: TextStyle(
                                        color: appTextColor(context),
                                        fontFamily: 'SfProDisplay',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                //---------------------------- Row 2 letter  -----------------------
                SizedBox(height: height * 0.015),
                GestureDetector(
                  onTap: () {
                    Get.to(Essay_letterPage(title: 'Letter Writing', subtitle: 'Letter'));
                  },
                  child: Container(
                    height: height * 0.13,
                    decoration: BoxDecoration(
                      color: appAccentContainerColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 13),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: height * 0.075,
                              width: width * 0.16,
                              decoration: BoxDecoration(
                                color: purpleBackground,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/letter.svg',
                                  height: height * 0.038,
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Letter Writing',
                                        style: TextStyle(
                                          color: appTextColor(context),
                                          fontFamily: 'SfProDisplay',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
                                        ),
                                      ),
                                      Container(
                                        height: height * 0.030,
                                        width: width * 0.070,
                                        decoration: BoxDecoration(
                                          color: purpleBackground,
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/upperrightarrow.svg',
                                            height: height * 0.017,
                                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Generate well-organized, insightful essays on various topics.',
                                      style: TextStyle(
                                        color: appTextColor(context),
                                        fontFamily: 'SfProDisplay',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                //---------------------------- Row 3 Grammar  -----------------------
                SizedBox(height: height * 0.015),
                GestureDetector(
                  onTap: () {
                    Get.to(GrammarPage());
                  },
                  child: Container(
                    height: height * 0.13,
                    decoration: BoxDecoration(
                      color: appAccentContainerColor(context),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14, right: 13),
                      child: Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: height * 0.075,
                              width: width * 0.16,
                              decoration: BoxDecoration(
                                color: purpleBackground,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/grammar.svg',
                                  height: height * 0.038,
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Grammar',
                                        style: TextStyle(
                                          color: appTextColor(context),
                                          fontFamily: 'SfProDisplay',
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
                                        ),
                                      ),
                                      Container(
                                        height: height * 0.030,
                                        width: width * 0.070,
                                        decoration: BoxDecoration(
                                          color: purpleBackground,
                                          borderRadius: BorderRadius.circular(36),
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/upperrightarrow.svg',
                                            height: height * 0.017,
                                            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  SizedBox(
                                    width: 180,
                                    child: Text(
                                      'Smarter Writing Starts with Better Grammar.',
                                      style: TextStyle(
                                        color: appTextColor(context),
                                        fontFamily: 'SfProDisplay',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
