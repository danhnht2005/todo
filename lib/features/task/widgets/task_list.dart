import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../../task_list/providers/task_list_provider.dart';
import '../../task_list/models/task_list_model.dart';
import '../../../../core/widgets/task_tile.dart';

class TaskList extends StatefulWidget {
  final List<TaskModel> incomplete;
  final List<TaskModel> completed;
  final bool showCreator;

  const TaskList({
    super.key,
    required this.incomplete,
    required this.completed,
    this.showCreator = false,
  });

  @override
  State<TaskList> createState() => TaskListState();
}

class TaskListState extends State<TaskList> {
  bool _showCompleted = false;

  TaskListModel? _listById(BuildContext context, String? listId) {
    if (listId == null) return null;
    try {
      return context
          .read<TaskListProvider>()
          .lists
          .firstWhere((l) => l.id == listId);
    } catch (_) {
      return null;
    }
  }

  String _creatorLabel(TaskModel task, String? currentUserId) {
    final name = task.createdByName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = task.createdByEmail?.trim();
    if (email != null && email.isNotEmpty) return email;

    if (currentUserId != null && task.userId == currentUserId) {
      return 'Bạn';
    }

    return 'Người dùng';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final currentUserId =
        Supabase.instance.client.auth.currentUser?.id;
    return ListView(
      padding: const EdgeInsets.only(top: AppSizes.sm),
      children: [
        ...widget.incomplete.map(
          (task) {
            final list = _listById(context, task.listId);
            final isSharedList = list != null && !list.isOwner;
            final creator = widget.showCreator && isSharedList
                ? _creatorLabel(task, currentUserId)
                : null;

            return TaskTile(
              task: task,
              listName: list?.title,
              creatorLabel: creator,
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
            );
          },
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
              (task) {
                final list = _listById(context, task.listId);
                final isSharedList = list != null && !list.isOwner;
                final creator = widget.showCreator && isSharedList
                    ? _creatorLabel(task, currentUserId)
                    : null;

                return TaskTile(
                  task: task,
                  listName: list?.title,
                  creatorLabel: creator,
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
                );
              },
            ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}


