import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_event.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_bloc.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_event.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/features/pipeline/data/models/stage_model.dart';

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
    context.read<PipelineBloc>().add(const PipelinesFetched());
    context.read<LeadBloc>().add(const LeadFetched());
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
        toolbarHeight: 110,
        title: Text(
          'Sales Pipeline',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocBuilder<PipelineBloc, PipelineState>(
        builder: (context, state) {
          if (state.status == AppStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == AppStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error.withOpacity(0.9),
                      size: 34,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.errorMessage?.isNotEmpty == true
                          ? state.errorMessage!
                          : 'Failed to load pipeline',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.read<PipelineBloc>().add(
                        const PipelinesFetched(),
                      ),
                      icon: const Icon(Icons.refresh),
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

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.25),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedPipeline?.id,
                            isExpanded: true,
                            hint: Text(
                              'Select Pipeline',
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontSize: 13,
                              ),
                            ),
                            items: state.pipelines
                                .map(
                                  (p) => DropdownMenuItem<String>(
                                    value: p.id,
                                    child: Text(
                                      p.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (id) =>
                                setState(() => _selectedPipelineId = id),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => context.read<PipelineBloc>().add(
                        const PipelinesFetched(),
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildKanbanView(
                  stages: leadStages.map((s) => s.name).toList(),
                  allStages: leadStages,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKanbanView({
    required List<String> stages,
    required List<StageModel> allStages,
  }) {
    if (stages.isEmpty) {
      return Center(
        child: Text(
          'No pipelines found',
          style: GoogleFonts.poppins(color: Colors.grey),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withOpacity(0.05), AppColors.background],
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: stages.map((stage) {
            final sm = allStages.firstWhere(
              (s) => s.name == stage,
              orElse: () => const StageModel(id: '', name: '', pipelineId: ''),
            );
            return _buildStageColumn(sm);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStageColumn(StageModel stage) {
    Color sc;
    try {
      if (stage.color.isNotEmpty) {
        final hex = stage.color.replaceAll('#', '');
        sc = Color(int.parse('FF$hex', radix: 16));
      } else {
        sc = AppColors.primary;
      }
    } catch (_) {
      sc = AppColors.primary;
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    stage.name.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: sc,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _StageBadge(count: _getCount(stage.name), color: sc),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Scrollable Cards Area
          Expanded(child: _buildCardsList(stage.name)),
        ],
      ),
    );
  }

  int _getCount(String stageName) {
    final leads = context.watch<LeadBloc>().state.items;
    return leads
        .where((l) => l.stage.toLowerCase() == stageName.toLowerCase())
        .length;
  }

  Widget _buildCardsList(String stageName) {
    final items = context
        .watch<LeadBloc>()
        .state
        .items
        .where((i) => i.stage.toLowerCase() == stageName.toLowerCase())
        .toList();

    if (items.isEmpty) {
      return _EmptyStageCard();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _KanbanCard(
          title: (item as dynamic).name,
          subtitle: (item as dynamic).phone,
          amount: (item as dynamic).value?.toString() ?? '0',
          branch: (item as dynamic).branchName ?? '',
        );
      },
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        count.toString(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyStageCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          'No items',
          style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
        ),
      ),
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.branch,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String branch;

  @override
  Widget build(BuildContext context) {
    return InnerShadow(
      shadows: [
        BoxShadow(
          color: Colors.transparent,
          blurRadius: 10,
          offset: const Offset(2, 2),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '₹$amount',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    branch,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade500,
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
    );
  }
}
