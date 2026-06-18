import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:gtcrm/features/activity/presentation/bloc/activity_event.dart';
import 'package:gtcrm/features/activity/presentation/bloc/activity_state.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/activity/data/models/activity_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ActivityBloc>().add(
      const ActivitiesTimelineFetched(type: 'meeting'),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
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
            size: 22,
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
              size: 26,
            ),
            onPressed: () {
              context.read<ActivityBloc>().add(
                const ActivitiesTimelineFetched(type: 'meeting'),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveConstraint(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 4,
                      offset: Offset.zero,
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.black, size: 22),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 14,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<ActivityBloc, ActivityState>(
                buildWhen: (prev, curr) =>
                    prev.status != curr.status || prev.items != curr.items,
                builder: (context, state) {
                  if (state.status == AppStatus.loading && state.items.isEmpty) {
                    return ShimmerLoading.listPlaceholder();
                  }
                  if (state.status == AppStatus.failure && state.items.isEmpty) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Failed to load activity',
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                    );
                  }

                  final filteredItems = state.items.where((item) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    return item.userName.toLowerCase().contains(q) ||
                        item.note.toLowerCase().contains(q) ||
                        item.type.toLowerCase().contains(q);
                  }).toList();

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ActivityBloc>().add(
                        const ActivitiesTimelineFetched(type: 'meeting'),
                      );
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
                                child: Text(
                                  'No activity found',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) => _ActivityTile(
                              item: filteredItems[index],
                              formatDate: _formatDate,
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

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.formatDate});

  final ActivityModel item;
  final String Function(DateTime) formatDate;

  @override
  Widget build(BuildContext context) {
    final initials = item.userName.isNotEmpty
        ? item.userName
            .trim()
            .split(' ')
            .map((p) => p.isNotEmpty ? p[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : 'EP';

    final displayType = item.type.replaceAll('_', ' ').replaceAll('-', ' ');
    final headline = item.note.trim().isNotEmpty ? item.note.trim() : 'Activity logged';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            offset: Offset.zero,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initials.isEmpty ? 'G' : initials,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E8EFF),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.userName.isNotEmpty ? item.userName : 'System',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      headline,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatDate(item.createdAt),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E8EFF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      displayType.isEmpty ? 'Activity' : displayType,
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
