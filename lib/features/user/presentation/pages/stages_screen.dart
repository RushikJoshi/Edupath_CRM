import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_bloc.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_event.dart';
import 'package:gtcrm/features/pipeline/presentation/bloc/pipeline_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/pipeline/data/models/pipeline_model.dart';
import 'package:gtcrm/features/pipeline/data/models/stage_model.dart';

class StagesScreen extends StatefulWidget {
  const StagesScreen({super.key});

  @override
  State<StagesScreen> createState() => _StagesScreenState();
}

class _StagesScreenState extends State<StagesScreen> {
  String? _selectedPipelineId;

  @override
  void initState() {
    super.initState();
    context.read<PipelineBloc>().add(PipelinesFetched());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PipelineBloc, PipelineState>(
      listener: (context, state) {
        if (state.actionStatus == AppStatus.success &&
            state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage!),
              backgroundColor: Colors.green,
            ),
          );
        }
        if (state.actionStatus == AppStatus.failure &&
            state.actionMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.actionMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      buildWhen: (prev, curr) =>
          prev.status != curr.status ||
          prev.pipelines != curr.pipelines ||
          prev.stages != curr.stages ||
          prev.selectedPipelineId != curr.selectedPipelineId,
      builder: (context, state) {
        final pipelines = state.pipelines;
        PipelineModel? selectedPipeline;
        for (final p in pipelines) {
          if (p.id == _selectedPipelineId) {
            selectedPipeline = p;
            break;
          }
        }
        final stages =
            (state.selectedPipelineId == _selectedPipelineId &&
                state.stages.isNotEmpty)
            ? state.stages
            : (selectedPipeline?.stages ?? <StageModel>[]);
        final isLoading = state.status == AppStatus.loading;
        final hasError = state.status == AppStatus.failure;
        final errorMsg = state.errorMessage;

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2E8EFF),
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            title: Text(
              'Pipeline & Stages',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () => context.read<PipelineBloc>().add(PipelinesFetched()),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: ResponsiveConstraint(
            child: SizedBox.expand(
              child: isLoading && pipelines.isEmpty
                  ? ShimmerLoading.listPlaceholder()
                  : hasError && pipelines.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              errorMsg ?? 'Failed to load',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<PipelineBloc>().add(
                                PipelinesFetched(),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<PipelineBloc>().add(PipelinesFetched());
                      },
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          responsiveHorizontalPadding(context),
                          16,
                          responsiveHorizontalPadding(context),
                          100,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Pipeline selector
                            Text(
                              'Pipeline',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    offset: Offset.zero,
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedPipelineId,
                                  isExpanded: true,
                                  hint: Text(
                                    'Select pipeline',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.black,
                                    size: 24,
                                  ),
                                  items: [
                                    ...pipelines.map(
                                      (p) => DropdownMenuItem<String>(
                                        value: p.id,
                                        child: Text(
                                          p.name,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  onChanged: (id) {
                                    setState(() => _selectedPipelineId = id);
                                  },
                                ),
                              ),
                            ),
                            if (pipelines.isEmpty) ...[
                              const SizedBox(height: 16),
                              Text(
                                'No pipelines yet. Add one using the button below.',
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            if (_selectedPipelineId != null) ...[
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Stages',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (state.selectedPipelineId ==
                                          _selectedPipelineId &&
                                      isLoading)
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF2E8EFF),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (state.selectedPipelineId ==
                                      _selectedPipelineId &&
                                  hasError &&
                                  stages.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    errorMsg ?? 'Failed to load stages',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ...stages.asMap().entries.map(
                                (e) => _StageTile(stage: e.value, index: e.key),
                              ),
                              if (stages.isEmpty && !isLoading)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  child: Text(
                                    'No stages in this pipeline. Add one below.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'add_pipeline_stage_fab',
            onPressed: () {
              if (_selectedPipelineId == null) {
                _showAddPipelineDialog(context);
              } else {
                showModalBottomSheet<void>(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add_chart_rounded, color: Color(0xFF2E8EFF)),
                          title: Text(
                            'Add New Pipeline',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showAddPipelineDialog(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.add_rounded, color: Color(0xFF2E8EFF)),
                          title: Text(
                            'Add Stage to Current Pipeline',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showAddStageDialog(context, _selectedPipelineId!);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            backgroundColor: const Color(0xFF2E8EFF),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }

  void _showAddPipelineDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: Color(0xFF2E8EFF),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Add Pipeline',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: const Color(0xFF2E8EFF),
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: TextField(
                controller: nameCtrl,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Sales Pipeline',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: const Icon(
                    Icons.badge_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset.zero,
                  ),
                ],
              ),
              child: TextField(
                controller: descCtrl,
                maxLines: 2,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. CRM Sales Flow',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              context.read<PipelineBloc>().add(
                PipelineCreated(
                  name: name,
                  description: descCtrl.text.trim().isEmpty
                      ? null
                      : descCtrl.text.trim(),
                ),
              );
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E8EFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Create',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddStageDialog(BuildContext context, String pipelineId) {
    final nameCtrl = TextEditingController();
    final orderCtrl = TextEditingController(text: '0');
    final probCtrl = TextEditingController(text: '0');
    String winLikelihood = 'open';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Add Stage',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    hintText: 'e.g. Negotiation',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: orderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Order',
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: probCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Probability (%)',
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: winLikelihood,
                  decoration: InputDecoration(
                    labelText: 'Win likelihood',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: ['open', 'won', 'lost']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setDialogState(() => winLikelihood = v);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                final order = int.tryParse(orderCtrl.text.trim()) ?? 0;
                final probability = int.tryParse(probCtrl.text.trim()) ?? 0;
                context.read<PipelineBloc>().add(
                  StageCreated(
                    name: name,
                    pipelineId: pipelineId,
                    order: order,
                    probability: probability,
                    winLikelihood: winLikelihood,
                  ),
                );
                Navigator.pop(ctx);
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Create',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({required this.stage, required this.index});

  final StageModel stage;
  final int index;

  static Color _colorForIndex(int i) {
    final colors = [
      AppColors.stageNew,
      AppColors.stageContacted,
      AppColors.stageInterested,
      AppColors.stageFollowUp,
      AppColors.stageNegotiation,
      AppColors.stageWon,
      AppColors.stageLost,
    ];
    return colors[i % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForIndex(index);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x40000000),
              blurRadius: 4,
              spreadRadius: 0,
              offset: Offset.zero,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Icon(Icons.label_rounded, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  if (stage.order > 0 ||
                      stage.probability > 0 ||
                      stage.winLikelihood.isNotEmpty)
                    Text(
                      'Order: ${stage.order} · ${stage.probability}% · ${stage.winLikelihood}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}
