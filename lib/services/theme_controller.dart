import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'isDarkMode';
  final GetStorage _storage = GetStorage();
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  @override
  void onInit() {
    super.onInit();
    final savedIsDark = _storage.read<bool>(_themeKey);
    themeMode.value = savedIsDark == true ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    final isDark = themeMode.value != ThemeMode.dark;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    _storage.write(_themeKey, isDark);
  }
}
