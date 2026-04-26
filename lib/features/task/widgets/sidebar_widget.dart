import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
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
