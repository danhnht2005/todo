import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../providers/task_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../../core/widgets/task_tile.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadAllTasks();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour < 18) {
      return 'Chào buổi chiều';
    } else {
      return 'Chào buổi tối';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authProvider = context.watch<AuthProvider>();
    final taskProvider = context.watch<TaskProvider>();

    final String name = authProvider.displayName ?? authProvider.email ?? 'Bạn';
    final allTasks = taskProvider.tasks;
    final totalTasks = allTasks.length;
    final completedTasks = allTasks.where((t) => t.isCompleted).length;
    final incompleteTasks = allTasks.where((t) => !t.isCompleted).toList();
    final completionRate = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    final myDayTasks = allTasks.where((t) => t.isMyDay).length;
    final importantTasks = allTasks.where((t) => t.isImportant).length;
    final plannedTasks = allTasks.where((t) => t.dueDate != null).length;

    return Scaffold(
      body: SafeArea(
        child: taskProvider.isLoading && allTasks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => taskProvider.loadAllTasks(),
                child: ListView(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  children: [
                    // Header Greeting
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_getGreeting()},',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$name! 👋',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Progress Ring Card
                    _buildProgressCard(
                      context,
                      completedTasks,
                      totalTasks,
                      completionRate,
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Grid Categories Stats
                    Text(
                      'Danh mục',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.35,
                      children: [
                        _buildStatCard(
                          context: context,
                          title: 'My Day',
                          icon: Icons.wb_sunny_rounded,
                          color: AppColors.myDay,
                          count: myDayTasks,
                          onTap: () => context.go('/my-day'),
                        ),
                        _buildStatCard(
                          context: context,
                          title: 'Quan trọng',
                          icon: Icons.star_rounded,
                          color: AppColors.important,
                          count: importantTasks,
                          onTap: () => context.go('/important'),
                        ),
                        _buildStatCard(
                          context: context,
                          title: 'Đã lên kế hoạch',
                          icon: Icons.calendar_month_rounded,
                          color: AppColors.planned,
                          count: plannedTasks,
                          onTap: () => context.go('/planned'),
                        ),
                        _buildStatCard(
                          context: context,
                          title: 'Tác vụ',
                          icon: Icons.home_rounded,
                          color: AppColors.allTasks,
                          count: totalTasks,
                          onTap: () => context.go('/all-tasks'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // Next Tasks
                    Text(
                      'Tác vụ tiếp theo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (incompleteTasks.isEmpty) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 44,
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tuyệt vời! Không có việc gì sắp tới.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: incompleteTasks.length > 3
                            ? 3
                            : incompleteTasks.length,
                        itemBuilder: (context, index) {
                          final task = incompleteTasks[index];
                          return TaskTile(
                            task: task,
                            onToggle: () =>
                                context.read<TaskProvider>().toggleComplete(
                                  taskId: task.id,
                                  isCompleted: !task.isCompleted,
                                ),
                            onToggleImportant: () =>
                                context.read<TaskProvider>().toggleImportant(
                                  taskId: task.id,
                                  isImportant: !task.isImportant,
                                ),
                            onDelete: () => context
                                .read<TaskProvider>()
                                .deleteTask(task.id),
                            onTap: () => context.push('/task/${task.id}'),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    int completed,
    int total,
    double rate,
  ) {
    final isDark = context.isDarkMode;
    final percent = (rate * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E3C72).withValues(alpha: 0.8),
                  const Color(0xFF2A5298).withValues(alpha: 0.8),
                ]
              : [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiến độ công việc',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  total > 0
                      ? 'Bạn đã hoàn thành $completed/$total tác vụ.'
                      : 'Không có tác vụ nào cần làm.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  total > 0
                      ? (percent == 100
                            ? 'Tuyệt vời! Bạn đã hoàn thành hết! 🎉'
                            : 'Cố gắng lên nhé! 💪')
                      : 'Bắt đầu thêm tác vụ nào!',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: total > 0 ? rate : 0,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
