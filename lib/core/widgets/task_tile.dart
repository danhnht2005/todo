import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  /// Tên của custom list mà task thuộc về. Nếu null → hiển thị "Tác vụ"
  final String? listName;

  const TaskTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onToggleImportant,
    required this.onDelete,
    required this.onTap,
    this.listName,
  });

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hôm nay';
    if (dateOnly == tomorrow) return 'Ngày mai';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    // ─── Build metadata chips ───
    final metaParts = <_MetaItem>[];

    if (task.isMyDay) {
      metaParts.add(
        _MetaItem(icon: Icons.wb_sunny_rounded, label: 'Ngày của tôi'),
      );
    }

    metaParts.add(
      _MetaItem(icon: Icons.home_rounded, label: listName ?? 'Tác vụ'),
    );

    if (task.dueDate != null) {
      metaParts.add(
        _MetaItem(
          icon: Icons.calendar_today_outlined,
          label: _formatDueDate(task.dueDate!),
        ),
      );
    }

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
                          // ─── Metadata row ───
                          const SizedBox(height: 2),
                          _MetaRow(parts: metaParts, isDark: isDark),
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

// ─── Internal helper types ───

class _MetaItem {
  final IconData icon;
  final String label;

  const _MetaItem({required this.icon, required this.label});
}

class _MetaRow extends StatelessWidget {
  final List<_MetaItem> parts;
  final bool isDark;

  const _MetaRow({required this.parts, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (parts.isEmpty) return const SizedBox.shrink();

    final separator = Text(
      ' • ',
      style: TextStyle(
        fontSize: 11,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
      ),
    );

    final widgets = <Widget>[];
    for (int i = 0; i < parts.length; i++) {
      final item = parts[i];
      widgets.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 11),
            const SizedBox(width: 3),
            Text(
              item.label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      );
      if (i < parts.length - 1) widgets.add(separator);
    }

    return Row(children: widgets);
  }
}
