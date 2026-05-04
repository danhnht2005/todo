import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/features/task/providers/task_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../models/task_model.dart';

/// TaskDetailPage — Bottom sheet chi tiết task
class TaskDetailPage extends StatefulWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TaskProvider>().loadTaskDetail(widget.taskId);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.task == null) {
          return Container(
            height: context.screenHeight * 0.78,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSizes.radiusXl),
              ),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

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

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.xxl),
                  children: [
                    // Task Title + Checkbox
                    Text(provider.task!.title),
                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
