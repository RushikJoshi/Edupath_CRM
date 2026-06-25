import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/deal/presentation/bloc/deal_bloc.dart';
import 'package:gtcrm/features/deal/presentation/bloc/deal_event.dart';
import 'package:gtcrm/features/deal/presentation/bloc/deal_state.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_bloc.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/deal/data/models/deal_model.dart';
import 'package:gtcrm/features/pipeline/data/models/stage_model.dart';
import 'package:gtcrm/routes/app_routes.dart';
import 'package:gtcrm/core/widgets/app_drawer.dart';

class DealListScreen extends StatefulWidget {
  const DealListScreen({super.key});

  @override
  State<DealListScreen> createState() => _DealListScreenState();
}

class _DealListScreenState extends State<DealListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';

  Future<void> _refreshDeals() async {
    context.read<DealBloc>().add(DealFetched());
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  void initState() {
    super.initState();
    context.read<DealBloc>().add(DealFetched());
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _getStageColor(String name, List<StageModel> allStages) {
    final stage = allStages.firstWhere(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
      orElse: () => const StageModel(id: '', name: '', pipelineId: ''),
    );
    if (stage.color.isNotEmpty) {
      try {
        final hex = stage.color.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }
    switch (name.toLowerCase()) {
      case 'new':
      case 'new lead':
        return AppColors.stageNew;
      case 'negotiation':
        return AppColors.stageNegotiation;
      case 'won':
      case 'closed won':
        return AppColors.stageWon;
      case 'lost':
      case 'closed lost':
        return AppColors.stageLost;
      default:
        return AppColors.stageFollowUp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: const AppDrawer(activeRoute: AppRoutes.deals),
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
              'Accounts',
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
              'assets/svgs/deal.svg',
              width: 26.w,
              height: 26.h,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_deal_fab',
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.addDeal).then((_) {
              if (context.mounted) context.read<DealBloc>().add(DealFetched());
            }),
        icon: Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'ADD ACCOUNTS',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
            color: Colors.white,
            letterSpacing: 0.6,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: ResponsiveConstraint(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                responsiveHorizontalPadding(context),
                14,
                responsiveHorizontalPadding(context),
                14,
              ),
              child: InnerShadow(
                shadows: [
                  BoxShadow(
                    color: Colors.transparent,
                    blurRadius: 8,
                    offset: const Offset(2, 2),
                  ),
                ],
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search by title or stage...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 16.w,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 1.5.w,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(height: 1.h, color: AppColors.primary.withOpacity(0.1)),
            Expanded(
              child: BlocBuilder<DealBloc, DealState>(
                builder: (context, state) {
                  final pipelineState = context.watch<PipelineBloc>().state;
                  final allStages = pipelineState.dealStages;

                  if (state.status == AppStatus.loading) {
                    return ShimmerLoading.listPlaceholder();
                  }

                  if (state.status == AppStatus.failure) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _refreshDeals,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 120),
                        children: [
                          Center(
                            child: Text(
                              state.errorMessage ?? 'Error',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filtered = state.items.where((d) {
                    if (_searchQuery.isEmpty) return true;
                    return d.title.toLowerCase().contains(_searchQuery) ||
                        d.stage.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filtered.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _refreshDeals,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(top: 90),
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                      'assets/svgs/deal.svg',
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
                                  'No accounts found',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Pull down to refresh'
                                      : 'Try another search term',
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
                    onRefresh: _refreshDeals,
                    color: AppColors.primary,
                    child: ListView.separated(
                      padding: responsiveListPadding(context),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, i) {
                        final deal = filtered[i];
                        final sc = _getStageColor(deal.stage, allStages);
                        return _DealCard(deal: deal, color: sc);
                      },
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

class _DealCard extends StatelessWidget {
  const _DealCard({required this.deal, required this.color});

  final DealModel deal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final initials = deal.title.isNotEmpty
        ? deal.title
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'DL';

    return InnerShadow(
      shadows: [
        BoxShadow(
          color: Colors.transparent,
          blurRadius: 10,
          offset: const Offset(2, 2),
        ),
      ],
      child: InkWell(
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.dealDetail, arguments: deal),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.primary, width: 1.w),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(width: 12.w),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 14.h),
                  width: 44.w,
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.15),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                deal.title,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 9.w,
                                vertical: 3.h,
                              ),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(
                                  color: color.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                deal.stage,
                                style: GoogleFonts.poppins(
                                  color: color,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            Icon(
                              Icons.currency_rupee_rounded,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${deal.value} ${deal.currency}',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.person_outline,
                              size: 12,
                              color: Colors.grey.shade500,
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                deal.assignedTo.isEmpty
                                    ? 'Unassigned'
                                    : deal.assignedTo,
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 14),
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
      ),
    );
  }
}
