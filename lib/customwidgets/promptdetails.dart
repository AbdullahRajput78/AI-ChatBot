import 'package:chatbot/startchat/view.dart';
import 'package:chatbot/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../startchat/logic.dart';

class PromptDetailsView extends StatelessWidget {
  final Map<String, dynamic> item;

  const PromptDetailsView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final List prompts = item['prompts'];
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 20),
                child: Row(
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
                      '${item['name']}',
                      style: TextStyle(
                        color: appTextColor(context),
                        fontFamily: SfProDisplay,
                        fontWeight: SfProRegular,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: prompts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      child: GestureDetector(
                        onTap: () {
                          Get.delete<StartChatLogic>(force: true);
                          Get.to(() => StartchatPage(
                                initialPrompt: prompts[index],
                                fromprompt: true,
                              ));
                        },
                        child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: appContainerColor(context),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              prompts[index],
                              style: TextStyle(
                                color: appTextColor(context),
                                fontFamily: 'SfProDisplay',
                                fontWeight: SfProRegular,
                                fontSize: 14,
                              ),
                            )),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
