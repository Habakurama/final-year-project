// lib/controller/theme_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  // Observable theme mode, default to light
  var themeMode = ThemeMode.light.obs;

  // Change theme mode and notify listeners
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
  }

  // Toggle between light and dark themes
  void toggleTheme() {
    if (themeMode.value == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else {
      setThemeMode(ThemeMode.light);
    }
  }
}
