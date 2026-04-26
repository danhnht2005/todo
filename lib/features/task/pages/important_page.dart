import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/features/task/models/task_model.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/task_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../../../../core/widgets/task_tile.dart';

/// ImportantPage — Trang hiển thị task quan trọng
class ImportantPage extends StatelessWidget {
  const ImportantPage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<TaskProvider>().loadTasks(isImportant: true);

    return Column(
      children: [
        // Header
        _ImportantHeader(),

        Expanded(
          child: Consumer<TaskProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.errorMessage != null) {
                return Center(child: Text(provider.errorMessage!));
              }

              final incomplete = provider.tasks
                  .where((t) => !t.isCompleted)
                  .toList();
              final completed = provider.tasks
                  .where((t) => t.isCompleted)
                  .toList();

              if (incomplete.isEmpty && completed.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.star_outline_rounded,
                  title: 'Không có task quan trọng',
                  subtitle: 'Đánh dấu ⭐ để thêm task vào đây.',
                  iconColor: AppColors.important,
                );
              }

              return _ImportantTaskList(
                incomplete: incomplete,
                completed: completed,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ImportantHeader extends StatelessWidget {
  const _ImportantHeader();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.xxl,
        AppSizes.lg,
        AppSizes.xxl,
        AppSizes.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.important.withValues(alpha: isDark ? 0.2 : 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColors.important, size: 28),
          const SizedBox(width: AppSizes.md),
          Text(
            'Quan trọng',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            color: Colors.black,
            surfaceTintColor: Colors.transparent,
            onSelected: (String value) {
              if (value == 'edit-active') {
                // Xử lý khi chọn "Chặn trên lịch"
              } else if (value == 'delete') {
                // Xử lý khi chọn "Xóa danh mục"
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit-active',
                child: Text(
                  'Chặn trên lịch',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Text(
                  'Xóa danh mục',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImportantTaskList extends StatefulWidget {
  final List<TaskModel> incomplete;
  final List<TaskModel> completed;
  const _ImportantTaskList({required this.incomplete, required this.completed});

  @override
  State<_ImportantTaskList> createState() => _ImportantTaskListState();
}

class _ImportantTaskListState extends State<_ImportantTaskList> {
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return ListView(
      padding: const EdgeInsets.only(top: AppSizes.sm),
      children: [
        ...widget.incomplete.map(
          (task) => TaskTile(
            task: task,
            accentColor: AppColors.important,
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
            onTap: () => {},
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
                accentColor: AppColors.important,
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
                onTap: () => {},
              ),
            ),
        ],
        const SizedBox(height: 100),
      ],
    );
  }
}
