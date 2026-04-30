import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/features/task/providers/task_provider.dart';
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
  late TaskModel _task;
  final _titleController = TextEditingController();
  bool _isEditingTitle = false;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
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
        final updated = provider.tasks.where((t) => t.id == _task.id).toList();
        if (updated.isNotEmpty) {
          _task = updated.first;
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
                    _buildTitleRow(isDark, _saveTitle),

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

  void _saveTitle() {
    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != _task.title) {
      context.read<TaskProvider>().updateTask(
        taskId: _task.id,
        title: newTitle,
      );
    }
    setState(() => _isEditingTitle = false);
  }

  Widget _buildTitleRow(bool isDark, void Function() _saveTitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Checkbox
        GestureDetector(
          onTap: () {
            context.read<TaskProvider>().toggleComplete(
              taskId: _task.id,
              isCompleted: !_task.isCompleted,
            );
          },
          child: Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _task.isCompleted ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: _task.isCompleted
                    ? AppColors.primary
                    : AppColors.textHint,
                width: 1.5,
              ),
            ),
            child: _task.isCompleted
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
                  onSubmitted: (_) => _saveTitle(),
                  onEditingComplete: _saveTitle,
                )
              : GestureDetector(
                  onTap: () {
                    _titleController.text = _task.title;
                    setState(() => _isEditingTitle = true);
                  },
                  child: Text(
                    _task.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                      decoration: _task.isCompleted
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
              taskId: _task.id,
              isImportant: !_task.isImportant,
            );
          },
          child: Icon(
            _task.isImportant ? Icons.star_rounded : Icons.star_outline_rounded,
            color: _task.isImportant
                ? AppColors.starYellow
                : AppColors.textHint,
            size: 24,
          ),
        ),
      ],
    );
  }
}
