import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/task_list/models/task_list_model.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../utils/extensions.dart';

class AddTaskBar extends StatefulWidget {
  final Function(
    String title,
    String? dueDate,
    String? reminderAt,
    String? listId,
  )
  onSubmit;
  final Color accentColor;
  final DateTime? initialDueDate;

  final List<TaskListModel>? lists;

  const AddTaskBar({
    super.key,
    required this.onSubmit,
    this.accentColor = AppColors.primary,
    this.initialDueDate,
    this.lists,
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

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showAddTaskBar(context),
      backgroundColor: widget.accentColor,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Hôm nay';
    if (dateOnly == tomorrow) return 'Ngày mai';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatReminder(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeStr = DateFormat('HH:mm').format(dateTime);

    if (dateOnly == today) return 'Hôm nay, $timeStr';
    if (dateOnly == tomorrow) return 'Ngày mai, $timeStr';
    return '${DateFormat('dd/MM/yyyy').format(dateTime)}, $timeStr';
  }

  void _showAddTaskBar(BuildContext context) {
    final isDark = context.isDarkMode;
    DateTime? selectedDate = widget.initialDueDate;
    DateTime? selectedReminder;
    TaskListModel? selectedList;

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          Future<void> pickDate() async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: sheetContext,
              initialDate: selectedDate ?? now,
              firstDate: now.subtract(const Duration(days: 365)),
              lastDate: now.add(const Duration(days: 365 * 5)),
              helpText: 'Chọn ngày đến hạn',
              cancelText: 'Hủy',
              confirmText: 'Xác nhận',
            );
            if (picked != null) {
              setSheetState(() {
                selectedDate = picked;
              });
            }
          }

          void clearDate() {
            setSheetState(() {
              selectedDate = null;
            });
          }

          Future<void> pickReminder() async {
            final now = DateTime.now();
            // Chọn ngày nhắc nhở
            final pickedDate = await showDatePicker(
              context: sheetContext,
              initialDate: selectedReminder ?? now,
              firstDate: now.subtract(const Duration(days: 1)),
              lastDate: now.add(const Duration(days: 365 * 5)),
              helpText: 'Chọn ngày nhắc nhở',
              cancelText: 'Hủy',
              confirmText: 'Tiếp theo',
            );
            if (pickedDate == null) return;

            // Chọn giờ nhắc nhở
            if (!sheetContext.mounted) return;
            final pickedTime = await showTimePicker(
              context: sheetContext,
              initialTime: selectedReminder != null
                  ? TimeOfDay.fromDateTime(selectedReminder!)
                  : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
              helpText: 'Chọn giờ nhắc nhở',
              cancelText: 'Hủy',
              confirmText: 'Xác nhận',
            );
            if (pickedTime == null) return;

            setSheetState(() {
              selectedReminder = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
            });
          }

          void clearReminder() {
            setSheetState(() {
              selectedReminder = null;
            });
          }

          /// Mở bottom sheet chọn danh sách
          void pickList() {
            final lists = widget.lists;
            if (lists == null || lists.isEmpty) return;

            showModalBottomSheet(
              context: sheetContext,
              useRootNavigator: true,
              backgroundColor: Colors.transparent,
              builder: (listCtx) {
                final isListDark = listCtx.isDarkMode;
                return Container(
                  decoration: BoxDecoration(
                    color: isListDark
                        ? AppColors.surfaceDark
                        : AppColors.surfaceLight,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tùy chọn "Không xếp vào danh sách"
                        ListTile(
                          leading: Icon(
                            Icons.home_rounded,
                            color: isListDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          title: Text(
                            'Tác vụ',
                            style: TextStyle(
                              color: isListDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                            ),
                          ),
                          trailing: selectedList == null
                              ? Icon(
                                  Icons.check_rounded,
                                  color: widget.accentColor,
                                )
                              : null,
                          onTap: () {
                            setSheetState(() => selectedList = null);
                            Navigator.pop(listCtx);
                          },
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        // Danh sách custom lists
                        ...lists.map(
                          (list) => ListTile(
                            leading: Icon(
                              Icons.list_rounded,
                              color: AppColors.customList,
                            ),
                            title: Text(
                              list.title,
                              style: TextStyle(
                                color: isListDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                            ),
                            trailing: selectedList?.id == list.id
                                ? Icon(
                                    Icons.check_rounded,
                                    color: widget.accentColor,
                                  )
                                : null,
                            onTap: () {
                              setSheetState(() => selectedList = list);
                              Navigator.pop(listCtx);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
              },
            );
          }

          void clearList() {
            setSheetState(() {
              selectedList = null;
            });
          }

          void submit() {
            if (_controller.text.trim().isNotEmpty) {
              String? dueDateStr;
              if (selectedDate != null) {
                dueDateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);
              }
              String? reminderStr;
              if (selectedReminder != null) {
                reminderStr = selectedReminder!.toIso8601String();
              }
              widget.onSubmit(
                _controller.text.trim(),
                dueDateStr,
                reminderStr,
                selectedList?.id,
              );
              _controller.clear();
              Navigator.of(sheetContext).pop();
            }
          }

          final isDateActive = selectedDate != null;
          final dateColor = isDateActive
              ? widget.accentColor
              : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary);

          final isReminderActive = selectedReminder != null;
          final reminderColor = isReminderActive
              ? widget.accentColor
              : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary);

          final isListActive = selectedList != null;
          final listColor = isListActive
              ? widget.accentColor
              : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary);

          final hasLists = widget.lists != null && widget.lists!.isNotEmpty;

          return Container(
            padding: EdgeInsets.only(
              left: AppSizes.md,
              right: AppSizes.md,
              top: AppSizes.sm,
              bottom: AppSizes.sm + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
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
                  // ─── Task name row ───
                  Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: widget.accentColor,
                      ),
                      const SizedBox(width: AppSizes.sm),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: "Tác vụ",
                            border: InputBorder.none,
                            hintStyle: const TextStyle(
                              color: AppColors.textHint,
                            ),
                          ),
                          onSubmitted: (_) => submit(),
                          onTap: () {},
                        ),
                      ),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder: (context, value, child) {
                          final isNotEmpty = value.text.trim().isNotEmpty;
                          return IconButton(
                            icon: Icon(
                              Icons.arrow_upward_rounded,
                              color: isNotEmpty
                                  ? widget.accentColor
                                  : Colors.grey.withValues(alpha: 0.5),
                            ),
                            onPressed: isNotEmpty ? submit : null,
                          );
                        },
                      ),
                    ],
                  ),

