import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';


import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_event.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/routes/app_routes.dart';
import 'package:gtcrm/core/widgets/app_drawer.dart';
import 'package:gtcrm/core/constants/lead_pipeline_stages.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  String _getTimeAgo(String id) {
    try {
      if (id.length >= 8) {
        final seconds = int.parse(id.substring(0, 8), radix: 16);
        final time = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        final diff = DateTime.now().difference(time);
        if (diff.inDays > 365) {
          return '${(diff.inDays / 365).floor()}y ago';
        } else if (diff.inDays > 30) {
          return '${(diff.inDays / 30).floor()}mo ago';
        } else if (diff.inDays > 0) {
          return '${diff.inDays}d ago';
        } else if (diff.inHours > 0) {
          return '${diff.inHours}h ago';
        } else if (diff.inMinutes > 0) {
          return '${diff.inMinutes}m ago';
        } else {
          return 'just now';
        }
      }
    } catch (e) {
      // ignore
    }
    return '2h ago';
  }

  Future<void> _refreshLeads() async {
    final q = _searchCtrl.text.trim();
    context.read<LeadBloc>().add(LeadFetched(search: q.isEmpty ? null : q));
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  void initState() {
    super.initState();
    context.read<LeadBloc>().add(LeadFetched());
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final q = _searchCtrl.text.trim();
      context.read<LeadBloc>().add(LeadFetched(search: q.isEmpty ? null : q));
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _stageColor(String s) {
    switch (s.toLowerCase()) {
      case 'new':
        return AppColors.stageNew;
      case 'contacted':
        return AppColors.stageContacted;
      case 'interested':
        return AppColors.stageInterested;
      case 'negotiation':
        return AppColors.stageNegotiation;
      case 'converted':
        return AppColors.stageWon;
      case 'lost':
        return AppColors.stageLost;
      default:
        return AppColors.stageFollowUp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeRoute: AppRoutes.leadList),

      // ── AppBar — same style as InquiryListScreen ──
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        toolbarHeight: 64,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leads',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                color: Colors.white,
              ),
            ),
            Text(
              'Manage your pipeline',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: SvgPicture.asset(
              'assets/svgs/leads.svg',
              width: 26.w,
              height: 26.h,
            ),
          ),
        ],
      ),

      body: ResponsiveConstraint(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: const Color(0xFF000000),
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search enquiries...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Color(0xFF000000).withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF000000),
                      size: 22,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10.h,
                      horizontal: 12.w,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.w,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1.5.w,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(height: 1.h, color: AppColors.primary.withOpacity(0.1)),

            // ── List ──
            Expanded(
              child: BlocBuilder<LeadBloc, LeadState>(
                builder: (context, state) {
                  if (state.status == AppStatus.loading) {
                    return ShimmerLoading.listPlaceholder();
                  }
                  if (state.status == AppStatus.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Error',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  // API already returns search-filtered list when search was sent
                  final filtered = state.items;

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _refreshLeads,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 90),
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 80.w,
                                  height: 80.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(24.r),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/svgs/leads.svg',
                                      width: 36.w,
                                      height: 36.h,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.primary.withOpacity(0.6),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No leads found',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Pull down to refresh',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF2E8EFF),
                    onRefresh: _refreshLeads,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) {
                        final lead = filtered[i];
                        final sc = _stageColor(lead.stage);
                        final initials = lead.name.isNotEmpty
                            ? lead.name
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
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.leadDetail,
                              arguments: lead,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // --- TOP ROW ---
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              // Avatar
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundColor: Color(0xFF2E8EFF).withOpacity(0.1),
                                                child: Text(
                                                  initials,
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFF2E8EFF),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              // Name & Company/Branch
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      lead.name,
                                                      style: GoogleFonts.poppins(
                                                        color: const Color(0xFF000000),
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 15.sp,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    SizedBox(height: 2.h),
                                                    Text(
                                                      lead.companyName?.trim().isNotEmpty == true
                                                          ? lead.companyName!
                                                          : (lead.branchName.trim().isNotEmpty ? lead.branchName : 'No Company'),
                                                      style: GoogleFonts.poppins(
                                                        color: Color(0xFF000000).withOpacity(0.8),
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12.sp,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      ),
                                                  ],
                                                ),
                                              ),
                                              // Time on far right
                                              Text(
                                                _getTimeAgo(lead.id),
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xE5000000),
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Divider(height: 1.h, color: Color(0x332E8EFF)),
                                        SizedBox(height: 10.h),

                                        // --- MIDDLE ROW (Was Bottom Row) ---
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                                          child: Row(
                                            children: [
                                              // Status Pill
                                              _pill(lead.stage.toUpperCase(), sc),
                                              SizedBox(width: 10.w),
                                              // Assigned User Name
                                              const Icon(
                                                Icons.person_outline_rounded,
                                                size: 16,
                                                color: Color(0xFF2E8EFF),
                                              ),
                                              SizedBox(width: 4.w),
                                              Flexible(
                                                child: Text(
                                                  lead.assignedTo.isNotEmpty ? lead.assignedTo : 'Unassigned',
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFF000000),
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Divider(height: 1.h, color: Color(0x332E8EFF)),
                                        SizedBox(height: 10.h),

                                        // --- BOTTOM ROW (Was Middle Row) ---
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.phone_outlined,
                                                    size: 16,
                                                    color: Color(0xFF2E8EFF),
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Flexible(
                                                    child: Text(
                                                      lead.phone.isNotEmpty ? lead.phone : 'No phone',
                                                      style: GoogleFonts.poppins(
                                                        color: const Color(0xE5000000),
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 6.h),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.email_outlined,
                                                    size: 16,
                                                    color: Color(0xFF2E8EFF),
                                                  ),
                                                  SizedBox(width: 6.w),
                                                  Expanded(
                                                    child: Text(
                                                      lead.email.isNotEmpty ? lead.email : 'No email',
                                                      style: GoogleFonts.poppins(
                                                        color: const Color(0xE5000000),
                                                        fontSize: 12.sp,
                                                        fontWeight: FontWeight.w500,
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
                                  ),
                                  // Option capsule button (flush right, same style as Enquiry screen button)
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      AppRoutes.leadDetail,
                                      arguments: lead,
                                    ),
                                    child: Container(
                                      width: 26.w,
                                      height: 46.h,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2E8EFF),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10.r),
                                          bottomLeft: Radius.circular(10.r),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _Dot(),
                                              SizedBox(width: 3.w),
                                              _Dot(),
                                            ],
                                          ),
                                          SizedBox(height: 3.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _Dot(),
                                              SizedBox(width: 3.w),
                                              _Dot(),
                                            ],
                                          ),
                                          SizedBox(height: 3.h),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _Dot(),
                                              SizedBox(width: 3.w),
                                              _Dot(),
                                            ],
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
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'add_lead_fab',
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addLead);
          if (context.mounted) {
            context.read<LeadBloc>().add(LeadFetched());
          }
        },
        backgroundColor: const Color(0xFF2E8EFF),
        shape: const CircleBorder(),
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4.w,
      height: 4.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}