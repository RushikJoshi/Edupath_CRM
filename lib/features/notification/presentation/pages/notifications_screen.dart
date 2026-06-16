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

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<NotificationBloc>();
    bloc.add(const NotificationFetched());
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
            ),
            backgroundColor: success ? AppColors.stageWon : AppColors.error,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Notifications',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              buildWhen: (p, c) =>
                  p.unreadCount != c.unreadCount ||
                  p.actionStatus != c.actionStatus,
              builder: (context, state) {
                final canMarkAll =
                    state.unreadCount > 0 &&
                    state.actionStatus != AppStatus.loading;
                return TextButton(
                  onPressed: canMarkAll
                      ? () => context.read<NotificationBloc>().add(
                          const NotificationMarkedAllRead(),
                        )
                      : null,
                  child: Text(
                    'Read All',
                    style: GoogleFonts.poppins(
                      color: canMarkAll
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ResponsiveConstraint(
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
                          backgroundColor: AppColors.primary,
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<NotificationBloc>().add(
                    const NotificationFetched(),
                  );
                },
                child: state.items.isEmpty
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
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return _notificationCard(context, item);
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: state.items.length,
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _notificationCard(BuildContext context, NotificationModel item) {
    final created = item.createdAt;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.isRead
                  ? Colors.grey.shade100
                  : AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isRead
                  ? Icons.notifications_none_rounded
                  : Icons.notifications_active_rounded,
              color: item.isRead ? Colors.grey.shade600 : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: item.isRead
                              ? FontWeight.w600
                              : FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.message.isEmpty ? 'No message' : item.message,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      created != null ? _timeAgo(created) : '-',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (!item.isRead)
                      TextButton(
                        onPressed: () => context.read<NotificationBloc>().add(
                          NotificationMarkedRead(item.id),
                        ),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(0, 30),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: Text(
                          'Mark Read',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
}
