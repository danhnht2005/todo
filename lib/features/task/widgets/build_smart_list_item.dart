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
  
  final GoRouterState routerState = GoRouterState.of(context);
  final String currentPath = routerState.uri.path;
  final bool isSelected = (currentPath == '/' && routeName == 'dashboard') || 
                           currentPath == '/$routeName';

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.go(routeName == 'dashboard' ? '/' : '/$routeName');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected 
                ? color.withValues(alpha: isDark ? 0.15 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                icon, 
                color: isSelected ? color : (isDark ? Colors.white70 : Colors.black54), 
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? (isDark ? Colors.white : color) 
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
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
