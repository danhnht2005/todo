import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/extensions.dart';

class MyDayPage extends StatefulWidget {
  const MyDayPage({super.key});

  @override
  State<MyDayPage> createState() => _MyDayPageState();
}

class _MyDayPageState extends State<MyDayPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _MyDayHeader(),
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
