import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
                    fontSize: 14,
                    color: const Color(0xFF000000),
                  ),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search enquiries...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF000000).withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF000000),
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
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
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
                    color: const Color(0xFF2E8EFF),
                    onRefresh: _refreshLeads,
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
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
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              // Avatar
                                              CircleAvatar(
                                                radius: 24,
                                                backgroundColor: const Color(0xFF2E8EFF).withOpacity(0.1),
                                                child: Text(
                                                  initials,
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFF2E8EFF),
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
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
                                                        fontSize: 15,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      lead.companyName?.trim().isNotEmpty == true
                                                          ? lead.companyName!
                                                          : (lead.branchName.trim().isNotEmpty ? lead.branchName : 'No Company'),
                                                      style: GoogleFonts.poppins(
                                                        color: const Color(0xFF000000).withOpacity(0.8),
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 12,
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
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        const Divider(height: 1, color: Color(0x332E8EFF)),
                                        const SizedBox(height: 10),

                                        // --- MIDDLE ROW ---
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 14),
                                            // Phone Icon and text
                                            const Icon(
                                              Icons.phone_outlined,
                                              size: 16,
                                              color: Color(0xFF2E8EFF),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                lead.phone.isNotEmpty ? lead.phone : 'No phone',
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xE5000000),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            // Email Icon and text
                                            const Icon(
                                              Icons.email_outlined,
                                              size: 16,
                                              color: Color(0xFF2E8EFF),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                lead.email.isNotEmpty ? lead.email : 'No email',
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xE5000000),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Divider(height: 1, color: Color(0x332E8EFF)),
                                        const SizedBox(height: 10),

                                        // --- BOTTOM ROW ---
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          child: Row(
                                            children: [
                                              // Status Pill
                                              _pill(lead.stage.toUpperCase(), sc),
                                              const SizedBox(width: 10),
                                              // Assigned User Name
                                              const Icon(
                                                Icons.person_outline_rounded,
                                                size: 16,
                                                color: Color(0xFF2E8EFF),
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  lead.assignedTo.isNotEmpty ? lead.assignedTo : 'Unassigned',
                                                  style: GoogleFonts.poppins(
                                                    color: const Color(0xFF000000),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
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
                                      width: 26,
                                      height: 46,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2E8EFF),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _Dot(),
                                              SizedBox(width: 3),
                                              _Dot(),
                                            ],
                                          ),
                                          SizedBox(height: 3),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _Dot(),
                                              SizedBox(width: 3),
                                              _Dot(),
                                            ],
                                          ),
                                          SizedBox(height: 3),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _Dot(),
                                              SizedBox(width: 3),
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
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addLead);
          if (context.mounted) {
            context.read<LeadBloc>().add(const LeadFetched());
          }
        },
        backgroundColor: const Color(0xFF2E8EFF),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
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

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
