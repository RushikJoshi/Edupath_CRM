import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:gtcrm/features/notification/presentation/bloc/notification_event.dart';
import 'package:gtcrm/features/notification/presentation/bloc/notification_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/notification/data/models/notification_model.dart';
import 'package:gtcrm/routes/app_routes.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final bloc = context.read<NotificationBloc>();
    bloc.add(const NotificationFetched());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '${weeks}w ago';
    final months = (diff.inDays / 30).floor();
    if (months < 12) return '${months}mo ago';
    final years = (diff.inDays / 365).floor();
    return '${years}y ago';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (p, c) =>
          p.actionStatus != c.actionStatus &&
          (c.actionStatus == AppStatus.success ||
              c.actionStatus == AppStatus.failure),
      listener: (context, state) {
        final success = state.actionStatus == AppStatus.success;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.actionMessage ?? (success ? 'Done' : 'Action failed'),
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
            ),
            backgroundColor: success ? AppColors.stageWon : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(10),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E8EFF),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          title: Text(
            'Notifications',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () => context.read<NotificationBloc>().add(
                    const NotificationFetched(),
                  ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ResponsiveConstraint(
          child: Column(
            children: [
              // Search & Read All controls row
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x40000000),
                              blurRadius: 4,
                              spreadRadius: 0,
                              offset: Offset.zero,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search Notifications...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.5),
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: Colors.black,
                              size: 22,
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Read All Button
                    BlocBuilder<NotificationBloc, NotificationState>(
                      buildWhen: (p, c) =>
                          p.unreadCount != c.unreadCount ||
                          p.actionStatus != c.actionStatus,
                      builder: (context, state) {
                        final canMarkAll =
                            state.unreadCount > 0 &&
                            state.actionStatus != AppStatus.loading;
                        return GestureDetector(
                          onTap: canMarkAll
                              ? () => context.read<NotificationBloc>().add(
                                    const NotificationMarkedAllRead(),
                                  )
                              : null,
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40000000),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset.zero,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.done_all_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Read All',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Notification List Content
              Expanded(
                child: BlocBuilder<NotificationBloc, NotificationState>(
                  builder: (context, state) {
                    if (state.status == AppStatus.loading && state.items.isEmpty) {
                      return ShimmerLoading.listPlaceholder(itemCount: 7);
                    }

                    if (state.status == AppStatus.failure && state.items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_off_rounded,
                              size: 42,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              state.errorMessage ?? 'Unable to load notifications',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 14),
                            FilledButton(
                              onPressed: () => context.read<NotificationBloc>().add(
                                    const NotificationFetched(),
                                  ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2E8EFF),
                              ),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    }

                    final query = _searchController.text.toLowerCase().trim();
                    final filteredItems = state.items.where((item) {
                      return query.isEmpty ||
                          item.title.toLowerCase().contains(query) ||
                          item.message.toLowerCase().contains(query);
                    }).toList();

                    return RefreshIndicator(
                      color: const Color(0xFF2E8EFF),
                      onRefresh: () async {
                        context.read<NotificationBloc>().add(
                              const NotificationFetched(),
                            );
                      },
                      child: filteredItems.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.2,
                                ),
                                Icon(
                                  Icons.notifications_none_rounded,
                                  size: 46,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'No notifications available',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return _notificationCard(context, item);
                              },
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemCount: filteredItems.length,
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.addInquiry);
          },
          backgroundColor: const Color(0xFF2E8EFF),
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _notificationCard(BuildContext context, NotificationModel item) {
    final created = item.createdAt;
    final isUnread = !item.isRead;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Bell Icon Circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2E8EFF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFF2E8EFF),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title & Timestamp & Red Dot Row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF2E8EFF),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            created != null ? _timeAgo(created) : '-',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Message
                Text(
                  item.message.isEmpty ? 'No message' : item.message,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                // Mark Read Button (Only for unread notifications)
                if (isUnread) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => context.read<NotificationBloc>().add(
                              NotificationMarkedRead(item.id),
                            ),
                        child: Text(
                          'Mark Read',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF2E8EFF),
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
