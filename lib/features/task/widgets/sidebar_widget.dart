import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/providers/auth_provider.dart';

/// Sidebar Navigation
class SidebarWidget extends StatelessWidget {
  const SidebarWidget({super.key});

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
            _buildUserHeader(isDark, authRepo),
            const SizedBox(height: AppSizes.sm),

            // Smart Lists
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm),
                children: [
                  _buildSmartListItem(
                    context: context,
                    icon: Icons.wb_sunny_rounded,
                    title: 'My Day',
                    color: AppColors.myDay,
                    routeName: 'home',
                  ),
                  _buildSmartListItem(
                    context: context,
                    icon: Icons.star_rounded,
                    title: 'Quan trọng',
                    color: AppColors.important,
                    routeName: 'important',
                  ),
                  _buildSmartListItem(
                    context: context,
                    icon: Icons.calendar_month_rounded,
                    title: 'Đã lên kế hoạch',
                    color: AppColors.planned,
                    routeName: 'planned',
                  ),
                  _buildSmartListItem(
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
                ],
              ),
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

  Widget _buildUserHeader(bool isDark, AuthService authRepo) {
    final name = authRepo.displayName.isNotEmpty
        ? authRepo.displayName
        : 'Người dùng';
    final email = authRepo.email;
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase()
        : 'U';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.lg,
        AppSizes.sm,
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.avatarSize,
            height: AppSizes.avatarSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartListItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required String routeName,
  }) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context); // Đóng Drawer trước
            context.go('/$routeName');
          },
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.md,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: AppSizes.iconMd),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
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
}
