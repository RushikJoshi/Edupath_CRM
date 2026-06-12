import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/activity/activity_bloc.dart';
import '../../bloc/activity/activity_event.dart';
import '../../bloc/activity/activity_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../data/models/activity_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(
      const ActivitiesTimelineFetched(type: 'meeting'),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDay = DateTime(dt.year, dt.month, dt.day);
    if (logDay == today) {
      return 'Today ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    final yesterday = today.subtract(const Duration(days: 1));
    if (logDay == yesterday) {
      return 'Yesterday ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient),
          ),
        ),
        elevation: 0,
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Activity',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Track team activity',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Icon(
              Icons.history_rounded,
              size: 28,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
      body: ResponsiveConstraint(
        child: BlocBuilder<ActivityBloc, ActivityState>(
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
                        onPressed: () => context.read<ActivityBloc>().add(
                          const ActivitiesTimelineFetched(type: 'meeting'),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final items = state.items;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ActivityBloc>().add(
                  const ActivitiesTimelineFetched(type: 'meeting'),
                );
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: AppColors.primary,
              child: items.isEmpty
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
                                  color: AppColors.primary.withOpacity(0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.history_toggle_off_rounded,
                                  size: 48,
                                  color: AppColors.primary.withOpacity(0.4),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No activity yet',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: responsiveListPadding(context),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _ActivityTile(
                        item: items[index],
                        formatDate: _formatDate,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.formatDate});

  final ActivityModel item;
  final String Function(DateTime) formatDate;

  Color _actionColor(String actionType) {
    final a = actionType.toLowerCase();
    if (a.contains('create') || a.contains('added')) return Colors.teal;
    if (a.contains('delete') || a.contains('remove')) return Colors.red;
    if (a.contains('update') || a.contains('edit') || a.contains('change'))
      return AppColors.primary;
    if (a.contains('meeting')) return AppColors.stageFollowUp;
    return Colors.grey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final initials = item.userName.isNotEmpty
        ? item.userName
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'EP';

    final actionColor = _actionColor(item.type);
    final displayType = item.type.replaceAll('_', ' ').replaceAll('-', ' ');
    final noteText = item.note.trim();
    final headline = noteText.isNotEmpty ? noteText : 'Activity logged';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Side color indicator
              Container(width: 4, color: actionColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                // User Avatar
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: actionColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: GoogleFonts.poppins(
                                        color: actionColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.userName.isNotEmpty
                                        ? item.userName
                                        : 'System',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            formatDate(item.createdAt),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        headline,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Small context tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: actionColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          displayType.isEmpty
                              ? 'ACTIVITY'
                              : displayType.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: actionColor.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
