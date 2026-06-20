import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/lead/data/models/lead_model.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_event.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_state.dart';
import 'package:gtcrm/features/lead/presentation/pages/lead_detail_screen.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_bloc.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_event.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_state.dart';
import 'package:gtcrm/core/constants/app_enums.dart';

class PipelineScreen extends StatefulWidget {
  const PipelineScreen({super.key});

  @override
  State<PipelineScreen> createState() => _PipelineScreenState();
}

class _PipelineScreenState extends State<PipelineScreen> {
  String? _selectedPipelineId;

  @override
  void initState() {
    super.initState();
    context.read<PipelineBloc>().add(PipelinesFetched());
    context.read<LeadBloc>().add(LeadFetched());
    context.read<LeadBloc>().add(LostLeadsFetched());
  }

  void _refresh() {
    context.read<PipelineBloc>().add(PipelinesFetched());
    context.read<LeadBloc>().add(LeadFetched());
    context.read<LeadBloc>().add(LostLeadsFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8EFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sales Pipeline',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: BlocBuilder<PipelineBloc, PipelineState>(
        builder: (context, state) {
          if (state.status == AppStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E8EFF)),
            );
          }

          if (state.status == AppStatus.failure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 34,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      state.errorMessage?.isNotEmpty == true
                          ? state.errorMessage!
                          : 'Failed to load pipeline',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state.pipelines.isEmpty &&
              state.leadStages.isEmpty &&
              state.dealStages.isEmpty) {
            return Center(
              child: Text(
                'No pipelines found',
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            );
          }

          final selectedPipeline =
              state.pipelines
                  .where((p) => p.id == _selectedPipelineId)
                  .isNotEmpty
              ? state.pipelines.firstWhere((p) => p.id == _selectedPipelineId)
              : (state.pipelines.isNotEmpty ? state.pipelines.first : null);

          final leadStages =
              (selectedPipeline?.stages.isNotEmpty == true
                      ? selectedPipeline!.stages
                      : state.leadStages)
                  .where((s) => s.name.trim().isNotEmpty)
                  .toList();

          // Build tabs: stage tabs + Lost Leads tab
          final tabNames = [
            ...leadStages.map((s) => s.name),
            'Lost Leads',
          ];

          if (leadStages.isEmpty) {
            return Column(
              children: [
                _buildSelectorButton(context, state, selectedPipeline),
                Expanded(
                  child: Center(
                    child: Text(
                      'No stages found',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            );
          }

          return DefaultTabController(
            key: ValueKey(selectedPipeline?.id),
            length: tabNames.length,
            child: Column(
              children: [
                _buildSelectorButton(context, state, selectedPipeline),
                Divider(height: 1.h, thickness: 1, color: Color(0xFFE2E8F0)),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x40000000),
                        blurRadius: 4,
                        spreadRadius: 1,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                  child: BlocBuilder<LeadBloc, LeadState>(
                    buildWhen: (prev, curr) =>
                        prev.items != curr.items || prev.lostLeads != curr.lostLeads,
                    builder: (context, leadState) {
                      return TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        labelColor: const Color(0xFF2E8EFF),
                        unselectedLabelColor: Colors.black87,
                        labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        indicatorColor: const Color(0xFF2E8EFF),
                        indicatorWeight: 2.5,
                        tabs: tabNames.map((tabName) {
                          final isLostTab = tabName == 'Lost Leads';
                          final count = isLostTab
                              ? leadState.lostLeads.length
                              : _getCount(leadState, tabName);
                          return Tab(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isLostTab)
                                  Icon(Icons.cancel_outlined, size: 14, color: Colors.red),
                                if (isLostTab) SizedBox(width: 4.w),
                                Text(
                                  tabName,
                                  style: isLostTab
                                      ? GoogleFonts.poppins(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.red,
                                        )
                                      : null,
                                ),
                                if (count > 0) ...[
                                  SizedBox(width: 6.w),
                                  _StageBadge(
                                    count: count,
                                    color: isLostTab ? Colors.red : Color(0xFF2E8EFF),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
                Divider(height: 1.h, thickness: 1, color: Color(0xFFE2E8F0)),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0x0D2E8EFF),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0x0D2E8EFF)),
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: BlocBuilder<LeadBloc, LeadState>(
                      builder: (context, leadState) {
                        return TabBarView(
                          children: tabNames.map((tabName) {
                            if (tabName == 'Lost Leads') {
                              return _buildLostLeadsList(leadState);
                            }
                            return _buildCardsList(leadState, tabName);
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectorButton(
    BuildContext context,
    PipelineState state,
    dynamic selectedPipeline,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: GestureDetector(
        onTap: () => _showPipelineSelector(context, state, selectedPipeline),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                spreadRadius: 1,
                offset: Offset.zero,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8EFF),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_tree_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  selectedPipeline?.name ?? 'Select Pipeline',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: selectedPipeline != null ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black54,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPipelineSelector(
    BuildContext context,
    PipelineState state,
    dynamic selectedPipeline,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext sheetCtx) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Pipeline',
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.black54),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
              ),
              const Divider(),
              if (state.pipelines.isEmpty)
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Text('No pipelines available', style: GoogleFonts.poppins(color: Colors.grey)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.pipelines.length,
                    itemBuilder: (context, index) {
                      final p = state.pipelines[index];
                      final isSelected = p.id == selectedPipeline?.id;
                      return ListTile(
                        leading: Icon(
                          Icons.schema_outlined,
                          color: isSelected ? const Color(0xFF2E8EFF) : Colors.black54,
                        ),
                        title: Text(
                          p.name,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF))
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedPipelineId = p.id;
                          });
                          Navigator.pop(sheetCtx);
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  int _getCount(LeadState leadState, String stageName) {
    return leadState.items
        .where((l) => l.stage.toLowerCase() == stageName.toLowerCase())
        .length;
  }

  Widget _buildCardsList(LeadState leadState, String stageName) {
    final items = leadState.items
        .where((i) => i.stage.toLowerCase() == stageName.toLowerCase())
        .toList();

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No leads in this stage',
          style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13.sp),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final item = items[index];
        return _PipelineCard(
          item: item,
          onTap: () => _openLeadDetail(context, item),
        );
      },
    );
  }

  Widget _buildLostLeadsList(LeadState leadState) {
    if (leadState.lostStatus == AppStatus.loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF2E8EFF)));
    }

    final items = leadState.lostLeads;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_satisfied_alt, color: Colors.grey.shade300, size: 48),
            SizedBox(height: 12.h),
            Text(
              'No lost leads 🎉',
              style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14.sp),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final item = items[index];
        return _PipelineCard(
          item: item,
          isLost: true,
          onTap: () => _openLeadDetail(context, item),
        );
      },
    );
  }

  void _openLeadDetail(BuildContext context, LeadModel lead) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => LeadDetailScreen(lead: lead),
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18.w,
      height: 18.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        count.toString(),
        style: GoogleFonts.poppins(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  const _PipelineCard({required this.item, required this.onTap, this.isLost = false});
  final LeadModel item;
  final VoidCallback onTap;
  final bool isLost;

  @override
  Widget build(BuildContext context) {
    final name = item.name;
    final phone = item.phone;
    final amount = item.value?.toString() ?? '0';
    final branch = item.branchName;
    final stage = item.stage;
    final lostReason = item.lostReason;

    final initials = name.isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    final cardColor = isLost ? Color(0xFFFFF5F5) : Colors.white;
    final accentColor = isLost ? Colors.red : Color(0xFF2E8EFF);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isLost ? Colors.red.withValues(alpha: 0.2) : Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Initials Avatar
            Container(
              width: 42.w,
              height: 42.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.poppins(
                    color: accentColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      if (phone.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.phone_outlined, size: 12, color: Colors.grey.shade500),
                            SizedBox(width: 3.w),
                            Text(
                              phone,
                              style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      if (branch.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF2E8EFF)),
                            SizedBox(width: 2.w),
                            Text(
                              branch,
                              style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                    ],
                  ),
                  if (isLost && lostReason != null && lostReason.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 12, color: Colors.red),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            lostReason,
                            style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.red.shade400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Right side: value + stage badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹$amount',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    stage,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}