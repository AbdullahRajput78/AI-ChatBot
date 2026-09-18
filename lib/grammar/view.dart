import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../theme.dart';
import 'logic.dart';

class GrammarPage extends StatelessWidget {
  GrammarPage({Key? key}) : super(key: key);

  final GrammarLogic logic = Get.put(GrammarLogic());

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
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
          final shouldPop = await logic.onBackPressed();
          if (shouldPop) Get.back();
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 23, right: 23, bottom: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final shouldPop = await logic.onBackPressed();
                          if (shouldPop) Get.back();
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
                        'Grammar',
                        style: TextStyle(
                          color: appTextColor(context),
                          fontFamily: SfProDisplay,
                          fontWeight: SfProRegular,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Obx(() {
                      return Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => logic.switchMode(true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: 48,
                                decoration: BoxDecoration(
                                  color: logic.isChecker.value ? purpleBackground : appAccentContainerColor(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "Checker",
                                    style: TextStyle(
                                      color: logic.isChecker.value ? Colors.white : purpleBackground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => logic.switchMode(false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                height: 48,
                                decoration: BoxDecoration(
                                  color: !logic.isChecker.value ? purpleBackground : appAccentContainerColor(context),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    "Enhancer",
                                    style: TextStyle(
                                      color: !logic.isChecker.value ? appAccentContainerColor(context) : purpleBackground,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  SizedBox(height: height * 0.02),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(color: appSurfaceColor(context), borderRadius: BorderRadius.circular(15)),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: logic.textController,
                                      maxLines: null,
                                      expands: true,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Write your text here",
                                      ),
                                      onChanged: (value) {
                                        logic.characterCount.value = value.length;
                                      },
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Obx(() => Text(
                                        "${logic.characterCount.value}/10000",
                                        style: const TextStyle(color: Colors.grey),
                                      )),
                                      const Spacer(),
                                      Obx(() => ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: appAccentContainerColor(context),
                                          foregroundColor: purpleBackground,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: logic.isLoading.value
                                            ? null
                                            : () {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                          logic.performAction();
                                        },
                                        child: logic.isLoading.value
                                            ? SpinKitThreeBounce(color: purpleBackground, size: 16)
                                            : Text(logic.isChecker.value ? "Check" : "Enhance"),
                                      )),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Divider(color: Colors.grey.shade300),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Your Result",
                                style: TextStyle(
                                  fontFamily: SfProDisplay,
                                  fontWeight: SfProMedium,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height * 0.017),
                          Expanded(
                            flex: 3,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Obx(() => SingleChildScrollView(
                                      child: Text(
                                        logic.result.value,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    )),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Obx(() {
                                        if (logic.result.value.isEmpty) return const SizedBox();
                                        return GestureDetector(
                                          onTap: () => logic.copyResult(),
                                          child: SvgPicture.asset(
                                            logic.copied.value ? 'assets/icons/copied.svg' : 'assets/icons/copy.svg',
                                            height: 20,
                                            colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
