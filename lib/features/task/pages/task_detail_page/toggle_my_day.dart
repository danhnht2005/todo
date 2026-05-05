import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class ToggleMyDay extends StatefulWidget {
  final TaskModel task;
  const ToggleMyDay({super.key, required this.task});

  @override
  State<ToggleMyDay> createState() => _ToggleMyDayState();
}

class _ToggleMyDayState extends State<ToggleMyDay> {
  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = context.isDarkMode;
    final isActive = task.isMyDay;
    final color = isActive
        ? AppColors.primary
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.read<TaskProvider>().toggleMyDay(
            taskId: task.id,
            isMyDay: !task.isMyDay,
          );
        },
        onLongPress: isActive
            ? () {
                context.read<TaskProvider>().toggleMyDay(
                  taskId: task.id,
                  isMyDay: false,
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              Icon(
                isActive ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                color: color,
                size: 22,
              ),
              const SizedBox(width: AppSizes.lg),
              Expanded(
                child: Text(
                  isActive
                      ? 'Đã thêm vào Ngày của tôi'
                      : 'Thêm vào Ngày của tôi',
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
