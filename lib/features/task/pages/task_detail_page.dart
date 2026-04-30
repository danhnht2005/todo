import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../models/task_model.dart';

/// TaskDetailPage — Bottom sheet chi tiết task
class TaskDetailPage extends StatefulWidget {
  final TaskModel task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      height: context.screenHeight * 0.78,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.dividerDark : AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(child: Center(child: Text("Chi tiết task"))),
        ],
      ),
    );
  }
}
