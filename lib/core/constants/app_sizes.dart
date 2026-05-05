import 'package:flutter/material.dart';

class AppSizes {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 40.0;
  static const double xxxl = 48.0;

  static const double avatarSize = 48.0;

  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  static const double iconMd = 24.0;
  static const double iconXl = 32.0;

  static double sidebarWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width * 0.75;
  }

  static double dialogWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width * 0.8;
  }
}
