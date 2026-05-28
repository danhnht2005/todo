import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/add_task_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../widgets/task_list.dart';
import '../../providers/task_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/extensions.dart';

class MyDayPage extends StatefulWidget {
  const MyDayPage({super.key});

  @override
  State<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks(isMyDay: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            // Header
            _MyDayHeader(),

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
                            onPressed: () => provider.loadTasks(isMyDay: true),
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
                      icon: Icons.wb_sunny_outlined,
                      title: 'Không có tác vụ trong ngày của tôi',
                      subtitle:
                          'Tác vụ bạn muốn hoàn thành hôm nay sẽ hiện ở đây.',
                      iconColor: AppColors.myDay,
                    );
                  }

                  return TaskList(incomplete: incomplete, completed: completed);
                },
              ),
            ),

            // Add Task Bar
          ],
        ),
        Positioned(
          right: 20,
          bottom: 50,
          child: AddTaskBar(
            onSubmit: (title) {
              context.read<TaskProvider>().addTask(title: title, isMyDay: true);
            },
            accentColor: AppColors.myDay,
          ),
        ),
      ],
    );
  }
}

class _MyDayHeader extends StatelessWidget {
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
            AppColors.myDay.withValues(alpha: isDark ? 0.2 : 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_rounded,
                color: AppColors.myDay,
                size: 28,
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                'My Day',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormatter.fullDate(DateTime.now()),
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
