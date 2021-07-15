import 'package:flutter/material.dart';

class AppColors {
  static var primary = Colors.teal.shade400;
  static var primaryDark = Colors.teal.shade500;
  static var darkText = Colors.teal.shade900;
  static var lightGrey = Colors.grey.shade300;
  static var medGrey = Colors.grey.shade400;
  static var darkGrey = Colors.grey.shade600;
  static var accent = Colors.orange.shade800;
  static var accentLight = Color(0xAAEC833B);
  static var star = Colors.yellow.shade700;
  static var noHover = Colors.white.withOpacity(0);
}

class AppStyles {
  static var header = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static var subtitle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.darkGrey,
      height: 1.2);
}
