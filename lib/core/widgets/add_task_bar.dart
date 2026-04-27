import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/extensions.dart';

class AddTaskBar extends StatefulWidget {
  final Function(String) onSubmit;
  final Color accentColor;
  final String hintText;

  const AddTaskBar({
    super.key,
    required this.onSubmit,
    this.accentColor = AppColors.primary,
    this.hintText = 'Thêm tác vụ',
  });

  @override
  State<AddTaskBar> createState() => _AddTaskBarState();
}

class _AddTaskBarState extends State<AddTaskBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

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
      // Keep focus if needed, or unfocus
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
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
                    decoration: InputDecoration(
                      hintText: widget.hintText,
                      border: InputBorder.none,
                      hintStyle: const TextStyle(color: AppColors.textHint),
                    ),
                    onSubmitted: (_) => _handleSubimit(),
                    onTap: () {}, // Xóa setState không dùng
                  ),
                ),
                if (_controller.text.isNotEmpty)
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
    );
  }
}
