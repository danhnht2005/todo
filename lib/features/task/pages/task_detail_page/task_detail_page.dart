import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'build_note_section.dart';
import 'build_title_task_detail.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../providers/task_provider.dart';

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
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.xxl,
                    AppSizes.xs,
                    AppSizes.xxl,
                    AppSizes.xs,
                  ),
                  children: [
                    // Task Title + Checkbox
                    BuildTitleTaskDetail(task: task),

                    const SizedBox(height: AppSizes.xl),

                    // Note
                    BuildNoteTaskSection(task: task),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
