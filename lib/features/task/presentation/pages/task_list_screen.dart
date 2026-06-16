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
            return Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
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
                      Text(
                        'Create Task',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: titleCtrl,
                        decoration: _dec('Title', Icons.title_rounded),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: _dec(
                          'Description',
                          Icons.description_rounded,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: priority,
                        decoration: _dec(
                          'Priority',
                          Icons.priority_high_rounded,
                        ),
                        items: const ['High', 'Medium', 'Low']
                            .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => priority = v ?? 'High'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: status,
                        decoration: _dec('Status', Icons.flag_rounded),
                        items: _statuses
                            .map(
                              (s) => DropdownMenuItem(value: s, child: Text(s)),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setModalState(() => status = v ?? 'Pending'),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: users.any((u) => u.id == assignedTo)
                            ? assignedTo
                            : '',
                        decoration: _dec(
                          'Assigned To',
                          Icons.person_pin_rounded,
                        ),
                        items: <DropdownMenuItem<String>>[
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Unassigned'),
                          ),
                          ...users.map(
                            (u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.name),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setModalState(() => assignedTo = v ?? ''),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
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
                        child: InputDecorator(
                          decoration: _dec(
                            'Due Date',
                            Icons.calendar_today_rounded,
                          ),
                          child: Text(
                            '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(0, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Create Task',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
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
        backgroundColor: AppColors.background,
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
              color: AppColors.primary,
              child: TabBar(
                controller: _tc,
                tabs: _statuses.map((s) => Tab(text: s)).toList(),
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                indicatorColor: Colors.white,
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

  InputDecoration _dec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.45),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.45),
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                task.priority,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            task.description,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  dueText,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (assignedName.trim().isNotEmpty)
            Text(
              'Assigned: $assignedName',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _statuses.contains(task.status)
                ? task.status
                : _statuses.first,
            items: _statuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (v) {
              if (v == null || v == task.status) return;
              onStatusChanged(v);
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
