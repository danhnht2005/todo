import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/task/widgets/task_list.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/task_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';

/// ImportantPage — Trang hiển thị task quan trọng
class ImportantPage extends StatefulWidget {
  const ImportantPage({super.key});

  @override
  State<ImportantPage> createState() => _ImportantPageState();
}

class _ImportantPageState extends State<ImportantPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(isImportant: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _ImportantHeader(),

        // Task List
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

              return TaskList(incomplete: incomplete, completed: completed);
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
        ],
      ),
    );
  }
}