                  // ─── List picker row (chỉ hiện khi có lists) ───
                  if (hasLists)
                    InkWell(
                      onTap: pickList,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 2,
                          vertical: AppSizes.sm,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.home_rounded,
                              color: listColor,
                              size: 20,
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Text(
                                isListActive ? selectedList!.title : 'Tác vụ',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: listColor,
                                  fontWeight: isListActive
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (isListActive)
                              GestureDetector(
                                onTap: clearList,
                                child: Icon(
                                  Icons.close_rounded,
                                  color: listColor.withValues(alpha: 0.5),
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                  // ─── Due date row ───
                  InkWell(
                    onTap: pickDate,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: AppSizes.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDateActive
                                ? Icons.calendar_today
                                : Icons.calendar_today_outlined,
                            color: dateColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              isDateActive
                                  ? 'Đến hạn ${_formatDueDate(selectedDate!)}'
                                  : 'Đặt ngày đến hạn',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: dateColor,
                                fontWeight: isDateActive
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isDateActive)
                            GestureDetector(
                              onTap: clearDate,
                              child: Icon(
                                Icons.close_rounded,
                                color: dateColor.withValues(alpha: 0.5),
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ─── Reminder row ───
                  InkWell(
                    onTap: pickReminder,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: AppSizes.sm,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isReminderActive
                                ? Icons.notifications_active
                                : Icons.notifications_none_outlined,
                            color: reminderColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              isReminderActive
                                  ? 'Nhắc tôi lúc ${_formatReminder(selectedReminder!)}'
                                  : 'Nhắc tôi',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: reminderColor,
                                fontWeight: isReminderActive
                                    ? FontWeight.w500
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                          if (isReminderActive)
                            GestureDetector(
                              onTap: clearReminder,
                              child: Icon(
                                Icons.close_rounded,
                                color: reminderColor.withValues(alpha: 0.5),
                                size: 16,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
