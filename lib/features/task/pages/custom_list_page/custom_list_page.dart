import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../task_list/providers/task_list_provider.dart';
import '../../../../core/widgets/add_task_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../widgets/task_list.dart';
import '../../providers/task_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';

class CustomListPage extends StatefulWidget {
  final String id;

  const CustomListPage({super.key, required this.id});

  @override
  State<CustomListPage> createState() => _CustomListPageState();
}

class _CustomListPageState extends State<CustomListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(covariant CustomListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _loadData();
    }
  }

  void _loadData() {
    context.read<TaskProvider>().loadTasks(listId: widget.id);
    context.read<TaskListProvider>().loadTaskListDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // ─── Header ───
            _CustomListHeader(),

            // ─── Task List ───
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage!,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                provider.loadTasks(listId: widget.id),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final incomplete = provider.tasks
                      .where((t) => !t.isCompleted)
                      .toList();
                  final completed = provider.tasks
                      .where((t) => t.isCompleted)
                      .toList();

                  if (incomplete.isEmpty && completed.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.folder_open_rounded,
                      title: 'Không có tác vụ trong danh sách này',
                      subtitle: 'Hãy thử thêm một số tác vụ để xem chúng ở đây',
                      iconColor: AppColors.primary,
                    );
                  }

                  return TaskList(incomplete: incomplete, completed: completed);
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 50,
          child: AddTaskBar(
            onSubmit: (title) {
              context.read<TaskProvider>().addTask(
                title: title,
                listId: widget.id,
              );
            },
            accentColor: AppColors.customList,
          ),
        ),
      ],
    );
  }
}

class _CustomListHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Consumer<TaskListProvider>(
      builder: (context, provider, child) {
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
                AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.list_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  provider.selectedTaskList?.title ?? 'Danh sách tùy chỉnh',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
