import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_bloc.dart';
import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_event.dart';
import 'package:gtcrm/features/audit_log/presentation/bloc/audit_log_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/audit_log/data/models/audit_log_model.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<AuditLogBloc>().add(AuditLogsFetched());
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatRelativeTime(DateTime dt) {
    final difference = DateTime.now().difference(dt);
    if (difference.inMinutes < 60) {
      if (difference.inMinutes <= 0) return 'Just now';
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8EFF),
        elevation: 0,
        toolbarHeight: 64,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Activity',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              context.read<AuditLogBloc>().add(AuditLogsFetched());
            },
          ),
        ],
      ),
      body: ResponsiveConstraint(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Container(
                height: 39,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000), // #00000040 (25% opacity)
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: Offset(0, 0), // x 0, y 0
                    ),
                  ],
                ),
                child:Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(Icons.search_rounded, size: 20,color: Colors.black,),
                      SizedBox(width: 7,),
                      Text('Search...',style: TextStyle(fontSize: 13, color: Colors.grey.shade500,),)

                    ],
                  ),
                )
                // TextField(
                //   controller: _searchCtrl,
                //   style: GoogleFonts.poppins(
                //     fontSize: 13,
                //     color: Colors.black,
                //   ),
                //   decoration: InputDecoration(
                //     hintText: 'Search...',
                //     hintStyle: GoogleFonts.poppins(
                //       fontSize: 13,
                //       color: Colors.grey.shade500,
                //     ),
                //     prefixIcon: const Icon(
                //       Icons.search_rounded,
                //       color: Colors.black,
                //     ),
                //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                //     border: InputBorder.none,
                //     enabledBorder: InputBorder.none,
                //     focusedBorder: InputBorder.none,
                //   ),
                // ),
              ),
            ),
            Expanded(
              child: BlocBuilder<AuditLogBloc, AuditLogState>(
                buildWhen: (prev, curr) =>
                    prev.status != curr.status || prev.items != curr.items,
                builder: (context, state) {
                  if (state.status == AppStatus.loading && state.items.isEmpty) {
                    return ShimmerLoading.listPlaceholder();
                  }
                  if (state.status == AppStatus.failure && state.items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.errorMessage ?? 'Failed to load activity',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: AppColors.error),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<AuditLogBloc>().add(
                                AuditLogsFetched(),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final items = state.items;
                  final filteredItems = items.where((log) {
                    if (_searchQuery.isEmpty) return true;
                    final userName = log.userName.toLowerCase();
                    final action = log.action.toLowerCase();
                    final entityType = log.entityType.toLowerCase();
                    final details = log.details.toLowerCase();
                    return userName.contains(_searchQuery) ||
                        action.contains(_searchQuery) ||
                        entityType.contains(_searchQuery) ||
                        details.contains(_searchQuery);
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<AuditLogBloc>().add(AuditLogsFetched());
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    color: const Color(0xFF2E8EFF),
                    child: filteredItems.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.2,
                              ),
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2E8EFF).withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.history_toggle_off_rounded,
                                        size: 48,
                                        color: const Color(0xFF2E8EFF).withOpacity(0.4),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No activity found',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF2E8EFF),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) => _LogTile(
                              log: filteredItems[index],
                              formatRelativeTime: _formatRelativeTime,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log, required this.formatRelativeTime});

  final AuditLogModel log;
  final String Function(DateTime) formatRelativeTime;

  Color _actionColor(String action) {
    final a = action.toLowerCase();
    if (a.contains('create') || a.contains('added')) return const Color(0xFF2EC4AC); // Teal/green
    if (a.contains('delete') || a.contains('remove')) return const Color(0xFFE53935); // Red
    if (a.contains('update') || a.contains('edit') || a.contains('change')) {
      return const Color(0xFF2E8EFF); // Blue
    }
    return const Color(0xFF2E8EFF);
  }

  @override
  Widget build(BuildContext context) {
    final initial = log.userName.isNotEmpty
        ? log.userName.trim()[0].toUpperCase()
        : 'S';

    final actionColor = _actionColor(log.action);
    final displayAction = log.action.replaceAll('_', ' ').replaceAll('-', ' ');
    final displayEntity = log.entityType.replaceAll('_', ' ').replaceAll('-', ' ');

    final timeText = formatRelativeTime(log.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000), // #00000040 (25% opacity)
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 0), // x 0, y 0
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User Avatar (Rounded square with border)
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: actionColor.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                initial,
                style: GoogleFonts.poppins(
                  color: actionColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Log Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      log.userName.isNotEmpty ? log.userName : 'System',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: const Color(0xFF2E8EFF),
                      ),
                    ),
                    Text(
                      timeText,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        () {
                          final e = displayEntity.isEmpty ? 'record' : displayEntity.toLowerCase();
                          final a = displayAction.toLowerCase();
                          String actionWord = 'updated';
                          if (a.contains('create') || a.contains('added')) {
                            actionWord = 'created';
                          } else if (a.contains('delete') || a.contains('remove')) {
                            actionWord = 'deleted';
                          }
                          
                          final displayE = e[0].toUpperCase() + e.substring(1);
                          
                          if (log.details.isNotEmpty) {
                            final firstChar = log.details[0].toUpperCase();
                            final rest = log.details.substring(1);
                            return '$firstChar$rest';
                          }
                          if (log.changesTo.isNotEmpty) {
                            return '$displayE $actionWord : ${log.changesTo}';
                          }
                          return '$displayE $actionWord';
                        }(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: actionColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        displayAction.split(' ').map((word) {
                          if (word.isEmpty) return '';
                          return word[0].toUpperCase() + word.substring(1).toLowerCase();
                        }).join(' '),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: actionColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
                
