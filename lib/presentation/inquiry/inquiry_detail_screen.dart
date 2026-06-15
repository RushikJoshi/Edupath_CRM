import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/inquiry/inquiry_bloc.dart';
import '../../bloc/inquiry/inquiry_event.dart';
import '../../bloc/inquiry/inquiry_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/widgets/shimmer_loading.dart';

import '../../data/models/inquiry_model.dart';

class InquiryDetailScreen extends StatefulWidget {
  const InquiryDetailScreen({super.key, this.inquiry});

  final InquiryModel? inquiry;

  @override
  State<InquiryDetailScreen> createState() => _InquiryDetailScreenState();
}

class _InquiryDetailScreenState extends State<InquiryDetailScreen> {
  bool _isContactExpanded = true;
  bool _isDetailsExpanded = false;
  bool _isAssignmentExpanded = false;
  bool _isMessageExpanded = false;
  bool _isNotesExpanded = false;

  // ── helpers ────────────────────────────────────────────────────────────────

  static Color statusColor(String s) {
    final lower = s.toLowerCase();
    switch (lower) {
      case 'new':
      case 'fresh':
        return AppColors.stageNew;
      case 'contacted':
        return AppColors.stageContacted;
      case 'interested':
        return AppColors.stageInterested;
      case 'negotiation':
      case 'reviewed':
        return AppColors.stageNegotiation;
      case 'converted':
        return AppColors.stageWon;
      case 'lost':
      case 'ignored':
        return AppColors.stageLost;
      default:
        return AppColors.stageFollowUp;
    }
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> _call(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Optional: you can show a SnackBar here if needed
    }
  }

