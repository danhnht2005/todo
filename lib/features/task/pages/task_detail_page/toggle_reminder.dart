import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class ToggleReminder extends StatefulWidget {
  final TaskModel task;
  const ToggleReminder({super.key, required this.task});

  @override
  State<ToggleReminder> createState() => _ToggleReminderState();
}

class _ToggleReminderState extends State<ToggleReminder> {
  /// Mở date picker → time picker, lưu vào reminderAt
  Future<void> _pickReminder() async {
    final now = DateTime.now();
    final current = widget.task.reminderAt;

    // Bước 1: Chọn ngày
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      helpText: 'Chọn ngày nhắc nhở',
      cancelText: 'Hủy',
      confirmText: 'Tiếp theo',
    );
    if (pickedDate == null || !mounted) return;

    // Bước 2: Chọn giờ
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: current != null
          ? TimeOfDay.fromDateTime(current)
          : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      helpText: 'Chọn giờ nhắc nhở',
      cancelText: 'Hủy',
      confirmText: 'Xác nhận',
    );
    if (pickedTime == null || !mounted) return;

    final reminder = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    context.read<TaskProvider>().updateTask(
          taskId: widget.task.id,
          reminderAt: reminder.toIso8601String(),
        );
  }

  void _clearReminder() {
    context.read<TaskProvider>().updateTask(
          taskId: widget.task.id,
          clearReminderAt: true,
        );
  }

  String _formatReminder(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeStr = DateFormat('HH:mm').format(dateTime);

    if (dateOnly == today) return 'Hôm nay, $timeStr';
    if (dateOnly == tomorrow) return 'Ngày mai, $timeStr';
    return '${DateFormat('dd/MM/yyyy').format(dateTime)}, $timeStr';
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = context.isDarkMode;
    final isActive = task.reminderAt != null;
    final color = isActive
        ? AppColors.primary
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickReminder,
        onLongPress: isActive ? _clearReminder : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              Icon(
                isActive
                    ? Icons.notifications_active
                    : Icons.notifications_none_outlined,
                color: color,
                size: 22,
              ),
              const SizedBox(width: AppSizes.lg),
              Expanded(
                child: Text(
                  isActive
                      ? 'Nhắc nhở ${_formatReminder(task.reminderAt!)}'
                      : 'Thêm lời nhắc',
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
