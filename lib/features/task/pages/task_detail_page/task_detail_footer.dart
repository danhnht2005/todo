import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class TaskDetailFooter extends StatelessWidget {
  final TaskModel task;
  const TaskDetailFooter({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormatter.createdAt(task.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
          ),
        ),
        IconButton(
          onPressed: () {
            showConfirmDeleteDialog(
              context: context,
              title: 'Xóa tác vụ?',
              content:
                  '"${task.title}" sẽ bị xóa vĩnh viễn. Bạn không thể hoàn tác hành động này.',
              onConfirmed: () {
                context.read<TaskProvider>().deleteTask(task.id);
                context.pop();
              },
            );
          },
          icon: const Icon(Icons.delete_outline_rounded, size: 22),
        ),
      ],
    );
  }
}
