import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

Widget buildLabel(String text, bool isDark) {
  return Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
    ),
  );
}
