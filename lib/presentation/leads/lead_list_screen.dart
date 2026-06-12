import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/lead/lead_bloc.dart';
import '../../bloc/lead/lead_event.dart';
import '../../bloc/lead/lead_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../routes/app_routes.dart';
import '../widgets/app_drawer.dart';
import '../../core/constants/lead_pipeline_stages.dart';

class LeadListScreen extends StatefulWidget {
  const LeadListScreen({super.key});

  @override
  State<LeadListScreen> createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;

  Future<void> _refreshLeads() async {
    final q = _searchCtrl.text.trim();
    context.read<LeadBloc>().add(LeadFetched(search: q.isEmpty ? null : q));
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  void initState() {
    super.initState();
    context.read<LeadBloc>().add(const LeadFetched());
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
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
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
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            Text(
              'Manage your pipeline',
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
            child: SvgPicture.asset(
              'assets/svgs/leads.svg',
              width: 26,
              height: 26,
            ),
          ),
        ],
      ),

      body: ResponsiveConstraint(
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: EdgeInsets.fromLTRB(
                responsiveHorizontalPadding(context),
                10,
                responsiveHorizontalPadding(context),
                10,
              ),
              child: Column(
                children: <Widget>[
                  InnerShadow(
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
                        fontSize: 14,
                        color: AppColors.primary,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by name or agent...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppColors.primary.withOpacity(0.1)),

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
                  final filtered = state.items
                      .where((e) => !isLeadStageWon(e.stage))
                      .toList();

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
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/svgs/leads.svg',
                                      width: 36,
                                      height: 36,
                                      colorFilter: ColorFilter.mode(
                                        AppColors.primary.withOpacity(0.6),
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No leads found',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pull down to refresh',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
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
                    color: AppColors.primary,
                    onRefresh: _refreshLeads,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: responsiveListPadding(context),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
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
                          child: InnerShadow(
                            shadows: [
                              BoxShadow(
                                color: Colors.transparent,
                                blurRadius: 10,
                                offset: const Offset(2, 2),
                              ),
                            ],
                            child: InkWell(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.leadDetail,
                                arguments: lead,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 1,
                                  ),
                                ),
                                child: IntrinsicHeight(
                                  child: Row(
                                    children: <Widget>[
                                      const SizedBox(width: 12),
                                      // Avatar
                                      Container(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.08,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primary
                                                .withOpacity(0.15),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            initials,
                                            style: GoogleFonts.poppins(
                                              color: AppColors.primary,
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
                                                      lead.name,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 14,
                                                            color: AppColors
                                                                .primary,
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  _pill(lead.stage, sc),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Row(
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.person_outline,
                                                    size: 12,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    lead.assignedTo,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: Icon(
                                          Icons.chevron_right_rounded,
                                          size: 18,
                                          color: AppColors.primary.withOpacity(
                                            0.4,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
          await Navigator.pushNamed(context, AppRoutes.addLead);
          if (context.mounted) {
            context.read<LeadBloc>().add(const LeadFetched());
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
                'New Lead',
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
}
