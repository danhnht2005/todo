import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../../task_list/providers/task_list_provider.dart';
import '../../../../core/widgets/task_tile.dart';

class TaskList extends StatefulWidget {
  final List<TaskModel> incomplete;
  final List<TaskModel> completed;

  const TaskList({
    super.key,
    required this.incomplete,
    required this.completed,
  });

  @override
  State<TaskList> createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  bool _showCompleted = false;

  String? _listName(BuildContext context, String? listId) {
    if (listId == null) return null;
    try {
      return context
          .read<TaskListProvider>()
          .lists
          .firstWhere((l) => l.id == listId)
          .title;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return ListView(
      padding: const EdgeInsets.only(top: AppSizes.sm),
      children: [
        ...widget.incomplete.map(
          (task) => TaskTile(
            task: task,
            listName: _listName(context, task.listId),
            onToggle: () => context.read<TaskProvider>().toggleComplete(
              taskId: task.id,
              isCompleted: !task.isCompleted,
            ),
            onToggleImportant: () =>
                context.read<TaskProvider>().toggleImportant(
                  taskId: task.id,
                  isImportant: !task.isImportant,
                ),
            onDelete: () => context.read<TaskProvider>().deleteTask(task.id),
            onTap: () => context.push('/task/${task.id}'),
          ),
        ),
        if (widget.completed.isNotEmpty) ...[
          const SizedBox(height: AppSizes.sm),
          InkWell(
            onTap: () => setState(() => _showCompleted = !_showCompleted),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.lg,
                vertical: AppSizes.md,
              ),
              child: Row(
                children: [
                  Icon(
                    _showCompleted
                        ? Icons.expand_more_rounded
                        : Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSizes.sm),
                  Text(
                    'Đã hoàn thành (${widget.completed.length})',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_showCompleted)
            ...widget.completed.map(
              (task) => TaskTile(
                task: task,
                listName: _listName(context, task.listId),
                onToggle: () => context.read<TaskProvider>().toggleComplete(
                  taskId: task.id,
                  isCompleted: !task.isCompleted,
                ),
                onToggleImportant: () =>
                    context.read<TaskProvider>().toggleImportant(
                      taskId: task.id,
                      isImportant: !task.isImportant,
                    ),
                onDelete: () =>
                    context.read<TaskProvider>().deleteTask(task.id),
                onTap: () => context.push('/task/${task.id}'),
              ),
            ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}


