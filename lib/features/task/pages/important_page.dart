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
class ImportantPage extends StatefulWidget {
  const ImportantPage({super.key});

  @override
  State<ImportantPage> createState() => _ImportantPageState();
}

class _ImportantPageState extends State<ImportantPage> {
  bool showCompleted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(isImportant: true);
    });
  }

  void _toggleShowCompleted() {
    setState(() {
      showCompleted = !showCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _ImportantHeader(
          showCompleted: showCompleted,
          onToggleShowCompleted: _toggleShowCompleted,
        ),

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
                showCompleted: showCompleted,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ImportantHeader extends StatelessWidget {
  final bool showCompleted;
  final VoidCallback onToggleShowCompleted;

  const _ImportantHeader({
    required this.showCompleted,
    required this.onToggleShowCompleted,
  });

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
              if (value == 'sort') {
                // Xử lý khi chọn "Sắp xếp"
              } else if (value == 'toggle_completed') {
                onToggleShowCompleted();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'sort',
                child: Text('Sắp xếp', style: TextStyle(color: Colors.white)),
              ),
              PopupMenuItem<String>(
                value: 'toggle_completed',
                child: Text(
                  showCompleted ? 'Ẩn task hoàn thành' : 'Hiện task hoàn thành',
                  style: const TextStyle(color: Colors.white),
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
  final bool showCompleted;
  const _ImportantTaskList({
    required this.incomplete,
    required this.completed,
    required this.showCompleted,
  });

  @override
  State<_ImportantTaskList> createState() => _ImportantTaskListState();
}

class _ImportantTaskListState extends State<_ImportantTaskList> {
  @override
  Widget build(BuildContext context) {
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
        if (widget.showCompleted)
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
              onDelete: () => context.read<TaskProvider>().deleteTask(task.id),
              onTap: () => {},
            ),
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}
