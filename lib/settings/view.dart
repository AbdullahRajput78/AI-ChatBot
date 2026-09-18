import 'package:chatbot/theme.dart';
import 'package:chatbot/services/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Obx(() => Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, left: 20),
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
                              color: appSurfaceColor(context),
                            ),
                            child: const Icon(Icons.arrow_back),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: appTextColor(context),
                            fontFamily: SfProDisplay,
                            fontWeight: SfProRegular,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //--------------------------- 2nd list of all settings -------------
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 20),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/restore2.svg',
                              colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                            ),
                            title: Text(
                              'Restore ',
                              style: TextStyle(
                                color: appTextColor(context),
                                fontFamily: SfProDisplay,
                                fontWeight: SfProRegular,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, top: 6),
                          child: ListTile(
                            leading: Icon(Icons.dark_mode_outlined, color: Theme.of(context).colorScheme.onSurfaceVariant),
                            title: Text(
                              'Dark Mode',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontFamily: SfProDisplay,
                                fontWeight: SfProRegular,
                                fontSize: 18,
                              ),
                            ),
                            trailing: Switch(
                              value: themeController.themeMode.value == ThemeMode.dark,
                              onChanged: (_) => themeController.toggleTheme(),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, top: 6),
                          child: ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/help.svg',
                              colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                            ),
                            title: Text(
                              'Help ',
                              style: TextStyle(
                                color: appTextColor(context),
                                fontFamily: SfProDisplay,
                                fontWeight: SfProRegular,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, top: 6),
                          child: ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/rateus.svg',
                              colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                            ),
                            title: Text(
                              'Rate Us ',
                              style: TextStyle(
                                color: appTextColor(context),
                                fontFamily: SfProDisplay,
                                fontWeight: SfProRegular,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, top: 6),
                          child: ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/support.svg',
                              colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                            ),
                            title: Text(
                              'Support ',
                              style: TextStyle(
                                color: appTextColor(context),
                                fontFamily: SfProDisplay,
                                fontWeight: SfProRegular,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, top: 6),
                          child: ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/moreapps.svg',
                              colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                            ),
                            title: Text(
                              'More Apps',
                              style: TextStyle(
                                color: appTextColor(context),
                                fontFamily: SfProDisplay,
                                fontWeight: SfProRegular,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, top: 6),
                          child: ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/termsandconditions.svg',
                              colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                            ),
                            title: Text(
                              'Terms & Conditions',
                              style: TextStyle(
                                color: appTextColor(context),
                                fontFamily: SfProDisplay,
                                fontWeight: SfProRegular,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 18, top: 6),
                          child: ListTile(
                            leading: SvgPicture.asset(
                              'assets/icons/privacypolicy.svg',
                              colorFilter: ColorFilter.mode(appIconColor(context), BlendMode.srcIn),
                            ),
                            title: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                color: appTextColor(context),
                                fontFamily: SfProDisplay,
                                fontWeight: SfProRegular,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 20, endIndent: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
