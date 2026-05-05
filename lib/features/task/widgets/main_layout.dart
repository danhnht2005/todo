import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:todo/core/constants/app_sizes.dart';
import 'package:todo/features/task/widgets/sidebar_widget.dart';
import '../.././../core/constants/app_colors.dart';
import 'package:todo/core/utils/extensions.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      // ─── Drawer ───
      drawer: Drawer(
        width: AppSizes.sidebarWidth(context),
        child: SidebarWidget(),
      ),

      // ─── AppBar ───
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              Icons.menu_rounded,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
        actions: [
          // Search button
          IconButton(
            onPressed: () => {context.push('/search')},
            icon: Icon(
              Icons.search_rounded,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ─── Body ───
      body: child,
    );
  }
}
