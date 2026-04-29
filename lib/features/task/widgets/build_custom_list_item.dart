import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/features/task_list/models/task_list_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';

Widget buildCustomListItem({
  required BuildContext context,
  required TaskListModel list,
}) {
  final isDark = context.isDarkMode;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 1),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          context.go('/custom-list/${list.id}');
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              Icon(Icons.list, color: AppColors.customList),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  list.title,
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