  Future<void> _whatsApp(String phone, String name) async {
    final normalized = phone.replaceAll(' ', '');
    // Use universal wa.me link so browser can hand off to WhatsApp
    final uri = Uri.parse('https://wa.me/$normalized?text=Hi%20$name');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // Optional: show a message if WhatsApp is not installed / cannot open
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.inquiry == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: AppColors.primary),
        body: Center(
          child: Text(
            'No enquiry selected',
            style: GoogleFonts.poppins(color: Colors.grey.shade500),
          ),
        ),
      );
    }

    return BlocConsumer<InquiryBloc, InquiryState>(
      listenWhen: (p, c) =>
          c.actionStatus != p.actionStatus &&
          (c.actionStatus == AppStatus.success ||
              c.actionStatus == AppStatus.failure),
      listener: (context, state) {
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isCurrentRoute) {
          return;
        }

        if (state.actionStatus == AppStatus.success) {
          final msg = state.actionMessage ?? 'Done';
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(_snack(msg, AppColors.stageWon));
          if (msg.toLowerCase().contains('delet') ||
              msg.toLowerCase().contains('convert')) {
            Navigator.pop(context);
          }
        } else if (state.actionStatus == AppStatus.failure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            _snack(
              state.actionMessage ?? 'Something went wrong',
              AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // Always use the latest version from BlocState if available
        final inq =
            state.items.where((i) => i.id == widget.inquiry!.id).firstOrNull ??
            widget.inquiry!;
        final sc = statusColor(inq.status);
        final loading = state.actionStatus == AppStatus.loading;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: const Color(0xFF2E8EFF),
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
                ShimmerLoading(
                  isLoading: state.status == AppStatus.loading,
                  baseColor: Colors.white.withOpacity(0.4),
                  highlightColor: Colors.white.withOpacity(0.7),
                  child: Text(
                    inq.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Enquiry Details',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                onPressed: () {},
              ),
            ],
          ),

          body: ResponsiveConstraint(
            child: state.status == AppStatus.loading
                ? ShimmerLoading.detailPlaceholder()
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      responsiveHorizontalPadding(context),
                      10,
                      responsiveHorizontalPadding(context),
                      10,
                    ),
                    children: <Widget>[
                      // ── Header card ──
                      _headerCard(inq, sc),
                      const SizedBox(height: 14),

                      // ── Contact Info ──
                      _buildCollapsibleSection(
                        title: 'Contact Info',
                        icon: Icons.person_rounded,
                        isExpanded: _isContactExpanded,
                        onToggle: () {
                          setState(() {
                            _isContactExpanded = !_isContactExpanded;
                          });
                        },
                        children: [
                          _row(
                            Icons.assignment_ind_rounded,
                            'Full Name',
                            inq.name,
                          ),
                          _rowWithActions(
                            Icons.phone_rounded,
                            'Phone',
                            inq.phone,
                            onCall: () => _call(inq.phone),
                            onWhatsApp: () => _whatsApp(inq.phone, inq.name),
                          ),
                          _row(Icons.email_rounded, 'Email', inq.email),
                          _rowSideBySide(
                            Icons.location_city_rounded,
                            'City',
                            inq.city?.isNotEmpty == true ? inq.city!.toUpperCase() : 'AHMADABAD',
                            'State',
                            'GUJRAT',
                          ),
                          if (inq.companyName?.isNotEmpty == true)
                            _row(
                              Icons.business_rounded,
                              'Company',
                              inq.companyName!,
                            ),
                          if (inq.address?.isNotEmpty == true)
                            _row(
                              Icons.location_on_rounded,
                              'Address',
                              inq.address!,
                            ),
                          if (inq.website?.isNotEmpty == true)
                            _row(Icons.language_rounded, 'Website', inq.website!),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Enquiry Details ──
                      _buildCollapsibleSection(
                        title: 'Enquiry Details',
                        icon: Icons.info_outline_rounded,
                        isExpanded: _isDetailsExpanded,
                        onToggle: () {
                          setState(() {
                            _isDetailsExpanded = !_isDetailsExpanded;
                          });
                        },
                        children: [
                          _row(Icons.flag_rounded, 'Status', _cap(inq.status)),
                          _row(Icons.place_rounded, 'Location', inq.location ?? 'AHMADABAD'),
                          _row(Icons.alt_route_rounded, 'Source', inq.source),
                          _row(
                            Icons.currency_rupee_rounded,
                            'Value',
                            inq.value != null ? '₹ ${inq.value}' : '₹ 0',
                          ),
                          if (inq.sourceId?.isNotEmpty == true)
                            _row(Icons.tag_rounded, 'Source ID', inq.sourceId!),
                          if (inq.course?.isNotEmpty == true)
                            _row(Icons.school_rounded, 'Course', inq.course!),
                          if (inq.branchName.isNotEmpty)
                            _row(
                              Icons.account_tree_rounded,
                              'Branch',
                              inq.branchName,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Assignment & More ──
                      _buildCollapsibleSection(
                        title: 'Assignment & More',
                        icon: Icons.assignment_ind_rounded,
                        isExpanded: _isAssignmentExpanded,
                        onToggle: () {
                          setState(() {
                            _isAssignmentExpanded = !_isAssignmentExpanded;
                          });
                        },
                        children: [
                          _row(Icons.person_pin_rounded, 'Assigned To', () {
                            if (inq.assignedTo?.isNotEmpty != true) {
                              return 'Not assigned';
                            }
                            final users = context.read<UserBloc>().state.items;
                            final match = users
                                .where((u) => u.id == inq.assignedTo)
                                .firstOrNull;
                            return match?.name ?? inq.assignedTo!;
                          }()),
                          if (inq.followUpDate != null)
                            _row(
                              Icons.event_rounded,
                              'Follow-up',
                              inq.followUpDate!
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                            ),
                          if (inq.createdAt != null)
                            _row(
                              Icons.access_time_rounded,
                              'Created',
                              inq.createdAt!
                                  .toLocal()
                                  .toString()
                                  .split(' ')
                                  .first,
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Message ──
                      if (inq.message?.isNotEmpty == true) ...[
                        _textCard(
                          'Message',
                          Icons.message_rounded,
                          inq.message!,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ── Notes ──
                      _buildCollapsibleSection(
                        title: 'Notes',
                        icon: Icons.notes_rounded,
                        isExpanded: _isNotesExpanded,
                        onToggle: () {
                          setState(() {
                            _isNotesExpanded = !_isNotesExpanded;
                          });
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              inq.notes?.isNotEmpty == true
                                  ? inq.notes!
                                  : 'No notes added',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF000000),
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Actions ──
                      if (loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      else ...[
                        // Convert to Lead (hidden when already converted)
                        if (inq.status.toLowerCase() != 'converted')
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton.icon(
                              onPressed: () => _confirmConvert(context, inq.id),
                              icon: const Icon(
                                Icons.trending_up_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: Text(
                                'Convert to Lead',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2E8EFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }

  // ── Confirm dialogs ────────────────────────────────────────────────────────

  void _confirmConvert(BuildContext context, String id) async {
    // Ensure users are loaded
    final userBloc = context.read<UserBloc>();
    final userState = userBloc.state;
    if (userState.items.isEmpty && userState.status != AppStatus.loading) {
      userBloc.add(UserFetched(role: 'sales'));
    }

    const allBranchesValue = '__all_branches__';
    String selectedBranchId = allBranchesValue;
    String searchQuery = '';

    final assigned = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (ctx, state) {
                final users = state.items;

                final branchMap = <String, String>{
                  allBranchesValue: 'All Branches',
                };
                for (final u in users) {
                  final id = u.branchId.trim().isEmpty
                      ? '__unassigned_branch__'
                      : u.branchId.trim();
                  final name = u.branchName.trim().isNotEmpty
                      ? u.branchName.trim()
                      : (u.branchId.trim().isNotEmpty
                            ? u.branchId.trim()
                            : 'Unassigned');
                  branchMap.putIfAbsent(id, () => name);
                }

                final filteredUsers = users.where((u) {
                  final q = searchQuery.trim().toLowerCase();
                  final queryOk =
                      q.isEmpty ||
                      u.name.toLowerCase().contains(q) ||
                      u.email.toLowerCase().contains(q);

                  final userBranchId = u.branchId.trim().isEmpty
                      ? '__unassigned_branch__'
                      : u.branchId.trim();
                  final branchOk =
                      selectedBranchId == allBranchesValue ||
                      userBranchId == selectedBranchId;

                  return queryOk && branchOk;
                }).toList();

                return AnimatedPadding(
                  duration: const Duration(milliseconds: 120),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                          child: Text(
                            'Assign to Sales User',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) =>
                                      setSheetState(() => searchQuery = value),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search user...',
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppColors.primary.withOpacity(
                                          0.25,
                                        ),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: AppColors.primary.withOpacity(
                                          0.25,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              PopupMenuButton<String>(
                                tooltip: 'Filter by branch',
                                onSelected: (value) => setSheetState(
                                  () => selectedBranchId = value,
                                ),
                                itemBuilder: (_) => branchMap.entries
                                    .map(
                                      (e) => PopupMenuItem<String>(
                                        value: e.key,
                                        child: Text(
                                          e.value,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.filter_alt_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedBranchId != allBranchesValue)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  'Branch: ${branchMap[selectedBranchId] ?? 'Selected'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        const Divider(height: 1),
                        if (state.status == AppStatus.loading)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else if (filteredUsers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              users.isEmpty
                                  ? 'No users found.\nPlease create a Sales user first.'
                                  : 'No users match this search/filter.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: filteredUsers.length,
                              itemBuilder: (_, i) {
                                final u = filteredUsers[i];
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: AppColors.primary
                                        .withOpacity(0.1),
                                    child: Text(
                                      u.name.isNotEmpty
                                          ? u.name[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    u.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${u.email}${u.branchName.trim().isNotEmpty ? ' • ${u.branchName}' : ''}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  onTap: () => Navigator.pop(ctx, u.id),
                                );
                              },
                            ),
                          ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );

    if (assigned != null && context.mounted) {
      context.read<InquiryBloc>().add(
        InquiryConverted(inquiryId: id, assignedTo: assigned),
      );
    }
  }

  // ── Reusable widgets ───────────────────────────────────────────────────────

  SnackBar _snack(String msg, Color color) => SnackBar(
    content: Text(
      msg,
      style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
    ),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(16),
  );

  Widget _headerCard(InquiryModel inq, Color sc) {
    final initials = inq.name.isNotEmpty
        ? inq.name
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : '?';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E8EFF), width: 1.5),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                color: const Color(0xFF2E8EFF).withOpacity(0.1),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E8EFF),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inq.name,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  inq.email.isNotEmpty ? inq.email : 'No email address',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    final activeChildren = children.where((w) => w is! SizedBox).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF2E8EFF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF2E8EFF),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && activeChildren.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: activeChildren,
          ),
      ],
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    final activeChildren = children.where((w) => w is! SizedBox).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF2E8EFF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF000000),
                    ),
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF2E8EFF),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && activeChildren.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: Offset.zero,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: activeChildren,
            ),
          ),
        ],
      ],
    );
  }

  Widget _section(String title, IconData icon, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E8EFF).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 14, color: const Color(0xFF2E8EFF)),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          ...rows,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowWithActions(
    IconData icon,
    String label,
    String value, {
    required VoidCallback onCall,
    required VoidCallback onWhatsApp,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onCall,
                icon: Image.asset(
                  'assets/svgs/mobile.png',
                  width: 30,
                  height: 30,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onWhatsApp,
                icon: Image.asset(
                  'assets/svgs/whatsapp.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rowSideBySide(
    IconData icon,
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: const Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label1,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value1,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label2,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value2,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _textCard(String title, IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset.zero,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF000000),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
