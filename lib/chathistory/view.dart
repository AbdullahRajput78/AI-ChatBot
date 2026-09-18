import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../startchat/logic.dart';
import '../startchat/view.dart';
import '../theme.dart';
import 'logic.dart';

class ChathistoryPage extends StatelessWidget {
  ChathistoryPage({Key? key}) : super(key: key);

  final ChathistoryLogic logic = Get.put(ChathistoryLogic());

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
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 23, right: 23, top: 10),
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
                          color: appSurfaceColor(context),
                        ),
                        child: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Chat History',
                      style: TextStyle(
                        color: appTextColor(context),
                        fontFamily: SfProDisplay,
                        fontWeight: SfProRegular,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    Obx(() {
                      if (logic.groupedSessions.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return GestureDetector(
                        onTap: () => logic.showClearAllDialog(context, logic),
                        child: const Text(
                          'All Clear',
                          style: TextStyle(
                            color: textColorRed,
                            fontFamily: SfProDisplay,
                            fontWeight: SfProRegular,
                            fontSize: 16,
                          ),
                        ),
                      );
                    })
                  ],
                ),
                SizedBox(height: height * 0.02),
                Expanded(
                  child: Obx(() {
                    if (logic.isLoadingSessions.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (logic.groupedSessions.isEmpty) {
                      return Center(
                        child: Image.asset('assets/images/historyempty.png', height: 230),
                      );
                    }

                    final dateLabels = logic.groupedSessions.keys.toList();

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: dateLabels.length,
                      itemBuilder: (context, groupIndex) {
                        final label = dateLabels[groupIndex];
                        final sessionsForDate = logic.groupedSessions[label]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: groupIndex == 0 ? 0 : height * 0.02, bottom: 8),
                              child: Text(
                                label,
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ),
                            ...sessionsForDate.map((sessionRow) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: () {
                                          final chatLogic = Get.put(StartChatLogic());
                                          chatLogic.loadSession(sessionRow['id'] as int);
                                          Get.to(() => StartchatPage());
                                        },
                                        child: Container(
                                          height: height * 0.055,
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: appSurfaceColor(context),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Text(
                                            sessionRow['title'] as String,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: appTextColor(context),
                                              fontFamily: 'SfProDisplay',
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => logic.showRenameDialog(context, logic, sessionRow),
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: appAccentContainerColor(context),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/edit.svg',
                                            height: 17,
                                            colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => logic.showDeleteDialog(
                                        sessionRow['id'] as int,
                                      ),
                                      child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          color: appSurfaceColor(context),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: SvgPicture.asset(
                                            'assets/icons/delete.svg',
                                            height: 17,
                                            colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
