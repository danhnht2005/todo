import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/task_list.dart';
import '../../../../core/widgets/add_task_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../providers/task_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';

/// AllTasksPage
class AllTasksPage extends StatefulWidget {
  const AllTasksPage({super.key});

  @override
  State<AllTasksPage> createState() => _AllTasksPageState();
}

class _AllTasksPageState extends State<AllTasksPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Header
            const _AllTasksHeader(),

            // Task List
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
                            onPressed: () => provider.loadTasks(),
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
                      icon: Icons.task_outlined,
                      title: 'Không có tác vụ nào',
                      subtitle: 'Các tác vụ của bạn sẽ hiển thị ở đây.',
                      iconColor: AppColors.allTasks,
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
              context.read<TaskProvider>().addTask(title: title);
            },
            accentColor: AppColors.allTasks,
          ),
        ),
      ],
    );
  }
}

class _AllTasksHeader extends StatelessWidget {
  const _AllTasksHeader();

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
            AppColors.allTasks.withValues(alpha: isDark ? 0.2 : 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_rounded, color: AppColors.allTasks, size: 28),
          const SizedBox(width: AppSizes.md),
          Text(
            'All Tasks',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
