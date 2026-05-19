import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../../task_list/models/task_list_model.dart';

Widget buildCustomListItem({
  required BuildContext context,
  required TaskListModel list,
}) {
  final isDark = context.isDarkMode;
  
  final GoRouterState routerState = GoRouterState.of(context);
  final String currentPath = routerState.uri.path;
  final bool isSelected = currentPath == '/custom-list/${list.id}';

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.go('/custom-list/${list.id}');
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
                ? AppColors.customList.withValues(alpha: isDark ? 0.15 : 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                Icons.list_rounded, 
                color: isSelected ? AppColors.customList : (isDark ? Colors.white70 : Colors.black54),
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  list.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? (isDark ? Colors.white : AppColors.customList) 
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
