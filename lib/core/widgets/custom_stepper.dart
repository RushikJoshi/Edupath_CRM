import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

enum StepStatus { pending, completed, denied, current }

class StepDetail {
  const StepDetail({required this.title, required this.description});
  final String title;
  final String description;
}

class StepData {
  const StepData({
    required this.title,
    required this.status,
    this.details,
    this.statusColor,
    this.titleColor,
    this.isStepDisabled = false,
    this.showIcon = true,
  });

  final String title;
  final StepStatus status;
  final List<StepDetail>? details;
  final Color? statusColor;
  final Color? titleColor;
  final bool isStepDisabled;
  final bool showIcon;
}

class CustomStepper extends StatelessWidget {
  const CustomStepper({
    super.key,
    required this.steps,
    this.isHorizontal = false,
    this.onStepTap,
  });

  final List<StepData> steps;
  final bool isHorizontal;
  final void Function(int index, StepData step)? onStepTap;

  static IconData _iconForStatus(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return Icons.check_rounded;
      case StepStatus.denied:
        return Icons.close_rounded;
      case StepStatus.current:
        return Icons.flag_rounded;
      case StepStatus.pending:
        return Icons.schedule_rounded;
    }
  }

  static Color _colorForStatus(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return AppColors.stageWon;
      case StepStatus.pending:
        return AppColors.warning;
      case StepStatus.denied:
        return AppColors.error;
      case StepStatus.current:
        return AppColors.primary;
    }
  }

  Widget _buildCircle(StepData step) {
    final icon = _iconForStatus(step.status);
    final baseColor = step.isStepDisabled
        ? Colors.grey
        : (step.statusColor ?? _colorForStatus(step.status));
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: baseColor.withOpacity(0.15),
        border: Border.all(color: baseColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: step.showIcon
          ? Icon(icon, color: baseColor, size: 20)
          : null,
    );
  }

  Widget _buildLine(bool isActive) {
    final color = isActive
        ? AppColors.primary.withOpacity(0.4)
        : Colors.grey.shade300;
    if (isHorizontal) {
      return Container(
        width: 40,
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: color,
      );
    }
    return Container(
      width: 2,
      margin: const EdgeInsets.only(left: 19),
      color: color,
    );
  }

  Widget _buildStep(BuildContext context, StepData step, int index) {
    final isLast = index == steps.length - 1;
    final color = step.isStepDisabled
        ? Colors.grey
        : (step.titleColor ?? step.statusColor ?? _colorForStatus(step.status));

    final circleTap = GestureDetector(
      onTap: onStepTap != null && !step.isStepDisabled
          ? () => onStepTap!(index, step)
          : null,
      child: _buildCircle(step),
    );

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          circleTap,
          if (!isLast) _buildLine(step.status == StepStatus.completed),
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              circleTap,
              if (!isLast)
                Expanded(child: _buildLine(step.status == StepStatus.completed)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    step.title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  if (step.details != null && step.details!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface.withOpacity(0.5),
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: step.details!.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    e.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Text(' : ', style: GoogleFonts.poppins(fontSize: 12)),
                                Expanded(
                                  child: Text(
                                    e.description,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            steps.length,
            (i) => _buildStep(context, steps[i], i),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        steps.length,
        (i) => _buildStep(context, steps[i], i),
      ),
    );
  }
}
