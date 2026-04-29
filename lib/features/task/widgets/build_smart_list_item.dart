import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import 'package:go_router/go_router.dart';

Widget buildSmartListItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required Color color,
  required String routeName,
}) {
  final isDark = context.isDarkMode;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.go('/$routeName');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: AppSizes.iconMd),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
