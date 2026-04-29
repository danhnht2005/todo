import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'build_custom_list_item.dart';
import 'build_smart_list_item.dart';
import 'build_user_header_sidebar.dart';
import '../../task_list/providers/task_list_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/providers/auth_provider.dart';

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
            buildUserHeaderSideBar(isDark, authRepo),
            const SizedBox(height: AppSizes.sm),

            // Smart Lists
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                children: [
                  buildSmartListItem(
                    context: context,
                    icon: Icons.wb_sunny_rounded,
                    title: 'My Day',
                    color: AppColors.myDay,
                    routeName: 'home',
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
                    title: 'Tất cả',
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
              child: _buildNewListButton(context, isDark),
            ),

            // Logout Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.sm,
                0,
                AppSizes.sm,
                AppSizes.sm,
              ),
              child: _buildLogoutButton(context, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewListButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _showCreateListDialog(context);
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_rounded,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                'Danh sách mới',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await context.read<AuthProvider>().logout();
          if (context.mounted) {
            context.go('/login');
          }
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: AppSizes.md,
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: AppSizes.iconMd,
              ),
              const SizedBox(width: AppSizes.md),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    final controller = TextEditingController();

    // 1. LẤY DATA TỪ CONTEXT CỤC BỘ TRƯỚC KHI GỌI BOT TOAST
    final isDark = context.isDarkMode; // Extention của bạn
    final taskProvider = context.read<TaskListProvider>();

    BotToast.showAnimationWidget(
      clickClose: true, // Bấm ra vùng tối để đóng dialog
      onlyOne: true, // Đảm bảo chỉ hiện 1 dialog này tại 1 thời điểm
      crossPage: false,
      backButtonBehavior:
          BackButtonBehavior.close, // Bấm nút Back trên Android sẽ đóng
      backgroundColor: Colors.black54, // Màu nền tối mờ
      animationDuration: const Duration(milliseconds: 200),
      wrapToastAnimation: (controller, cancel, child) {
        return FadeTransition(opacity: controller, child: child);
      },
      toastBuilder: (cancelFunc) {
        // Dùng Material và Center để căn giữa AlertDialog trong Overlay
        return Center(
          child: Material(
            color: Colors.transparent,
            child: AlertDialog(
              backgroundColor: isDark
                  ? AppColors.surfaceDark
                  : AppColors.surfaceLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              title: Text(
                'Tạo danh sách mới',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Tên danh sách...'),
              ),
              actions: [
                TextButton(
                  // 2. DÙNG cancelFunc ĐỂ ĐÓNG THAY VÌ Navigator.pop
                  onPressed: cancelFunc,
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      // Gọi Provider đã được khởi tạo ở trên
                      taskProvider.createTaskList(
                        title: controller.text.trim(),
                      );

                      cancelFunc(); // Đóng dialog

                      // 3. Có thể dùng luôn BotToast để hiện thông báo thay cho SnackBar
                      BotToast.showText(
                        text: 'Đã tạo: ${controller.text.trim()}',
                        align: const Alignment(
                          0,
                          0.8,
                        ), // Hiển thị ở gần cuối màn hình
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 40),
                  ),
                  child: const Text('Tạo'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
