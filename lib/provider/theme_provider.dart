import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_chat_app/utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  Color color = themeColors[Random().nextInt(8)];
  bool language = true;
  String get whatLanguage => language ? 'es' : 'en';

  void changeLanguage() {
    language = !language;
    notifyListeners();
  }

  void changeColor(int colorIndex) {
    color = themeColors[colorIndex];
    notifyListeners();
  }

  bool get isLightMode => themeMode == ThemeMode.light;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
