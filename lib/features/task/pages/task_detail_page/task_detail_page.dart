import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'task_detail_footer.dart';
import 'build_app_step_input.dart';
import 'build_step_list.dart';
import 'toggle_due_date.dart';
import 'build_note_section.dart';
import 'build_title_task_detail.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../providers/task_provider.dart';
import 'toggle_my_day.dart';

/// TaskDetailPage — Bottom sheet chi tiết task
class TaskDetailPage extends StatefulWidget {
  final String id;

  const TaskDetailPage({super.key, required this.id});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TaskProvider>().loadTaskDetail(widget.id);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.task == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final task = provider.task!;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    // Task Title + Checkbox
                    BuildTitleTaskDetail(task: task),

                    const SizedBox(height: AppSizes.xs),

                    // Steps
                    BuildStepList(task: task),
                    BuildAddStepInput(task: task),

                    const SizedBox(height: AppSizes.sm),

                    _buildSectionCard(
                      context: context,
                      children: [
                        ToggleMyDay(task: task),
                        const Divider(height: 1, indent: 56, endIndent: 16),
                        ToggleDueDate(task: task),
                      ],
                    ),

                    const SizedBox(height: AppSizes.sm),

                    // Note
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                      ),
                      child: BuildNoteTaskSection(task: task),
                    ),
                  ],
                ),
              ),

              //Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                child: TaskDetailFooter(task: task),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final isDark = context.isDarkMode;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    );
  }
}
