import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../task_list/providers/task_list_provider.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

Widget buildNewListButton(BuildContext context, bool isDark) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        _showCreateListDialog(context);
      },
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_rounded,
              color: AppColors.primary,
              size: AppSizes.iconMd,
            ),
            const SizedBox(width: AppSizes.md),
            Text(
              'Danh sách mới',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void _showCreateListDialog(BuildContext context) {
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      final isDark = ctx.isDarkMode;

      return AlertDialog(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          'Danh sách mới',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        content: SizedBox(
          width: AppSizes.dialogWidth(context),
          child: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Nhập tiêu đề danh sách',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Hủy bỏ',
              style: TextStyle(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isEmpty) {
                BotToast.showText(
                  text: 'Tiêu đề danh sách không được để trống',
                  align: const Alignment(0, 0.8),
                );
                return;
              }
              context.read<TaskListProvider>().createTaskList(
                title: title,
              );
              Navigator.pop(ctx);
              BotToast.showText(
                text: 'Đã tạo danh sách: $title',
                align: const Alignment(0, 0.8),
              );
            },
            child: const Text(
              'Tạo danh sách',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      );
    },
  );
}
