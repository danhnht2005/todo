import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';

class BuildNoteTaskSection extends StatefulWidget {
  final TaskModel task;
  const BuildNoteTaskSection({super.key, required this.task});

  @override
  State<BuildNoteTaskSection> createState() => _BuildNoteTaskSectionState();
}

class _BuildNoteTaskSectionState extends State<BuildNoteTaskSection> {
  final _noteController = TextEditingController();
  bool _isEditingNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final isDark = context.isDarkMode;
    if (_isEditingNote) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              maxLines: 5,
              autofocus: true,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'Nhập ghi chú...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _noteController.text = task.note ?? '';
                    setState(() => _isEditingNote = false);
                  },
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: AppSizes.sm),
                ElevatedButton(
                  onPressed: () {
                    final note = _noteController.text.trim();
                    if (note.isEmpty) {
                      context.read<TaskProvider>().updateTask(
                        taskId: task.id,
                        clearNote: true,
                      );
                    } else {
                      context.read<TaskProvider>().updateTask(
                        taskId: task.id,
                        note: note,
                      );
                    }
                    setState(() => _isEditingNote = false);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(60, 36),
                  ),
                  child: const Text('Lưu'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _isEditingNote = true),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notes_rounded,
              size: 18,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Text(
                task.note?.isNotEmpty == true ? task.note! : 'Thêm ghi chú...',
                style: TextStyle(
                  fontSize: 14,
                  color: task.note?.isNotEmpty == true
                      ? (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary)
                      : AppColors.textHint,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
