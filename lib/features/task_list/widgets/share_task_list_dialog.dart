import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../providers/task_list_provider.dart';

class ShareTaskListDialog extends StatefulWidget {
  final String listId;
  final String listTitle;

  const ShareTaskListDialog({
    super.key,
    required this.listId,
    required this.listTitle,
  });

  @override
  State<ShareTaskListDialog> createState() => _ShareTaskListDialogState();
}

class _ShareTaskListDialogState extends State<ShareTaskListDialog> {
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskListProvider>().loadMembers(widget.listId);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _invite() async {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      BotToast.showText(
        text: 'Nhap email hop le',
        align: const Alignment(0, 0.8),
      );
      return;
    }

    final provider = context.read<TaskListProvider>();
    final success = await provider.inviteUser(
      listId: widget.listId,
      email: email,
    );

    if (!mounted) return;
    if (success) {
      _emailController.clear();
      BotToast.showText(
        text: 'Da moi nguoi dung vao danh sach',
        align: const Alignment(0, 0.8),
      );
    } else if (provider.errorMessage != null) {
      BotToast.showText(
        text: provider.errorMessage!,
        align: const Alignment(0, 0.8),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      title: Text(
        'Chia se danh sach',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      content: SizedBox(
        width: AppSizes.dialogWidth(context),
        child: Consumer<TaskListProvider>(
          builder: (context, provider, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.listTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'email@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        onSubmitted: (_) => _invite(),
                      ),
                    ),
                    const SizedBox(width: AppSizes.sm),
                    IconButton.filled(
                      onPressed: provider.isSharing ? null : _invite,
                      tooltip: 'Moi',
                      icon: provider.isSharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.person_add_alt_1_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),
                Text(
                  'Thanh vien',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.sm),
                if (provider.isSharing && provider.members.isEmpty)
                  const Center(child: CircularProgressIndicator())
                else if (provider.members.isEmpty)
                  Text(
                    'Chua co thanh vien nao',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: provider.members.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSizes.xs),
                      itemBuilder: (context, index) {
                        final member = provider.members[index];
                        final name = member.fullName?.trim();
                        final email = member.email?.trim();
                        final title = name?.isNotEmpty == true
                            ? name!
                            : email?.isNotEmpty == true
                                ? email!
                                : 'Nguoi dung';

                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            child: Text(title.substring(0, 1).toUpperCase()),
                          ),
                          title: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: member.email == null
                              ? null
                              : Text(
                                  member.email!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          trailing: IconButton(
                            tooltip: 'Xoa thanh vien',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: provider.isSharing
                                ? null
                                : () => provider.removeMember(
                                      listId: widget.listId,
                                      memberId: member.id,
                                    ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Dong',
            style: TextStyle(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
