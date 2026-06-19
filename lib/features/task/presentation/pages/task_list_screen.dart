import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/task/presentation/bloc/task_bloc.dart';
import 'package:gtcrm/features/task/presentation/bloc/task_event.dart';
import 'package:gtcrm/features/task/presentation/bloc/task_state.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_bloc.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_event.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/task/data/models/task_model.dart';
import 'package:gtcrm/routes/app_routes.dart';
import 'package:gtcrm/core/widgets/app_drawer.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tc;

  static const List<String> _statuses = <String>[
    'Pending',
    'In Progress',
    'Completed',
    'Overdue',
  ];

  @override
  void initState() {
    super.initState();
    _tc = TabController(length: _statuses.length, vsync: this);
    context.read<TaskBloc>().add(const TaskFetched(page: 1, limit: 100));
    context.read<UserBloc>().add(const UserFetched());
  }

  @override
  void dispose() {
    _tc.dispose();
    super.dispose();
  }

  void _showCreateTaskSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    String priority = 'High';
    String status = 'Pending';
    String assignedTo = '';
    DateTime dueDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final users = context.watch<UserBloc>().state.items;
            String assignedName = 'Unassigned';
            if (assignedTo.isNotEmpty) {
              for (final u in users) {
                if (u.id == assignedTo) {
                  assignedName = u.name;
                  break;
                }
              }
            }

            return Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 10,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Text(
                        'Create Task',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E8EFF),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: _fieldDec('Title', Icons.text_fields_rounded),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: _fieldDec(
                          'Description',
                          Icons.description_outlined,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      _buildSelectorField(
                        context: context,
                        label: 'Priority',
                        value: priority,
                        prefixIcon: Icons.priority_high_rounded,
                        onTap: () {
                          _showPriorityPicker(
                            context: context,
                            currentValue: priority,
                            onSelected: (val) {
                              setModalState(() {
                                priority = val;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSelectorField(
                        context: context,
                        label: 'Status',
                        value: status,
                        prefixIcon: Icons.flag_rounded,
                        onTap: () {
                          _showStatusPicker(
                            context: context,
                            currentValue: status,
                            onSelected: (val) {
                              setModalState(() {
                                status = val;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSelectorField(
                        context: context,
                        label: 'Assigned To',
                        value: assignedName,
                        prefixIcon: Icons.person_outline_rounded,
                        onTap: () {
                          _showAssignedToPicker(
                            context: context,
                            currentValue: assignedTo,
                            users: users,
                            onSelected: (val) {
                              setModalState(() {
                                assignedTo = val;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildSelectorField(
                        context: context,
                        label: 'Due Date',
                        value: '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                        prefixIcon: Icons.calendar_today_rounded,
                        showDropdownArrow: false,
                        onTap: () async {
                          final d = await showDatePicker(
                            context: ctx,
                            initialDate: dueDate,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365 * 3),
                            ),
                          );
                          if (d != null) {
                            setModalState(() {
                              dueDate = DateTime(
                                d.year,
                                d.month,
                                d.day,
                                dueDate.hour,
                                dueDate.minute,
                              );
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          context.read<TaskBloc>().add(
                            TaskCreated(
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              priority: priority,
                              dueDate: dueDate.toUtc().toIso8601String(),
                              leadId: null,
                              dealId: null,
                              customerId: null,
                              assignedTo: assignedTo.isEmpty
                                  ? null
                                  : assignedTo,
                              status: status,
                            ),
                          );
                          Navigator.pop(ctx);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E8EFF),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Create Task',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectorField({
    required BuildContext context,
    required String label,
    required String value,
    required IconData prefixIcon,
    bool showDropdownArrow = true,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F6FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    prefixIcon,
                    color: const Color(0xFF2E8EFF),
                    size: 18,
                  ),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (showDropdownArrow)
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.grey,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showPriorityPicker({
    required BuildContext context,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select Priority',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF2E8EFF),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ...['High', 'Medium', 'Low'].map((p) {
                final isSelected = p.toLowerCase() == currentValue.toLowerCase();
                return ListTile(
                  title: Text(
                    p,
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF))
                      : null,
                  onTap: () {
                    onSelected(p);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showStatusPicker({
    required BuildContext context,
    required String currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select Status',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF2E8EFF),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ..._statuses.map((s) {
                final isSelected = s.toLowerCase() == currentValue.toLowerCase();
                return ListTile(
                  title: Text(
                    s,
                    style: GoogleFonts.poppins(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF))
                      : null,
                  onTap: () {
                    onSelected(s);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showAssignedToPicker({
    required BuildContext context,
    required String currentValue,
    required List<dynamic> users,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Select Assignee',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color(0xFF2E8EFF),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(),
              ListTile(
                title: Text(
                  'Unassigned',
                  style: GoogleFonts.poppins(
                    fontWeight: currentValue.isEmpty ? FontWeight.w600 : FontWeight.w400,
                    color: currentValue.isEmpty ? const Color(0xFF2E8EFF) : Colors.black87,
                  ),
                ),
                trailing: currentValue.isEmpty
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF))
                    : null,
                onTap: () {
                  onSelected('');
                  Navigator.pop(ctx);
                },
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, i) {
                    final u = users[i];
                    final isSelected = u.id == currentValue;
                    return ListTile(
                      title: Text(
                        u.name,
                        style: GoogleFonts.poppins(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF))
                          : null,
                      onTap: () {
                        onSelected(u.id);
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TaskBloc, TaskState>(
      listenWhen: (p, c) =>
          p.actionStatus != c.actionStatus &&
          (c.actionStatus == AppStatus.success ||
              c.actionStatus == AppStatus.failure),
      listener: (context, state) {
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isCurrentRoute) {
          return;
        }

        final isSuccess = state.actionStatus == AppStatus.success;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.actionMessage ?? (isSuccess ? 'Done' : 'Error'),
            ),
            backgroundColor: isSuccess ? AppColors.stageWon : AppColors.error,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        drawer: const AppDrawer(activeRoute: AppRoutes.tasks),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          toolbarHeight: 64,
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tasks',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                'Track pending work',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.task_alt_rounded, color: Colors.white),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tc,
                tabs: _statuses.map((s) => Tab(text: s)).toList(),
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: const Color(0xFF2E8EFF),
                unselectedLabelColor: const Color(0xFF000000),
                indicatorColor: const Color(0xFF2E8EFF),
                indicatorWeight: 3,
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
        body: ResponsiveConstraint(
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state.status == AppStatus.loading) {
                return ShimmerLoading.listPlaceholder();
              }
              if (state.status == AppStatus.failure) {
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Failed to load tasks',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary),
                  ),
                );
              }
              return TabBarView(
                controller: _tc,
                children: _statuses
                    .map((s) => _taskListByStatus(context, state, s))
                    .toList(),
              );
            },
          ),
        ),
        floatingActionButton: InnerShadow(
          shadows: [
            BoxShadow(
              color: Colors.transparent,
              blurRadius: 10,
              offset: const Offset(3, 3),
            ),
          ],
          child: FloatingActionButton.extended(
            heroTag: 'add_task_fab',
            onPressed: () => _showCreateTaskSheet(context),
            icon: const Icon(Icons.add_task_rounded, color: Colors.white),
            label: Text(
              'Add Task',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _taskListByStatus(
    BuildContext context,
    TaskState state,
    String status,
  ) {
    final users = context.watch<UserBloc>().state.items;
    final items = state.items
        .where((t) => t.status.toLowerCase() == status.toLowerCase())
        .toList();

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No $status tasks',
          style: GoogleFonts.poppins(color: Colors.grey.shade600),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TaskBloc>().add(const TaskFetched(page: 1, limit: 100));
      },
      child: ListView.separated(
        padding: responsiveListPadding(context),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final task = items[i];
          String assignedName = task.assignedToName;
          for (final u in users) {
            if (u.id == task.assignedTo) {
              assignedName = u.name;
              break;
            }
          }
          return _TaskCard(
            task: task,
            assignedName: assignedName,
            onStatusChanged: (newStatus) {
              context.read<TaskBloc>().add(
                TaskStatusUpdated(taskId: task.id, status: newStatus),
              );
            },
          );
        },
      ),
    );
  }

  InputDecoration _fieldDec(String hint, IconData prefixIcon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: Colors.grey.shade500,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6FE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            prefixIcon,
            color: const Color(0xFF2E8EFF),
            size: 18,
          ),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE8ECF3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2E8EFF), width: 1.5),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});
  final String priority;

  Color _getBgColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFFFEBEE); // Light Red
      case 'medium':
        return const Color(0xFFFFF0E6); // Light Orange/Peach
      case 'low':
      default:
        return const Color(0xFFE8F8F5); // Light Green/Teal
    }
  }

  Color _getTextColor() {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFE53935); // Red
      case 'medium':
        return const Color(0xFFFF6D00); // Orange
      case 'low':
      default:
        return const Color(0xFF2ECC71); // Green
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBgColor(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        priority,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _getTextColor(),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.assignedName,
    required this.onStatusChanged,
  });

  final TaskModel task;
  final String assignedName;
  final ValueChanged<String> onStatusChanged;

  static const List<String> _statuses = <String>[
    'Pending',
    'In Progress',
    'Completed',
    'Overdue',
  ];

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return const Color(0xFFFFB300); // Amber
      case 'completed':
        return const Color(0xFF2ECC71); // Green
      case 'overdue':
        return const Color(0xFFE53935); // Red
      case 'pending':
      default:
        return const Color(0xFF2E8EFF); // Blue
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return const Color(0xFFFFF8E1); // Light Amber
      case 'completed':
        return const Color(0xFFE8F8F5); // Light Green
      case 'overdue':
        return const Color(0xFFFFEBEE); // Light Red
      case 'pending':
      default:
        return const Color(0xFFF2F6FE); // Light Blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final due = task.dueDate.toLocal();
    final dueText =
        '${due.day}/${due.month}/${due.year} ${due.hour.toString().padLeft(2, '0')}:${due.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000), // #00000040 (25% opacity)
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 0), // x 0, y 0
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF2E8EFF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (task.description.trim().isNotEmpty) ...[
                      Text(
                        task.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          size: 14,
                          color: Color(0xFF2E8EFF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task.assignedToName.isNotEmpty ? task.assignedToName : 'Unassigned',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Color(0xFF2E8EFF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dueText,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (assignedName.trim().isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            height: 12,
                            width: 1,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.person_rounded,
                            size: 14,
                            color: Color(0xFF2E8EFF),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Assigned: $assignedName',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _PriorityBadge(priority: task.priority),
                  const SizedBox(height: 4),
                  const Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20, thickness: 1, color: Color(0xFFF2F6FE)),
          const SizedBox(height: 4),
          InkWell(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (ctx) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Update Status',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF2E8EFF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(),
                        Flexible(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _statuses.length,
                            itemBuilder: (context, i) {
                              final statusOption = _statuses[i];
                              final isSelected = task.status.toLowerCase() == statusOption.toLowerCase();
                              final statusColor = _getStatusColor(statusOption);
                              return ListTile(
                                leading: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(
                                  statusOption,
                                  style: GoogleFonts.poppins(
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF))
                                    : null,
                                onTap: () {
                                  if (task.status.toLowerCase() != statusOption.toLowerCase()) {
                                    onStatusChanged(statusOption);
                                  }
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: _getStatusBg(task.status),
                borderRadius: BorderRadius.circular(10),
                border: task.status.toLowerCase() == 'pending'
                    ? null
                    : Border.all(
                        color: _getStatusColor(task.status).withValues(alpha: 0.2),
                      ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      task.status,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(task.status),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: task.status.toLowerCase() == 'pending'
                        ? Colors.black
                        : _getStatusColor(task.status),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
