import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../task_list/providers/task_list_provider.dart';
import '../../../task_list/models/task_list_model.dart';
import '../../../task_list/widgets/share_task_list_dialog.dart';
import '../../../../core/widgets/add_task_bar.dart';
import '../../../../core/widgets/confirm_delete_dialog.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../widgets/task_list.dart';
import '../../providers/task_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';

class CustomListPage extends StatefulWidget {
  final String id;

  const CustomListPage({super.key, required this.id});

  @override
  State<CustomListPage> createState() => _CustomListPageState();
}

class _CustomListPageState extends State<CustomListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didUpdateWidget(covariant CustomListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) {
      _loadData();
    }
  }

  void _loadData() {
    context.read<TaskProvider>().loadTasks(listId: widget.id);
    context.read<TaskListProvider>().loadTaskListDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final isSharedList =
        context.watch<TaskListProvider>().selectedTaskList?.isOwner == false;
    return Stack(
      children: [
        Column(
          children: [
            // ─── Header ───
            _CustomListHeader(listId: widget.id),

            // ─── Task List ───
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (provider.errorMessage != null) {
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
                            onPressed: () =>
                                provider.loadTasks(listId: widget.id),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }

                  final incomplete = provider.tasks
                      .where((t) => !t.isCompleted)
                      .toList();
                  final completed = provider.tasks
                      .where((t) => t.isCompleted)
                      .toList();

                  if (incomplete.isEmpty && completed.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.folder_open_rounded,
                      title: 'Không có tác vụ trong danh sách này',
                      subtitle: 'Hãy thử thêm một số tác vụ để xem chúng ở đây',
                      iconColor: AppColors.primary,
                    );
                  }

                  return TaskList(
                    incomplete: incomplete,
                    completed: completed,
                    showCreator: isSharedList,
                  );
                },
              ),
            ),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 50,
          child: Consumer<TaskListProvider>(
            builder: (context, listProvider, _) {
              return AddTaskBar(
                onSubmit: (title, dueDate, reminderAt, listId) {
                  context.read<TaskProvider>().addTask(
                    title: title,
                    listId: listId,
                    dueDate: dueDate,
                    reminderAt: reminderAt,
                  );
                },
                accentColor: AppColors.customList,
                lists: listProvider.lists,
                initialListId: widget.id,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Enum cho menu options ───
enum _ListMenuAction { share, rename, delete }

class _CustomListHeader extends StatelessWidget {
  final String listId;

  const _CustomListHeader({required this.listId});

  String? _ownerLabel(TaskListModel? list) {
    if (list == null || list.isOwner) return null;

    final name = list.ownerName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final email = list.ownerEmail?.trim();
    if (email != null && email.isNotEmpty) return email;

    return 'Người dùng';
  }

  /// Hiển thị dialog đổi tên danh sách
  Future<void> _showRenameDialog(
    BuildContext context,
    String currentTitle,
  ) async {
    final controller = TextEditingController(text: currentTitle);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        final isDark = dialogCtx.isDarkMode;

        return AlertDialog(
          backgroundColor: isDark
              ? AppColors.surfaceDark
              : AppColors.surfaceLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          title: Text(
            'Đổi tên danh sách',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          content: SizedBox(
            width: AppSizes.dialogWidth(context),
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Nhập tiêu đề danh sách',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Hủy bỏ',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final newTitle = controller.text.trim();
                if (newTitle.isEmpty) {
                  BotToast.showText(
                    text: 'Tiêu đề danh sách không được để trống',
                    align: const Alignment(0, 0.8),
                  );
                  return;
                }
                Navigator.pop(dialogCtx, newTitle);
              },
              child: const Text(
                'Lưu',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    ).then((newTitle) async {
      if (newTitle != null && newTitle is String && context.mounted) {
        await context.read<TaskListProvider>().updateTaskList(
          listId: listId,
          title: newTitle,
        );
        // Reload detail để cập nhật tiêu đề trên header
        if (context.mounted) {
          context.read<TaskListProvider>().loadTaskListDetail(listId);
        }
      }
    });
  }

  /// Hiển thị dialog xác nhận xóa danh sách
  Future<void> _showDeleteDialog(BuildContext context, String listTitle) async {
    await showConfirmDeleteDialog(
      context: context,
      title: 'Xóa danh sách?',
      content:
          'Danh sách "$listTitle" và tất cả tác vụ trong đó sẽ bị xóa vĩnh viễn. Bạn không thể hoàn tác hành động này.',
      onConfirmed: () async {
        await context.read<TaskListProvider>().deleteTaskList(listId);
        if (context.mounted) {
          context.go('/');
        }
      },
    );
  }

  Future<void> _showShareDialog(
    BuildContext context,
    String listTitle,
  ) async {
    await showDialog(
      context: context,
      builder: (_) => ShareTaskListDialog(
        listId: listId,
        listTitle: listTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Consumer<TaskListProvider>(
      builder: (context, provider, child) {
        final list = provider.selectedTaskList;
        final listTitle = list?.title ?? 'Danh sách tùy chỉnh';
        final isOwner = list?.isOwner ?? true;
        final ownerLabel = _ownerLabel(list);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            AppSizes.xxl,
            AppSizes.lg,
            AppSizes.md, // giảm padding phải để nút menu không bị cắt
            AppSizes.md,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                Colors.transparent,
              ],
            ),
          ),
          child: Row(
            children: [
              Icon(
                isOwner ? Icons.list_rounded : Icons.group_rounded,
                color: AppColors.customList,
                size: 28,
              ),
              const SizedBox(width: AppSizes.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listTitle,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (ownerLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Chia sẻ bởi $ownerLabel',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // ─── More options menu ───
              PopupMenuButton<_ListMenuAction>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                tooltip: 'Tùy chọn',
                onSelected: (action) {
                  switch (action) {
                    case _ListMenuAction.share:
                      _showShareDialog(context, listTitle);
                    case _ListMenuAction.rename:
                      _showRenameDialog(context, listTitle);
                    case _ListMenuAction.delete:
                      _showDeleteDialog(context, listTitle);
                  }
                },
                itemBuilder: (_) => [
                  if (!isOwner)
                    const PopupMenuItem(
                      enabled: false,
                      child: Row(
                        children: [
                          Icon(Icons.group_rounded, size: 20),
                          SizedBox(width: 12),
                          Text('Được chia sẻ với bạn'),
                        ],
                      ),
                    ),
                  if (isOwner)
                    const PopupMenuItem(
                      value: _ListMenuAction.share,
                      child: Row(
                        children: [
                          Icon(Icons.ios_share_rounded, size: 20),
                          SizedBox(width: 12),
                          Text('Chia sẻ'),
                        ],
                      ),
                    ),
                  if (isOwner)
                    const PopupMenuItem(
                      value: _ListMenuAction.rename,
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 20),
                          SizedBox(width: 12),
                          Text('Đổi tên'),
                        ],
                      ),
                    ),
                  if (isOwner)
                    const PopupMenuItem(
                      value: _ListMenuAction.delete,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 20,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Xóa danh sách',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
