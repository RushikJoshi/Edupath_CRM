import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/features/lead/data/models/lead_status_history_entry.dart';

/// Timeline of lead status changes: Status name, remark, date/time, user.
class LeadStatusTimeline extends StatelessWidget {
  const LeadStatusTimeline({
    super.key,
    required this.entries,
    this.currentStage,
  });

  final List<LeadStatusHistoryEntry> entries;
  final String? currentStage;

  static String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  static String _formatTime(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String _displayUserName(LeadStatusHistoryEntry entry) {
    final name = entry.createdByName.trim();
    return name.isEmpty ? 'Gitakshmi' : name;
  }

  String _buildStatusSentence({
    required LeadStatusHistoryEntry current,
    required LeadStatusHistoryEntry? previous,
  }) {
    final fromStatus = previous?.statusName.trim() ?? '';
    final toStatus = current.statusName.trim();
    if (fromStatus.isNotEmpty && toStatus.isNotEmpty) {
      return '"Status changed from "$fromStatus" to "$toStatus""';
    }
    if (toStatus.isNotEmpty) {
      return '"Status updated to "$toStatus""';
    }
    if (current.remark.trim().isNotEmpty) {
      return '"${current.remark.trim()}"';
    }
    return '"Status updated"';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status history',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        if (currentStage != null && currentStage!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Current stage: $currentStage',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              'No status changes yet. Change stage from the pipeline above and add a remark.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = entries[i];
              final isLast = i == entries.length - 1;
              final previous = i + 1 < entries.length ? entries[i + 1] : null;
              final sentence = _buildStatusSentence(
                current: e,
                previous: previous,
              );
              final userName = _displayUserName(e);
              final initials = userName
                  .trim()
                  .split(' ')
                  .where((p) => p.isNotEmpty)
                  .map((p) => p[0])
                  .take(1)
                  .join()
                  .toUpperCase();
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 28,
                            margin: const EdgeInsets.only(top: 4),
                            color: Colors.grey.shade300,
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  initials.isEmpty ? 'G' : initials,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$userName   SYSTEM',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${_formatDate(e.createdAt)}, ${_formatTime(e.createdAt)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sentence,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          if (e.remark.trim().isNotEmpty &&
                              e.remark.trim() !=
                                  sentence.replaceAll('"', '')) ...[
                            const SizedBox(height: 4),
                            Text(
                              e.remark.trim(),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
