import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/extensions.dart';

class AddTaskBar extends StatefulWidget {
  final Function(String) onSubmit;
  final Color accentColor;

  const AddTaskBar({
    super.key,
    required this.onSubmit,
    this.accentColor = AppColors.primary,
  });

  @override
  State<AddTaskBar> createState() => _AddTaskBarState();
}

class _AddTaskBarState extends State<AddTaskBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubimit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSubmit(_controller.text.trim());
      _controller.clear();
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return FloatingActionButton(
      onPressed: () => _showAddTaskBar(context),
      backgroundColor: widget.accentColor,
      shape: const CircleBorder(),
      child: Icon(
        Icons.add,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
      ),
    );
  }

  void _showAddTaskBar(BuildContext context) {
    final isDark = context.isDarkMode;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          left: AppSizes.md,
          right: AppSizes.md,
          top: AppSizes.sm,
          bottom: AppSizes.sm + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.add, color: widget.accentColor),
                  const SizedBox(width: AppSizes.sm),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: "Thêm tác vụ",
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: AppColors.textHint),
                      ),
                      onSubmitted: (_) => _handleSubimit(),
                      onTap: () {}, // Xóa setState không dùng
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_upward_rounded,
                      color: widget.accentColor,
                    ),
                    onPressed: _handleSubimit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
