import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/inquiry/inquiry_bloc.dart';
import '../../bloc/inquiry/inquiry_event.dart';
import '../../bloc/inquiry/inquiry_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../widgets/app_drawer.dart';

import '../../routes/app_routes.dart';

class InquiryListScreen extends StatefulWidget {
  const InquiryListScreen({super.key});

  @override
  State<InquiryListScreen> createState() => _InquiryListScreenState();
}

class _InquiryListScreenState extends State<InquiryListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<InquiryBloc>().add(InquiryFetched());
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'fresh':
        return AppColors.stageNew;
      case 'contacted':
        return AppColors.stageContacted;
      case 'interested':
        return AppColors.stageInterested;
      case 'negotiation':
      case 'reviewed':
        return AppColors.stageNegotiation;
      case 'converted':
        return AppColors.stageWon;
      case 'lost':
      case 'ignored':
        return AppColors.stageLost;
      default:
        return AppColors.stageFollowUp;
    }
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeRoute: AppRoutes.inquiryList),
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
              'Enquiries',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Manage all enquiries',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          // Refresh button
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: SvgPicture.asset(
              'assets/svgs/Enquiries.svg',
              width: 26,
              height: 26,
            ),
          ),
        ],
      ),

      body: ResponsiveConstraint(
        child: Column(
          children: <Widget>[
            // ── List ──
            Expanded(
              child: BlocConsumer<InquiryBloc, InquiryState>(
                // Rebuild on list status change OR when items change
                buildWhen: (p, c) => c.status != p.status || c.items != p.items,
                listenWhen: (p, c) => c.actionStatus != p.actionStatus,
                listener: (context, state) {
                  if (state.actionStatus == AppStatus.success) {
                    // Re-fetch after a successful action (create/delete/convert)
                    context.read<InquiryBloc>().add(InquiryFetched());
                  }
                },
                builder: (context, state) {
                  if (state.status == AppStatus.loading) {
                    return ShimmerLoading.listPlaceholder();
                  }
                  if (state.status == AppStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage ?? 'Failed to load enquiries',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => context.read<InquiryBloc>().add(
                              InquiryFetched(),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(
                              'Retry',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final items = state.items;
                  if (items.isEmpty) return _empty();

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async =>
                        context.read<InquiryBloc>().add(InquiryFetched()),
                    child: ListView.separated(
                      padding: responsiveListPadding(context),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final inq = items[i];
                        final sc = _statusColor(inq.status);
                        final initials = inq.name.isNotEmpty
                            ? inq.name
                                  .trim()
                                  .split(' ')
                                  .map((p) => p[0])
                                  .take(2)
                                  .join()
                                  .toUpperCase()
                            : '?';

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 150 + i * 40),
                          builder: (_, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: InkWell(
                            onTap: () async {
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.inquiryDetail,
                                arguments: inq,
                              );
                              // Refresh list when returning from detail (status may have changed)
                              if (context.mounted) {
                                context.read<InquiryBloc>().add(
                                  InquiryFetched(),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.6),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  // Left colour strip
                                  Container(
                                    width: 4,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      color: sc,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Avatar
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: sc.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: sc.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: GoogleFonts.poppins(
                                          color: sc,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Content
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Text(
                                                  inq.name,
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                    color: AppColors.primary,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              _pill(_cap(inq.status), sc),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            inq.phone,
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          if (inq.email.isNotEmpty) ...[
                                            const SizedBox(height: 1),
                                            Text(
                                              inq.email,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey.shade400,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                          if (inq.followUpDate != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 10,
                                                  color: AppColors.primary
                                                      .withOpacity(0.6),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Follow-up: ${inq.followUpDate!.toLocal().toString().split(' ').first}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.primary
                                                        .withOpacity(0.7),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Icon(
                                      Icons.chevron_right_rounded,
                                      size: 18,
                                      color: AppColors.primary.withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: GestureDetector(
        onTap: () async {
          await Navigator.pushNamed(context, AppRoutes.addInquiry);
          // Refresh after adding a new inquiry
          if (context.mounted) {
            context.read<InquiryBloc>().add(InquiryFetched());
          }
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                'New Enquiry',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _empty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/svgs/Enquiries.svg',
              width: 36,
              height: 36,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No enquiries found',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap + to add a new enquiry',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}
