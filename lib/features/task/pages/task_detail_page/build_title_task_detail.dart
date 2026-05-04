import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';

class BuildTitleTaskDetail extends StatefulWidget {
  final TaskModel task;
  const BuildTitleTaskDetail({super.key, required this.task});

  @override
  State<BuildTitleTaskDetail> createState() => _BuildTitleTaskDetailState();
}

class _BuildTitleTaskDetailState extends State<BuildTitleTaskDetail> {
  final _titleController = TextEditingController();
  bool _isEditingTitle = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveTitle(TaskModel task) {
    final newTitle = _titleController.text.trim();
    if (newTitle.isNotEmpty && newTitle != task.title) {
      context.read<TaskProvider>().updateTask(taskId: task.id, title: newTitle);
    }
    setState(() => _isEditingTitle = false);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = context.isDarkMode;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Checkbox
        IconButton(
          icon: Icon(
            task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
            color: task.isCompleted ? AppColors.checkGreen : Colors.grey,
          ),
          onPressed: () {
            context.read<TaskProvider>().toggleComplete(
              taskId: task.id,
              isCompleted: !task.isCompleted,
            );
          },
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
        IconButton(
          icon: Icon(
            task.isImportant ? Icons.star : Icons.star_border,
            color: task.isImportant ? AppColors.starYellow : AppColors.textHint,
          ),
          onPressed: () {
            context.read<TaskProvider>().toggleImportant(
              taskId: task.id,
              isImportant: !task.isImportant,
            );
          },
        ),
      ],
    );
  }
}
