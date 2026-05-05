import 'package:flutter/material.dart';
import 'package:todo/core/constants/app_colors.dart';
import 'package:todo/core/utils/extensions.dart';
import 'package:todo/features/task/providers/task_provider.dart';

class TaskSearchDelegate extends SearchDelegate<String> {
  final TaskProvider taskProvider;

  TaskSearchDelegate({required this.taskProvider});

  @override
  String get searchFieldLabel => 'Tìm kiếm công việc...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear_rounded),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, ''),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final isDark = context.isDarkMode;

    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 48,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Nhập để tìm kiếm công việc',
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Tìm kiếm qua Supabase
    return FutureBuilder(
      future: taskProvider.searchTasks(query).then((_) => taskProvider.tasks),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = taskProvider.tasks
            .where((t) => t.title.toLowerCase().contains(query.toLowerCase()))
            .toList();

        if (results.isEmpty) {
          return Center(
            child: Text(
              'Không tìm thấy kết quả cho "$query"',
              style: TextStyle(
                fontSize: 15,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final task = results[index];
            return ListTile(
              leading: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted
                      ? AppColors.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted
                        ? AppColors.primary
                        : AppColors.textHint,
                    width: 1.5,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: task.isCompleted
                      ? AppColors.textHint
                      : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                ),
              ),
              subtitle: task.dueDate != null
                  ? Text(
                      'Hạn: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: task.dueDate!.isOverdue
                            ? AppColors.error
                            : AppColors.textHint,
                      ),
                    )
                  : null,
              trailing: task.isImportant
                  ? const Icon(
                      Icons.star_rounded,
                      color: AppColors.starYellow,
                      size: 20,
                    )
                  : null,
              onTap: () {},
            );
          },
        );
      },
    );
  }
}
