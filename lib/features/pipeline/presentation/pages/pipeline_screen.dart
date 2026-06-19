import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/lead/presentation/bloc/lead_bloc.dart';
import 'package:gtcrm/features/lead/presentation/bloc/lead_event.dart';
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
    context.read<PipelineBloc>().add(const PipelinesFetched());
    context.read<LeadBloc>().add(const LeadFetched());
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
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<PipelineBloc>().add(const PipelinesFetched());
              context.read<LeadBloc>().add(const LeadFetched());
            },
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
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red,
                      size: 34,
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        context.read<PipelineBloc>().add(const PipelinesFetched());
                        context.read<LeadBloc>().add(const LeadFetched());
                      },
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
            length: leadStages.length,
            child: Column(
              children: [
                _buildSelectorButton(context, state, selectedPipeline),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
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
                  child: TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelColor: const Color(0xFF2E8EFF),
                    unselectedLabelColor: Colors.black87,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                    labelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorColor: const Color(0xFF2E8EFF),
                    indicatorWeight: 2.5,
                    tabs: leadStages.map((stage) {
                      final count = _getCount(stage.name);
                      return Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(stage.name),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              _StageBadge(
                                count: count,
                                color: const Color(0xFF2E8EFF),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: BoxDecoration(
                      color: const Color(0x0D2E8EFF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x0D2E8EFF)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: TabBarView(
                      children: leadStages.map((stage) {
                        return _buildCardsList(stage.name);
                      }).toList(),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8EFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_tree_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  selectedPipeline?.name ?? 'Select Pipeline',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetCtx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Pipeline',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
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
                  padding: const EdgeInsets.all(20),
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
                            fontSize: 14,
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
      return Center(
        child: Text(
          'No items',
          style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return _PipelineCard(item: item);
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
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        count.toString(),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  const _PipelineCard({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final name = item.name ?? '';
    final phone = item.phone ?? '';
    final amount = item.value?.toString() ?? '0';
    final branch = item.branchName ?? '';

    final initials = name.isNotEmpty
        ? name
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2E8EFF).withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF2E8EFF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      phone,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (branch.isNotEmpty) ...[
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF2E8EFF),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            branch,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Value
          Text(
            '₹$amount',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2E8EFF),
            ),
          ),
        ],
      ),
    );
  }
}
