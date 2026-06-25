import 'package:flutter_screenutil/flutter_screenutil.dart';
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
                fontSize: 20.sp,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () =>
                    context.read<PipelineBloc>().add(PipelinesFetched()),
              ),
              SizedBox(width: 8.w),
            ],
          ),
          body: ResponsiveConstraint(
            child: SizedBox.expand(
              child: isLoading && pipelines.isEmpty
                  ? ShimmerLoading.listPlaceholder()
                  : hasError && pipelines.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
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
                            SizedBox(height: 16.h),
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
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.r),
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
                              SizedBox(height: 16.h),
                              Text(
                                'No pipelines yet. Add one using the button below.',
                                style: GoogleFonts.poppins(
                                  color: Colors.black54,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                            if (_selectedPipelineId != null) ...[
                              SizedBox(height: 24.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Stages',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      color: Colors.black,
                                    ),
                                  ),
                                  if (state.selectedPipelineId ==
                                          _selectedPipelineId &&
                                      isLoading)
                                    SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF2E8EFF),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: 8.h),
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
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ...stages.asMap().entries.map(
                                (e) => _StageTile(stage: e.value, index: e.key),
                              ),
                              if (stages.isEmpty && !isLoading)
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24.h),
                                  child: Text(
                                    'No stages in this pipeline. Add one below.',
                                    style: GoogleFonts.poppins(
                                      color: Colors.black54,
                                      fontSize: 13.sp,
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                  ),
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.add_chart_rounded,
                            color: Color(0xFF2E8EFF),
                          ),
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
                          leading: const Icon(
                            Icons.add_rounded,
                            color: Color(0xFF2E8EFF),
                          ),
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
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        );
      },
    );
  }

  void _showAddPipelineDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color(0xFF2E8EFF),
                              width: 1.w,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Icon(
                            Icons.show_chart_rounded,
                            color: Color(0xFF2E8EFF),
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          'Add Pipeline',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16.sp,
                            color: const Color(0xFF2E8EFF),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    TextFormField(
                      controller: nameCtrl,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Name',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF2E8EFF),
                          ),
                        ),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Pipeline name is required'
                          : null,
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: descCtrl,
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Description (Optional)',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade500,
                        ),
                        prefixIcon: const Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: const BorderSide(
                            color: Color(0xFF2E8EFF),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E8EFF),
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final name = nameCtrl.text.trim();
                          context.read<PipelineBloc>().add(
                            PipelineCreated(
                              name: name,
                              description: descCtrl.text.trim().isEmpty
                                  ? null
                                  : descCtrl.text.trim(),
                            ),
                          );
                          Navigator.pop(ctx);
                        }
                      },
                      child: Text(
                        'Create',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
            borderRadius: BorderRadius.circular(20.r),
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
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: orderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Order',
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: probCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Probability (%)',
                    hintText: '0',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                DropdownButtonFormField<String>(
                  value: winLikelihood,
                  decoration: InputDecoration(
                    labelText: 'Win likelihood',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
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
                  borderRadius: BorderRadius.circular(10.r),
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
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
              width: 26.w,
              height: 26.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              width: 38.w,
              height: 38.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(11.r),
                border: Border.all(color: color.withOpacity(0.25)),
              ),
              child: Icon(Icons.label_rounded, size: 18, color: color),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: Colors.black,
                    ),
                  ),
                  if (stage.order > 0 ||
                      stage.probability > 0 ||
                      stage.winLikelihood.isNotEmpty)
                    Text(
                      'Order: ${stage.order} · ${stage.probability}% · ${stage.winLikelihood}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 10.w,
              height: 10.h,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
    );
  }
}
