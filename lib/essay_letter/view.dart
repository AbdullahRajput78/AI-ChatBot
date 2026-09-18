import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../theme.dart';
import '../customwidgets/message_bubble.dart';
import 'logic.dart';

class Essay_letterPage extends StatelessWidget {
  final String title;
  final String? subtitle;

  Essay_letterPage({Key? key, required this.title, required this.subtitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Essay_letterlogic logic = Get.put(Essay_letterlogic(title), tag: title);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          final shouldLeave = await logic.onBackPressed();
          if (shouldLeave) {
            Get.back();
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 15, left: 23, right: 23),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final shouldLeave = await logic.onBackPressed();
                          if (shouldLeave) {
                            Get.back();
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
                            color: appSurfaceColor(context),
                          ),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          color: appTextColor(context),
                          fontFamily: SfProDisplay,
                          fontWeight: SfProRegular,
                          fontSize: 22,
                        ),
                      ),
                      const Spacer(),
                      Obx(() {
                        if (!logic.hasSuccessfulResponse.value) return const SizedBox.shrink();
                        return GestureDetector(
                          onTap: logic.isExporting.value ? null : logic.exportToPdf,
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
                              color: appSurfaceColor(context),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/download.svg',
                                colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                              ),
                            ),
                          ),
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
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/essay_letterempty.png', height: 170),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: 190,
                                child: Text(
                                  'Let AI write your $subtitle perfectly and instantly',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: appTextColor(context),
                                    fontFamily: 'SfProDisplay',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
                          showRegenerate: false,
                          showSpeak: false,
                          onCopy: () => logic.copyMessage(msg),
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
