import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class ToggleDueDate extends StatefulWidget {
  final TaskModel task;
  const ToggleDueDate({super.key, required this.task});

  @override
  State<ToggleDueDate> createState() => _ToggleDueDateState();
}

class _ToggleDueDateState extends State<ToggleDueDate> {
  void _pickDueDate() async {
    final task = widget.task;
    final picked = await showDatePicker(
      context: context,
      initialDate: task.dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null && mounted) {
      final dateStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      context.read<TaskProvider>().updateTask(
        taskId: task.id,
        dueDate: dateStr,
      );
    }
  }

  void _clearDueDate() {
    context.read<TaskProvider>().updateTask(
      taskId: widget.task.id,
      clearDueDate: true,
    );
  }

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
    final task = widget.task;
    final isDark = context.isDarkMode;
    final isActive = task.dueDate != null;
    final color = isActive
        ? AppColors.primary
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickDueDate,
        onLongPress: isActive ? _clearDueDate : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              Icon(
                isActive
                    ? Icons.calendar_today
                    : Icons.calendar_today_outlined,
                color: color,
                size: 22,
              ),
              const SizedBox(width: AppSizes.lg),
              Expanded(
                child: Text(
                  isActive
                      ? 'Đến hạn ${_formatDueDate(task.dueDate!)}'
                      : 'Thêm ngày đến hạn',
                  style: TextStyle(
                    fontSize: 14.5,
                    color: color,
                    fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              if (isActive)
                Icon(
                  Icons.close_rounded,
                  color: color.withValues(alpha: 0.5),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
