import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../home/logic.dart';
import '../home/view.dart';
import '../theme.dart';
import '../customwidgets/message_bubble.dart';
import 'logic.dart';

class StartchatPage extends StatelessWidget {
  final String? initialPrompt;
  final bool fromprompt;

  StartchatPage({Key? key,
    this.initialPrompt,
    this.fromprompt = false,
  }) : super(key: key);

  late final logic = Get.put(
    StartChatLogic(initialPrompt: initialPrompt),
  );

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (logic.isGenerating.value) return;
          if (logic.hasChatted.value) {
            Get.offAll(() => HomePage());
          } else {
            if (fromprompt) {
              Get.back();
            } else {
              Get.back();
            }
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 23, right: 23),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (logic.isGenerating.value) return;

                          if (logic.hasChatted.value) {
                            if (Get.isRegistered<HomeLogic>()) {
                              await Get.find<HomeLogic>().loadRecentSessions();
                            }

                            Get.until((route) => route.isFirst);
                          } else {
                            if (fromprompt) {
                              Get.back();
                            } else {
                              Get.back();
                            }
                          }
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
                              color: appSurfaceColor(context)),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 160,
                        child: Obx(() => Text(
                              logic.session.value.title.value.isEmpty ? 'Untitled chat' : logic.session.value.title.value,
                              style: TextStyle(
                                  color: appTextColor(context),
                                  fontFamily: SfProDisplay,
                                  fontWeight: SfProRegular,
                                  fontSize: 20),
                              overflow: TextOverflow.ellipsis,
                            )),
                      ),
                      const Spacer(),
                      Obx(() {
                        if (logic.session.value.id == null) return const SizedBox.shrink();
                        return Row(
                          children: [
                            InkWell(
                              onTap: logic.isExporting.value ? null : logic.exportToPdf,
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(0, 2))
                                    ],
                                    borderRadius: BorderRadius.circular(30),
                                    color: appSurfaceColor(context)),
                                child: Center(
                                  child: SvgPicture.asset(
                                    'assets/icons/download.svg',
                                    colorFilter: ColorFilter.mode(
                                      appIconColor(context),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                if (logic.isGenerating.value) return;
                                logic.startNewChat();
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: purpleBackground),
                                child: Center(
                                    child: SvgPicture.asset(
                                  'assets/icons/plus.svg',
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                )),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                // ---------------------- Chat messages list ----------------------
                const SizedBox(height: 10),
                Expanded(
                  child: Obx(() {
                    final messages = logic.session.value.messages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Image.asset(
                          'assets/images/emptychat.png',
                          height: 200,
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: logic.scrollController,
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];

                        return MessageBubble(
                          message: msg,
                          isRegenerating: msg.isRegenerating,
                          showRegenerate: true,
                          onCopy: () => logic.copyMessage(msg),
                          onSpeak: () => logic.toggleSpeak(msg),
                          onRegenerate: () => logic.regenerateMessage(msg),
                          onPreviousVersion: () => logic.goToPreviousVersion(msg),
                          onNextVersion: () => logic.goToNextVersion(msg),
                        );
                      },
                    );
                  }),
                ),

                // ---------------------- Text input row ----------------------
                Padding(
                  padding: const EdgeInsets.only(left: 23, right: 23, bottom: 15, top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: appSurfaceColor(context),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextField(
                            minLines: 1,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            controller: logic.textController,
                            decoration: const InputDecoration(
                              hintText: 'Ask anything to AI',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Obx(() => GestureDetector(
                            onTap: logic.isGenerating.value ? logic.stopGenerating : logic.sendMessage,
                            child: Container(
                              height: 45,
                              width: 45,
                              decoration: const BoxDecoration(
                                color: purpleBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  logic.isGenerating.value ? 'assets/icons/stop.svg' : 'assets/icons/send.svg',
                                  height: 20,
                                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                ),
                              ),
                            ),
                          )),
                    ],
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
