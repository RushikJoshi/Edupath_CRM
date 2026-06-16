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

class AddDealScreen extends StatefulWidget {
  const AddDealScreen({super.key});

  @override
  State<AddDealScreen> createState() => _AddDealScreenState();
}

class _AddDealScreenState extends State<AddDealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _leadIdCtrl = TextEditingController();
  final _customerIdCtrl = TextEditingController();
  final _contactIdCtrl = TextEditingController();
  final _assignedToCtrl = TextEditingController();
  final _pipelineIdCtrl = TextEditingController();
  final _stageIdCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  String _stage = '';
  String _priority = 'medium';
  String _currency = 'INR';
  DateTime? _expectedCloseDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _valueCtrl.dispose();
    _leadIdCtrl.dispose();
    _customerIdCtrl.dispose();
    _contactIdCtrl.dispose();
    _assignedToCtrl.dispose();
    _pipelineIdCtrl.dispose();
    _stageIdCtrl.dispose();
    _descriptionCtrl.dispose();
    _notesCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final value = num.tryParse(_valueCtrl.text.trim());
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter a valid value', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final stage = _stage.isEmpty
        ? (context.read<PipelineBloc>().state.dealStageNames.isNotEmpty
              ? context.read<PipelineBloc>().state.dealStageNames.first
              : 'New')
        : _stage;
    context.read<DealBloc>().add(
      DealCreated(
        title: _titleCtrl.text.trim(),
        value: value,
        stage: stage,
        leadId: _leadIdCtrl.text.trim().isEmpty
            ? null
            : _leadIdCtrl.text.trim(),
        customerId: _customerIdCtrl.text.trim().isEmpty
            ? null
            : _customerIdCtrl.text.trim(),
        contactId: _contactIdCtrl.text.trim().isEmpty
            ? null
            : _contactIdCtrl.text.trim(),
        assignedTo: _assignedToCtrl.text.trim().isEmpty
            ? null
            : _assignedToCtrl.text.trim(),
        pipelineId: _pipelineIdCtrl.text.trim().isEmpty
            ? null
            : _pipelineIdCtrl.text.trim(),
        stageId: _stageIdCtrl.text.trim().isEmpty
            ? null
            : _stageIdCtrl.text.trim(),
        currency: _currency,
        priority: _priority,
        description: _descriptionCtrl.text.trim().isEmpty
            ? null
            : _descriptionCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        tags: _tagsCtrl.text.trim().isEmpty
            ? null
            : _tagsCtrl.text
                  .trim()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
        expectedCloseDate: _expectedCloseDate
            ?.toIso8601String()
            .split('T')
            .first,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DealBloc, DealState>(
      listenWhen: (p, c) => c.actionStatus != p.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == AppStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage ?? 'Account created successfully',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppColors.stageWon,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        } else if (state.actionStatus == AppStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.actionMessage ?? 'Failed to create account',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          toolbarHeight: 64,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Accounts',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                'Add accounts like lead flow',
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
                'assets/svgs/deal.svg',
                width: 24,
                height: 24,
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ResponsiveConstraint(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                responsiveHorizontalPadding(context),
                16,
                responsiveHorizontalPadding(context),
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('CORE INFORMATION'),
                  const SizedBox(height: 12),
                  InnerShadow(
                    shadows: [
                      BoxShadow(
                        color: Colors.transparent,
                        blurRadius: 10,
                        offset: const Offset(2, 2),
                      ),
                    ],
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Account Title *'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _titleCtrl,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _decoration(
                              'e.g. Corporate Training Project',
                              Icons.title_rounded,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Title is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _label('Account Value (₹) *'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _valueCtrl,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _decoration(
                              'e.g. 150000',
                              Icons.currency_rupee_rounded,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Value is required';
                              if (num.tryParse(v.trim()) == null)
                                return 'Enter a valid amount';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _label('Account Stage'),
                          const SizedBox(height: 8),
                          Builder(
                            builder: (ctx) {
                              final stageNames = ctx
                                  .watch<PipelineBloc>()
                                  .state
                                  .dealStageNames;
                              final options = stageNames.isEmpty
                                  ? ['New']
                                  : stageNames;
                              final value = _stage.isEmpty && options.isNotEmpty
                                  ? options.first
                                  : (_stage.isEmpty ? 'New' : _stage);
                              final effectiveValue = options.contains(value)
                                  ? value
                                  : (options.isNotEmpty
                                        ? options.first
                                        : 'New');
                              return DropdownButtonFormField<String>(
                                value: effectiveValue,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: _decoration(
                                  '',
                                  Icons.stairs_rounded,
                                ),
                                items: options
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(
                                  () => _stage = v ?? effectiveValue,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final isNarrow = constraints.maxWidth < 380;
                              final currencyField = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Currency'),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _currency,
                                    decoration: _decoration(
                                      '',
                                      Icons.payments_rounded,
                                    ),
                                    items: ['INR', 'USD', 'EUR', 'GBP']
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => _currency = v ?? 'INR'),
                                  ),
                                ],
                              );
                              final priorityField = Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _label('Priority'),
                                  const SizedBox(height: 8),
                                  DropdownButtonFormField<String>(
                                    value: _priority,
                                    decoration: _decoration(
                                      '',
                                      Icons.priority_high_rounded,
                                    ),
                                    items: ['low', 'medium', 'high']
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text(s.toUpperCase()),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => setState(
                                      () => _priority = v ?? 'medium',
                                    ),
                                  ),
                                ],
                              );

                              if (isNarrow) {
                                return Column(
                                  children: [
                                    currencyField,
                                    const SizedBox(height: 12),
                                    priorityField,
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(child: currencyField),
                                  const SizedBox(width: 12),
                                  Expanded(child: priorityField),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _label('Expected Close Date'),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate:
                                    _expectedCloseDate ?? DateTime.now(),
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 365),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365 * 5),
                                ),
                              );
                              if (d != null)
                                setState(() => _expectedCloseDate = d);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 18,
                                    color: AppColors.primary.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _expectedCloseDate == null
                                        ? 'Select Date'
                                        : '${_expectedCloseDate!.day}/${_expectedCloseDate!.month}/${_expectedCloseDate!.year}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _expectedCloseDate == null
                                          ? Colors.grey.shade400
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _label('Description'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionCtrl,
                            maxLines: 3,
                            style: GoogleFonts.poppins(fontSize: 14),
                            decoration: _decoration(
                              'Enter account description...',
                              Icons.description_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(height: 8),
                  InnerShadow(
                    shadows: [
                      BoxShadow(
                        color: Colors.transparent,
                        blurRadius: 10,
                        offset: const Offset(3, 3),
                      ),
                    ],
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: BlocBuilder<DealBloc, DealState>(
                        builder: (context, state) {
                          final isLoading =
                              state.actionStatus == AppStatus.loading;
                          return FilledButton(
                            onPressed: isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'SAVE ACCOUNT',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                          );
                        },
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
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.grey.shade700,
    ),
  );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(
      fontSize: 13,
      color: Colors.grey.shade400,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: Colors.white,
    prefixIcon: Icon(icon, size: 18, color: AppColors.primary.withOpacity(0.6)),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.2)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
  );
}
