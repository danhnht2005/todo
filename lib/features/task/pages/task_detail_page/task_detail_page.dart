import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo/features/task/providers/task_provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/utils/extensions.dart';
import '../../models/task_model.dart';

/// TaskDetailPage — Bottom sheet chi tiết task
class TaskDetailPage extends StatefulWidget {
  final String id;

  const TaskDetailPage({super.key, required this.id});

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
        context.read<TaskProvider>().loadTaskDetail(widget.id);
      }
    });
  }

  @override
  void dispose() {
    context.read<TaskProvider>().clearTaskDetail();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.xxl,
                    AppSizes.xs,
                    AppSizes.xxl,
                    AppSizes.xs,
                  ),
                  children: [
                    // Task Title + Checkbox
                    _buildTitleRow(isDark, provider.task!),

                    const SizedBox(height: AppSizes.xl),
                  ],
                ),
              ),
            ],
          );
        },
      ),
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
