import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'build_new_list_button.dart';
import 'build_custom_list_item.dart';
import 'build_smart_list_item.dart';
import 'build_user_header_sidebar.dart';
import '../../task_list/providers/task_list_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../../auth/services/auth_service.dart';

/// Sidebar
class SidebarWidget extends StatefulWidget {
  const SidebarWidget({super.key});

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget> {
  @override
  void initState() {
    super.initState();
    // Load data lần đầu khi vào home
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskListProvider>().loadTaskLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final authRepo = AuthService();

    return Container(
      color: isDark ? AppColors.sidebarDark : AppColors.sidebarLight,
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Header
            buildUserHeaderSideBar(context, isDark, authRepo),
            const SizedBox(height: AppSizes.sm),

            // Smart Lists
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                children: [
                  buildSmartListItem(
                    context: context,
                    icon: Icons.dashboard_rounded,
                    title: 'Tổng quan',
                    color: AppColors.primary,
                    routeName: 'dashboard',
                  ),
                  buildSmartListItem(
                    context: context,
                    icon: Icons.wb_sunny_rounded,
                    title: 'My Day',
                    color: AppColors.myDay,
                    routeName: 'my-day',
                  ),
                  buildSmartListItem(
                    context: context,
                    icon: Icons.star_rounded,
                    title: 'Quan trọng',
                    color: AppColors.important,
                    routeName: 'important',
                  ),
                  buildSmartListItem(
                    context: context,
                    icon: Icons.calendar_month_rounded,
                    title: 'Đã lên kế hoạch',
                    color: AppColors.planned,
                    routeName: 'planned',
                  ),
                  buildSmartListItem(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'Tác vụ',
                    color: AppColors.allTasks,
                    routeName: 'all-tasks',
                  ),

                  // Divider
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    child: Divider(
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                    ),
                  ),

                  // Custom Lists Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.lg,
                      vertical: AppSizes.xs,
                    ),
                    child: Text(
                      'Danh sách của tôi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Custom Lists
                  Consumer<TaskListProvider>(
                    builder: (context, taskListProvider, child) {
                      final lists = taskListProvider.lists;
                      if (lists.isNotEmpty) {
                        return Column(
                          children: lists
                              .map(
                                (list) => buildCustomListItem(
                                  context: context,
                                  list: list,
                                ),
                              )
                              .toList(),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),

            // New List Button
            Padding(
              padding: const EdgeInsets.all(AppSizes.sm),
              child: buildNewListButton(context, isDark),
            ),
          ],
        ),
      ),
    );
  }
}
