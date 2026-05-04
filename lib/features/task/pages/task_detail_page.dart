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
  bool _isEditingTitle = false;

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
                    _buildTitleRow(isDark, provider.task!),

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

  void _saveTitle(TaskModel task) {
    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != task.title) {
      context.read<TaskProvider>().updateTask(taskId: task.id, title: newTitle);
    }
    setState(() => _isEditingTitle = false);
  }

  Widget _buildTitleRow(bool isDark, TaskModel task) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox
        GestureDetector(
          onTap: () {
            context.read<TaskProvider>().toggleComplete(
              taskId: task.id,
              isCompleted: !task.isCompleted,
            );
          },
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: task.isCompleted
                    ? AppColors.primary
                    : AppColors.textHint,
                width: 1.5,
              ),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: AppSizes.md),
        // Title — tap to edit
        Expanded(
          child: _isEditingTitle
              ? TextField(
                  controller: _titleController,
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                  onSubmitted: (_) => _saveTitle(task),
                  onEditingComplete: () => _saveTitle(task),
                )
              : GestureDetector(
                  onTap: () {
                    _titleController.text = task.title;
                    setState(() => _isEditingTitle = true);
                  },
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ),
        ),
        // Star
        GestureDetector(
          onTap: () {
            context.read<TaskProvider>().toggleImportant(
              taskId: task.id,
              isImportant: !task.isImportant,
            );
          },
          child: Icon(
            task.isImportant ? Icons.star_rounded : Icons.star_outline_rounded,
            color: task.isImportant ? AppColors.starYellow : AppColors.textHint,
            size: 24,
          ),
        ),
      ],
    );
  }
}
