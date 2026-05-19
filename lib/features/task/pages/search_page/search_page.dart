import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:todo/core/widgets/task_tile.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/utils/extensions.dart';
import '../../providers/task_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value.trim());
    if (_query.isNotEmpty) {
      context.read<TaskProvider>().searchTasks(_query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm công việc...',
            hintStyle: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
            ),
            filled: false,
            fillColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,

            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
              icon: const Icon(Icons.clear_rounded),
            ),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_query.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 48,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.md),
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

    return Consumer<TaskProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = provider.tasks
            .where((t) => t.title.toLowerCase().contains(_query.toLowerCase()))
            .toList();

        if (results.isEmpty) {
          return Center(
            child: Text(
              'Không tìm thấy kết quả cho "$_query"',
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
            return TaskTile(
              task: task,
              onToggle: () => context.read<TaskProvider>().toggleComplete(
                    taskId: task.id,
                    isCompleted: !task.isCompleted,
                  ),
              onToggleImportant: () =>
                  context.read<TaskProvider>().toggleImportant(
                        taskId: task.id,
                        isImportant: !task.isImportant,
                      ),
              onDelete: () => context.read<TaskProvider>().deleteTask(task.id),
              onTap: () => context.push('/task/${task.id}'),
            );
          },
        );
      },
    );
  }
}
