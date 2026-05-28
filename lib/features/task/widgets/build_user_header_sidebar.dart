import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/services/auth_service.dart';

Widget buildUserHeaderSideBar(
  BuildContext context,
  bool isDark,
  AuthService authRepo,
) {
  final name = authRepo.displayName.isNotEmpty
      ? authRepo.displayName
      : 'Người dùng';
  final email = authRepo.email;
  final initials = name.isNotEmpty
      ? name
            .split(' ')
            .map((w) => w.isNotEmpty ? w[0] : '')
            .take(1)
            .join()
            .toUpperCase()
      : 'U';

  return Container(
    padding: const EdgeInsets.fromLTRB(
      AppSizes.lg,
      AppSizes.lg,
      AppSizes.sm,
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
        IconButton(
          onPressed: () {
            Navigator.pop(context); // Close drawer first
            context.push('/settings');
          },
          icon: Icon(
            Icons.settings_rounded,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
            size: AppSizes.iconMd,
          ),
        ),
      ],
    ),
  );
}
