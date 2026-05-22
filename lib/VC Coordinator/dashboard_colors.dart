import 'package:flutter/material.dart';

class DashboardColors {
  static const Color surface = Color(0xFFF3F4F6);
  static const Color darkSurface = Color(0xFF0B1220);
  static const Color darkCard = Color(0xFF111827);
  static const Color darkBorder = Color(0xFF26354D);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkMutedText = Color(0xFFAAB6C7);
  static const Color top = Color(0xFF0B1F3A);
  static const Color sidebar = Color(0xFF0F172A);
  static const Color text = Color(0xFF0F172A);
  static const Color red = Color(0xFF2552C2);
  static const Color blue = Color(0xFF2D65D7);
  static const Color border = Color(0xFFD9DFF0);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color pageSurface(BuildContext context) =>
      isDark(context) ? darkSurface : surface;

  static Color cardSurface(BuildContext context) =>
      isDark(context) ? darkCard : Colors.white;

  static Color borderFor(BuildContext context) =>
      isDark(context) ? darkBorder : border;

  static Color textFor(BuildContext context) =>
      isDark(context) ? darkText : text;

  static Color mutedTextFor(BuildContext context) =>
      isDark(context) ? darkMutedText : const Color(0xFF5D6B82);
}
