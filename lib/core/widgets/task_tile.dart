import 'package:flutter/material.dart';
import '../../features/task/models/task_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/extensions.dart';
import 'confirm_delete_dialog.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onToggle;
  final VoidCallback onToggleImportant;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onToggleImportant,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSizes.lg),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      // Hiện dialog xác nhận trước khi xóa;
      // trả về true → xóa, false → tile snap back
      confirmDismiss: (_) async {
        bool confirmed = false;
        await showConfirmDeleteDialog(
          context: context,
          title: 'Xóa tác vụ?',
          content:
              '"${task.title}" sẽ bị xóa vĩnh viễn. Bạn không thể hoàn tác hành động này.',
          onConfirmed: () => confirmed = true,
        );
        return confirmed;
      },
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: 4,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.md,
                  vertical: 6,
                ),
                child: Row(
                  children: [
                    // Checkbox
                    IconButton(
                      icon: Icon(
                        task.isCompleted
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: task.isCompleted
                            ? AppColors.checkGreen
                            : Colors.grey,
                      ),
                      onPressed: onToggle,
                    ),
                    const SizedBox(width: AppSizes.xs),
                    // Task Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? AppColors.textHint
                                  : (isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary),
                            ),
                          ),
                          if (task.totalStepCount > 0)
                            Text(
                              '${task.completedStepCount} của ${task.totalStepCount}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textHint,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Important Star
                    IconButton(
                      icon: Icon(
                        task.isImportant ? Icons.star : Icons.star_border,
                        color: task.isImportant
                            ? AppColors.starYellow
                            : AppColors.textHint,
                      ),
                      onPressed: onToggleImportant,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
