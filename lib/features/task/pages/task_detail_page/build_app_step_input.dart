import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class BuildAddStepInput extends StatefulWidget {
  final TaskModel task;
  const BuildAddStepInput({super.key, required this.task});

  @override
  State<BuildAddStepInput> createState() => _BuildAddStepInputState();
}

class _BuildAddStepInputState extends State<BuildAddStepInput> {
  late final TextEditingController _stepController;
  late final FocusNode _stepFocusNode;

  @override
  void initState() {
    super.initState();
    _stepController = TextEditingController();
    _stepFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _stepController.dispose();
    _stepFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.xs),
      child: Row(
        children: [
          Container(
            width: 18, height: 18,
            margin: const EdgeInsets.only(left: AppSizes.sm),
            child: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: TextField(
              controller: _stepController,
              focusNode: _stepFocusNode,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  context.read<TaskProvider>().addStep(taskId: widget.task.id, title: value.trim());
                  _stepController.clear();
                  _stepFocusNode.requestFocus();
                }
              },
              style: TextStyle(fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Thêm bước...',
                hintStyle: TextStyle(color: AppColors.primary.withValues(alpha: 0.5), fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                isDense: true,
                filled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
