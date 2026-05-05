import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';

class BuildStepList extends StatelessWidget {
  final TaskModel task;
  const BuildStepList({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: task.steps.map((step) {
        return Dismissible(
          key: Key(step.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            context.read<TaskProvider>().deleteStep(step.id);
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: AppSizes.md),
            child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 18),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.read<TaskProvider>().toggleStep(stepId: step.id, isCompleted: !step.isCompleted);
                },
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: AppSizes.sm + 2),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18, height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: step.isCompleted ? AppColors.primary : Colors.transparent,
                          border: Border.all(
                            color: step.isCompleted ? AppColors.primary
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                            width: 1.5,
                          ),
                        ),
                        child: step.isCompleted
                            ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: step.isCompleted
                                ? (isDark ? AppColors.textSecondaryDark : AppColors.textHint)
                                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                            decoration: step.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<TaskProvider>().deleteStep(step.id);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.close_rounded, size: 16,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
