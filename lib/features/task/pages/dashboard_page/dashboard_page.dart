import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animProgress;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animProgress = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadAllTasks();
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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

    // Thống kê theo tuần (7 ngày gần nhất)
    final now = DateTime.now();
    final weeklyData = _buildWeeklyData(allTasks, now);

    return Scaffold(
      body: SafeArea(
        child: taskProvider.isLoading && allTasks.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  await taskProvider.loadAllTasks();
                  _animController.reset();
                  _animController.forward();
                },
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

                    // ═══════════════════════════════════════════
                    // THỐNG KÊ TỔNG QUAN
                    // ═══════════════════════════════════════════
                    _buildSectionTitle(context, 'Thống kê tổng quan',
                        icon: Icons.bar_chart_rounded),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      context,
                      total: totalTasks,
                      completed: completedTasks,
                      incomplete: totalTasks - completedTasks,
                      rate: completionRate,
                    ),
                    const SizedBox(height: AppSizes.xl),

                    // ═══════════════════════════════════════════
                    // THỐNG KÊ THEO NHÓM
                    // ═══════════════════════════════════════════
                    _buildSectionTitle(context, 'Thống kê theo nhóm',
                        icon: Icons.category_rounded),
                    const SizedBox(height: 12),
                    _buildCategoryBreakdown(
                      context,
                      total: totalTasks,
                      myDay: myDayTasks,
                      important: importantTasks,
                      planned: plannedTasks,
                    ),
                    const SizedBox(height: AppSizes.xl),

                    _buildSectionTitle(context, 'Hoàn thành 7 ngày qua',
                        icon: Icons.trending_up_rounded),
                    const SizedBox(height: 12),
                    _buildWeeklyChart(context, weeklyData),
                    const SizedBox(height: AppSizes.xl),

                    // Grid Categories Stats
                    _buildSectionTitle(context, 'Danh mục',
                        icon: Icons.grid_view_rounded),
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
                    _buildSectionTitle(context, 'Tác vụ tiếp theo',
                        icon: Icons.arrow_forward_rounded),
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

  // ═══════════════════════════════════════════════════════════════
  // Section Title Widget
  // ═══════════════════════════════════════════════════════════════
  Widget _buildSectionTitle(BuildContext context, String title,
      {IconData? icon}) {
    final isDark = context.isDarkMode;
    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required int total,
    required int completed,
    required int incomplete,
    required double rate,
  }) {
    final percent = (rate * 100).toInt();

    return AnimatedBuilder(
      animation: _animProgress,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              child: _buildMiniStat(
                context,
                label: 'Tổng',
                value: '$total',
                icon: Icons.assignment_rounded,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStat(
                context,
                label: 'Hoàn thành',
                value: '$completed',
                icon: Icons.check_circle_rounded,
                color: AppColors.checkGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStat(
                context,
                label: 'Chưa xong',
                value: '$incomplete',
                icon: Icons.pending_rounded,
                color: AppColors.myDay,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMiniStat(
                context,
                label: 'Tiến độ',
                value: '$percent%',
                icon: Icons.speed_rounded,
                color: percent >= 70
                    ? AppColors.checkGreen
                    : percent >= 40
                        ? AppColors.myDay
                        : AppColors.important,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color:
                  isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(
    BuildContext context, {
    required int total,
    required int myDay,
    required int important,
    required int planned,
  }) {
    final isDark = context.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: AnimatedBuilder(
        animation: _animProgress,
        builder: (context, _) {
          return Column(
            children: [
              _buildBarRow(
                context,
                label: 'Công việc trong ngày',
                count: myDay,
                total: total,
                color: AppColors.myDay,
                icon: Icons.wb_sunny_rounded,
              ),
              const SizedBox(height: 14),
              _buildBarRow(
                context,
                label: 'Công việc quan trọng',
                count: important,
                total: total,
                color: AppColors.important,
                icon: Icons.star_rounded,
              ),
              const SizedBox(height: 14),
              _buildBarRow(
                context,
                label: 'Đã lên kế hoạch',
                count: planned,
                total: total,
                color: AppColors.planned,
                icon: Icons.calendar_month_rounded,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBarRow(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required Color color,
    required IconData icon,
  }) {
    final isDark = context.isDarkMode;
    final ratio = total > 0 ? count / total : 0.0;
    final animatedRatio = ratio * _animProgress.value;
    final percent = (ratio * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '($percent%)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: animatedRatio,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  List<_DayData> _buildWeeklyData(List tasks, DateTime now) {
    final result = <_DayData>[];
    for (int i = 6; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final dayEnd = day.add(const Duration(days: 1));

      final completedOnDay = tasks.where((t) {
        if (!t.isCompleted || t.completedAt == null) return false;
        return t.completedAt!.isAfter(day) && t.completedAt!.isBefore(dayEnd);
      }).length;

      final createdOnDay = tasks.where((t) {
        return t.createdAt.isAfter(day) && t.createdAt.isBefore(dayEnd);
      }).length;

      result.add(_DayData(
        day: day,
        completed: completedOnDay,
        created: createdOnDay,
      ));
    }
    return result;
  }

  Widget _buildWeeklyChart(BuildContext context, List<_DayData> data) {
    final isDark = context.isDarkMode;
    final maxVal = data.fold<int>(
        1,
        (prev, d) =>
            [prev, d.completed, d.created].reduce((a, b) => a > b ? a : b));

    final totalCompleted = data.fold<int>(0, (sum, d) => sum + d.completed);
    final totalCreated = data.fold<int>(0, (sum, d) => sum + d.created);

    return Container(
      padding: const EdgeInsets.all(16),
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
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          // Legend
          Row(
            children: [
              _buildLegendDot(AppColors.checkGreen, 'Hoàn thành'),
              const SizedBox(width: 16),
              _buildLegendDot(AppColors.primary, 'Tạo mới'),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.checkGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '✓ $totalCompleted  |  + $totalCreated',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Chart bars
          AnimatedBuilder(
            animation: _animProgress,
            builder: (context, _) {
              return SizedBox(
                height: 140,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: data.map((d) {
                    final completedH =
                        (d.completed / maxVal) * 90 * _animProgress.value;
                    final createdH =
                        (d.created / maxVal) * 90 * _animProgress.value;
                    final dayLabel = DateFormat('E', 'vi').format(d.day);
                    final isToday = d.day.isToday;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Values
                            if (d.completed > 0 || d.created > 0)
                              Text(
                                '${d.completed}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.checkGreen,
                                ),
                              ),
                            const SizedBox(height: 2),
                            // Bars
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Completed bar
                                Container(
                                  width: 10,
                                  height: completedH.clamp(2, 90),
                                  decoration: BoxDecoration(
                                    color: AppColors.checkGreen,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                // Created bar
                                Container(
                                  width: 10,
                                  height: createdH.clamp(2, 90),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Day label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? AppColors.primary.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                dayLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isToday
                                      ? AppColors.primary
                                      : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    final isDark = context.isDarkMode;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color:
                isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
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

  // ═══════════════════════════════════════════════════════════════
  // PROGRESS CARD (Tiến độ tổng)
  // ═══════════════════════════════════════════════════════════════
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
          AnimatedBuilder(
            animation: _animProgress,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value:
                          total > 0 ? rate * _animProgress.value : 0,
                      strokeWidth: 6,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.25),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  Text(
                    '${(percent * _animProgress.value).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DayData {
  final DateTime day;
  final int completed;
  final int created;

  const _DayData({
    required this.day,
    required this.completed,
    required this.created,
  });
}
