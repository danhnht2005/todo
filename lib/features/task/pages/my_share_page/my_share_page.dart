import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/utils/extensions.dart';
import '../../../task_list/models/task_list_model.dart';
import '../../../task_list/providers/task_list_provider.dart';

class MySharePage extends StatefulWidget {
  const MySharePage({super.key});

  @override
  State<MySharePage> createState() => _MySharePageState();
}

class _MySharePageState extends State<MySharePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskListProvider>().loadTaskLists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _MyShareHeader(),
        Expanded(
          child: Consumer<TaskListProvider>(
            builder: (context, provider, _) {
              final sharedLists = provider.lists
                  .where((list) => !list.isOwner)
                  .toList();

              if (provider.isLoading && sharedLists.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.errorMessage != null && sharedLists.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: provider.loadTaskLists,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (sharedLists.isEmpty) {
                return const EmptyStateWidget(
                  icon: Icons.group_off_rounded,
                  title: 'Chưa có danh sách được chia sẻ',
                  subtitle:
                      'Khi người khác chia sẻ danh sách với bạn, chúng sẽ xuất hiện ở đây.',
                  iconColor: AppColors.myShare,
                );
              }

              return RefreshIndicator(
                onRefresh: provider.loadTaskLists,
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: AppSizes.sm),
                  itemCount: sharedLists.length,
                  itemBuilder: (context, index) {
                    return _SharedListItem(list: sharedLists[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MyShareHeader extends StatelessWidget {
  const _MyShareHeader();

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
            AppColors.myShare.withValues(alpha: isDark ? 0.2 : 0.08),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_rounded,
            color: AppColors.myShare,
            size: 28,
          ),
          const SizedBox(width: AppSizes.md),
          Text(
            'Đã giao cho tôi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SharedListItem extends StatelessWidget {
  final TaskListModel list;

  const _SharedListItem({required this.list});

  String _ownerLabel() {
    final name = list.ownerName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = list.ownerEmail?.trim();
    if (email != null && email.isNotEmpty) return email;

    return 'Người dùng';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.lg,
        vertical: 4,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/custom-list/${list.id}'),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceDark.withValues(alpha: 0.65)
                  : Colors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.group_rounded,
                  color: AppColors.myShare,
                  size: AppSizes.iconMd,
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chia sẻ bởi ${_ownerLabel()}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
