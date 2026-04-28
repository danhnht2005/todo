import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/task/widgets/task_list.dart';
import '../../../core/widgets/add_task_bar.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../features/task/providers/task_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../features/task/providers/task_provider.dart';
import '../../../features/task/widgets/task_list.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';

/// PlannedPage — Trang hiển thị task có due date
class PlannedPage extends StatefulWidget {
  const PlannedPage({super.key});

  @override
  State<PlannedPage> createState() => _PlannedPageState();
}

class _PlannedPageState extends State<PlannedPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(hasDueDate: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _PlannedHeader(),

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
                      Text(provider.errorMessage!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.loadTasks(hasDueDate: true),
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
                  icon: Icons.calendar_month_outlined,
                  title: 'Không có task đã lên kế hoạch',
                  subtitle:
                      'Thêm công việc bạn muốn hoàn thành hôm nay.\nNhấn + ở bên dưới để bắt đầu.',
                  iconColor: AppColors.planned,
                );
              }

              return TaskList(incomplete: incomplete, completed: completed);
            },
          ),
        ),
      ],
    );
  }
}

class _PlannedHeader extends StatelessWidget {
  const _PlannedHeader();

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
            AppColors.planned.withValues(alpha: isDark ? 0.2 : 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_rounded,
            color: AppColors.planned,
            size: 28,
          ),
          const SizedBox(width: AppSizes.md),
          Text(
            'Đã lên kế hoạch',
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
