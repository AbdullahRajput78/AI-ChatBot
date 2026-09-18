import 'package:chatbot/aitools/view.dart';
import 'package:chatbot/chathistory/view.dart';
import 'package:chatbot/customwidgets/promptdetails.dart';
import 'package:chatbot/essay_letter/view.dart';
import 'package:chatbot/prompts/view.dart';
import 'package:chatbot/settings/view.dart';
import 'package:chatbot/startchat/view.dart';
import 'package:chatbot/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../essay_letter/logic.dart';
import '../prompts/logic.dart';
import '../startchat/logic.dart';
import 'logic.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final HomeLogic logic = Get.put(HomeLogic());
  final PromptsLogic promptlogic = Get.put(PromptsLogic());

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
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 23, right: 23, top: 10, bottom: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //-------------------------- Row 1 hi chatbot -----------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Hi, I’m\n',
                                style: TextStyle(
                                  fontFamily: 'SfProDisplay',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 36,
                                  color: appTextColor(context),
                                ),
                              ),
                              TextSpan(
                                text: 'Chatbot',
                                style: TextStyle(
                                  color: textColorLavender,
                                  fontFamily: 'SfProDisplay',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 36,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(
                              SettingsPage(),
                              transition: Transition.leftToRight,
                              duration: const Duration(milliseconds: 300),
                            );
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(0, 1),
                                ),
                              ],
                              borderRadius: BorderRadius.circular(30),
                              color: appSurfaceColor(context),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/menu.svg',
                                height: 30,
                                colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            Get.delete<StartChatLogic>(force: true);
                            await Get.to(() => StartchatPage());
                          },
                          child: Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: purpleBackground),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/plus.svg',
                                height: 30,
                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),

                //---------------------  ---- Row 2 Ai tools ----------------------------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Tools ',
                      style: TextStyle(
                        color: appTextColor(context),
                        fontFamily: SfProDisplay,
                        fontWeight: SfProBold,
                        fontSize: 35,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(AitoolsPage());
                      },
                      child: Text(
                        'See All',
                        style: TextStyle(
                          color: appTextColor(context),
                          fontFamily: SfProDisplay,
                          fontWeight: SfProRegular,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                //---------------------------- Row 3  essay  -----------------------
                SizedBox(height: height * 0.006),
                GestureDetector(
                  onTap: () {
                    Get.delete<Essay_letterlogic>(force: true);
                    Get.to(() => Essay_letterPage(title: 'Essay Writing', subtitle: 'Essay'));
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
                                  Text(
                                    'Generate well-organized, insightful essays on various topics.',
                                    style: TextStyle(
                                      color: appTextColor(context),
                                      fontFamily: 'SfProDisplay',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
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

                //----------------------------- Row 4 letter  -----------------------
                SizedBox(height: height * 0.01),
                GestureDetector(
                  onTap: () {
                    Get.delete<Essay_letterlogic>(force: true);
                    Get.to(() => Essay_letterPage(title: 'Letter Writing', subtitle: 'Letter'));
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
                                  Text(
                                    'Generate well-organized, insightful essays on various topics.',
                                    style: TextStyle(
                                      color: appTextColor(context),
                                      fontFamily: 'SfProDisplay',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
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

                //-------------------------- row 5 popular prompts -----------------
                SizedBox(height: height * 0.02),
                Container(
                  height: height * 0.18,
                  decoration: BoxDecoration(
                    color: homeSectionColor(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Popular Prompt',
                              style: TextStyle(
                                color: appTextColor(context),
                                fontFamily: 'SfProDisplay',
                                fontWeight: SfProRegular,
                                fontSize: 20,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Get.to(PromptsPage());
                              },
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  color: appTextColor(context),
                                  fontFamily: 'SfProDisplay',
                                  fontWeight: SfProRegular,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Row(
                            children: List.generate(4, (index) {
                              final item = promptlogic.prompts[index];
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: GestureDetector(
                                    onTap: () {
                                      Get.to(PromptDetailsView(item: item));
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: homeInnerColor(context),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            item['emoji'],
                                            style: const TextStyle(fontSize: 28),
                                          ),
                                          Text(
                                            item['name'],
                                            style: TextStyle(
                                              color: appTextColor(context),
                                              fontFamily: 'SfProDisplay',
                                              fontWeight: FontWeight.w400,
                                              fontSize: 17,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                //------------------------- row 6 chat history  -----------------------
                SizedBox(height: height * 0.02),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: homeSectionColor(context),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'History',
                                style: TextStyle(
                                  color: appTextColor(context),
                                  fontFamily: 'SfProDisplay',
                                  fontWeight: SfProMedium,
                                  fontSize: 22,
                                ),
                              ),
                              const Spacer(),
                              Obx(() {
                                if (logic.recentSessions.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(ChathistoryPage());
                                  },
                                  child: Text(
                                    'See All',
                                    style: TextStyle(
                                      color: appTextColor(context),
                                      fontFamily: 'SfProDisplay',
                                      fontWeight: SfProRegular,
                                      fontSize: 13,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                          Expanded(
                            child: Obx(() {
                              if (logic.recentSessions.isEmpty) {
                                return Center(
                                  child: SizedBox(
                                    height: 110,
                                    width: 110,
                                    child: Image.asset(
                                      'assets/images/historyemptyhome.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: logic.recentSessions.length,
                                itemBuilder: (context, index) {
                                  final sessionRow = logic.recentSessions[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: GestureDetector(
                                      onTap: () async {
                                        Get.delete<StartChatLogic>(force: true);
                                        final chatLogic = Get.put(StartChatLogic());
                                        await chatLogic.loadSession(sessionRow['id'] as int);
                                        await Get.to(() => StartchatPage());
                                        logic.loadRecentSessions(); // refresh Home list on return
                                      },
                                      child: Container(
                                        height: height * 0.045,
                                        decoration: BoxDecoration(
                                          color: homeInnerColor(context),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: width * 0.36,
                                                child: Text(
                                                  sessionRow['title'] as String,
                                                  style: TextStyle(
                                                    color: appTextColor(context),
                                                    fontFamily: 'SfProDisplay',
                                                    fontWeight: SfProRegular,
                                                    fontSize: 14,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () => _showRenameDialog(context, logic, sessionRow),
                                                    child: SvgPicture.asset(
                                                      'assets/icons/edit.svg',
                                                      height: 17,
                                                      colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  GestureDetector(
                                                    onTap: () => logic.showDeleteDialog(sessionRow['id'] as int),
                                                    child: SvgPicture.asset(
                                                      'assets/icons/delete.svg',
                                                      height: 17,
                                                      colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _showRenameDialog(BuildContext context, HomeLogic logic, Map<String, dynamic> sessionRow) {
  final controller = TextEditingController(text: sessionRow['title'] as String);
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Rename chat'),
      content: TextField(controller: controller, autofocus: true),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        TextButton(
          onPressed: () {
            logic.renameSession(sessionRow['id'] as int, controller.text);
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
