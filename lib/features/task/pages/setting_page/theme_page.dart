import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo/core/constants/app_colors.dart';
import 'package:todo/core/constants/app_sizes.dart';
import 'package:todo/core/utils/extensions.dart';
import 'package:todo/config/themes/theme_provider.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chủ đề',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final currentMode = themeProvider.themeMode;

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildThemeOption(
                    context: context,
                    isDark: isDark,
                    icon: Icons.light_mode_rounded,
                    title: 'Sáng',
                    mode: ThemeMode.light,
                    currentMode: currentMode,
                    themeProvider: themeProvider,
                    isFirst: true,
                  ),
                  _buildDivider(isDark),
                  _buildThemeOption(
                    context: context,
                    isDark: isDark,
                    icon: Icons.dark_mode_rounded,
                    title: 'Tối',
                    mode: ThemeMode.dark,
                    currentMode: currentMode,
                    themeProvider: themeProvider,
                  ),
                  _buildDivider(isDark),
                  _buildThemeOption(
                    context: context,
                    isDark: isDark,
                    icon: Icons.settings_suggest_rounded,
                    title: 'Sử dụng chủ đề hệ thống',
                    mode: ThemeMode.system,
                    currentMode: currentMode,
                    themeProvider: themeProvider,
                    isLast: true,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required String title,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required ThemeProvider themeProvider,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = currentMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => themeProvider.setThemeMode(mode),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(AppSizes.radiusLg) : Radius.zero,
          bottom:
              isLast ? const Radius.circular(AppSizes.radiusLg) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.md,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppSizes.iconMd,
                color: isSelected
                    ? AppColors.primary
                    : isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.dividerDark : AppColors.divider,
      ),
    );
  }
}
