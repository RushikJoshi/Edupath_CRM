import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_bloc.dart';
import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_event.dart';
import 'package:gtcrm/features/inquiry/presentation/bloc/inquiry_state.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_bloc.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_event.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';

import 'package:gtcrm/features/inquiry/data/models/inquiry_model.dart';

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
          backgroundColor: const Color(0xFFF9FAFB),
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
                      fontSize: 17.sp,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'Enquiry Details',
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
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
                      SizedBox(height: 14.h),

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
                            inq.city?.isNotEmpty == true
                                ? inq.city!.toUpperCase()
                                : 'AHMADABAD',
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
                            _row(
                              Icons.language_rounded,
                              'Website',
                              inq.website!,
                            ),
                        ],
                      ),
                      SizedBox(height: 14.h),

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
                          _row(
                            Icons.place_rounded,
                            'Location',
                            inq.location ?? 'AHMADABAD',
                          ),
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
                      SizedBox(height: 14.h),

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
                      SizedBox(height: 14.h),

                      // ── Message ──
                      if (inq.message?.isNotEmpty == true) ...[
                        _textCard(
                          'Message',
                          Icons.message_rounded,
                          inq.message!,
                        ),
                        SizedBox(height: 14.h),
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
                            padding: EdgeInsets.all(16.0.w),
                            child: Text(
                              inq.notes?.isNotEmpty == true
                                  ? inq.notes!
                                  : 'No notes added',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: const Color(0xFF000000),
                                height: 1.6.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // ── Actions ──
                      if (loading)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
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
                            height: 50.h,
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
                                  borderRadius: BorderRadius.circular(12.r),
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
      userBloc.add(UserFetched());
    }

    const allBranchesValue = '__all_branches__';
    String selectedBranchId = allBranchesValue;
    String searchQuery = '';
    String? tappedUserId;

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
                  final roleLower = u.role.toLowerCase();
                  final isSalesOrMgr = roleLower == 'sales' ||
                      roleLower == 'branch_manager' ||
                      roleLower == 'branch manager';
                  if (!isSalesOrMgr) return false;

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

                // Get currently assigned user for this inquiry
                final inqState = context.read<InquiryBloc>().state;
                final currentlyAssigned =
                    inqState.items
                        .where((inq) => inq.id == id)
                        .map((e) => e.assignedTo)
                        .isNotEmpty
                    ? inqState.items
                          .firstWhere((inq) => inq.id == id)
                          .assignedTo
                    : null;

                // Color generators for avatars
                Color getAvatarBg(String name) {
                  final colors = [
                    const Color(0xFFE3F2FD),
                    const Color(0xFFF3E5F5),
                    const Color(0xFFE8F5E9),
                    const Color(0xFFFFF3E0),
                    const Color(0xFFFFEBEE),
                  ];
                  if (name.isEmpty) return colors[0];
                  return colors[name.codeUnitAt(0) % colors.length];
                }

                Color getAvatarText(String name) {
                  final colors = [
                    const Color(0xFF1976D2),
                    const Color(0xFF7B1FA2),
                    const Color(0xFF388E3C),
                    const Color(0xFFF57C00),
                    const Color(0xFFD32F2F),
                  ];
                  if (name.isEmpty) return colors[0];
                  return colors[name.codeUnitAt(0) % colors.length];
                }

                return AnimatedPadding(
                  duration: const Duration(milliseconds: 120),
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(ctx).viewInsets.bottom,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.r),
                        topRight: Radius.circular(24.r),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 24.h),
                        // HEADER ROW
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(ctx, ''), // Unassign
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  width: 44.w,
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDF2F2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Color(0xFFFF4B4B),
                                    size: 20,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    'Assign to Sales User',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Container(
                                    width: 32.w,
                                    height: 2.5.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E8EFF),
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                onTap: () => Navigator.pop(ctx),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  width: 44.w,
                                  height: 44.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F4FC),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.black,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // SEARCH ROW
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: TextField(
                                    onChanged: (value) => setSheetState(
                                      () => searchQuery = value,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      color: Colors.black,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Search user...',
                                      hintStyle: GoogleFonts.poppins(
                                        fontSize: 13.sp,
                                        color: Colors.grey.shade500,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.search_rounded,
                                        size: 20,
                                        color: Colors.grey.shade500,
                                      ),
                                      isDense: true,
                                      filled: false,
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 14.h,
                                      ),
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
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
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                child: Container(
                                  width: 48.w,
                                  height: 48.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7FA),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: const Icon(
                                    Icons.filter_alt_outlined,
                                    color: Color(0xFF2E8EFF),
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedBranchId != allBranchesValue)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8EEFE),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  'Branch: ${branchMap[selectedBranchId] ?? 'Selected'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2E8EFF),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(height: 20.h),

                        // USER LIST
                        if (state.status == AppStatus.loading)
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF2E8EFF),
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else if (filteredUsers.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Text(
                              users.isEmpty
                                  ? 'No users found.\nPlease create a Sales user first.'
                                  : 'No users match this search/filter.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          )
                        else
                          Flexible(
                            child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: filteredUsers.length,
                              itemBuilder: (_, i) {
                                final u = filteredUsers[i];
                                final isSelected = (tappedUserId != null)
                                    ? u.id == tappedUserId
                                    : u.id == currentlyAssigned;

                                return Container(
                                  margin: const EdgeInsets.only(
                                    bottom: 12,
                                    left: 16,
                                    right: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFFF2F6FE)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF83A9FF)
                                          : const Color(0xFFF0F0F0),
                                      width: 1.5.w,
                                    ),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12.r),
                                      onTap: () {
                                        setSheetState(
                                          () => tappedUserId = u.id,
                                        );
                                        Future.delayed(
                                          const Duration(milliseconds: 300),
                                          () {
                                            if (ctx.mounted)
                                              Navigator.pop(ctx, u.id);
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 14.h,
                                        ),
                                        child: Row(
                                          children: [
                                            Stack(
                                              children: [
                                                Container(
                                                  width: 44.w,
                                                  height: 44.h,
                                                  decoration: BoxDecoration(
                                                    color: getAvatarBg(u.name),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      u.name.isNotEmpty
                                                          ? u.name[0]
                                                                .toUpperCase()
                                                          : '?',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16.sp,
                                                            color:
                                                                getAvatarText(
                                                                  u.name,
                                                                ),
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  right: 0,
                                                  bottom: 0,
                                                  child: Container(
                                                    width: 12.w,
                                                    height: 12.h,
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFF4CAF50,
                                                      ),
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2.w,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    u.name,
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${u.email}${u.branchName.trim().isNotEmpty ? '   |   ${u.branchName}' : ''}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 11.sp,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 12.w),
                                            Container(
                                              width: 20.w,
                                              height: 20.h,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isSelected
                                                    ? const Color(0xFF3D78FF)
                                                    : Colors.transparent,
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFF3D78FF)
                                                      : const Color(0xFFD3E0FB),
                                                  width: isSelected ? 0 : 1.5,
                                                ),
                                              ),
                                              child: isSelected
                                                  ? const Icon(
                                                      Icons.check_rounded,
                                                      size: 14,
                                                      color: Colors.white,
                                                    )
                                                  : null,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        SizedBox(height: 16.h),
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
      style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.white),
    ),
    backgroundColor: color,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    margin: EdgeInsets.all(16.w),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Color(0xFF2E8EFF), width: 1.5.w),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56.w,
            height: 56.h,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28.r),
              child: Container(
                color: Color(0xFF2E8EFF).withOpacity(0.1),
                child: Center(
                  child: Text(
                    initials,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF2E8EFF),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inq.name,
                  style: GoogleFonts.poppins(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF000000),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  inq.email.isNotEmpty ? inq.email : 'No email address',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(12.r)),
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
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
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
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(16.r)),
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

  Widget _row(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
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
          top: BorderSide(color: Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: const Color(0xFF000000),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
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
                  width: 30.w,
                  height: 30.h,
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onWhatsApp,
                icon: Image.asset(
                  'assets/svgs/whatsapp.png',
                  width: 30.w,
                  height: 30.h,
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
          top: BorderSide(color: Color(0xFF2E8EFF).withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2E8EFF)),
          SizedBox(width: 10.w),
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
                          fontSize: 10.sp,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        value1,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF000000),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 24.h,
                  width: 1.w,
                  color: Colors.grey.shade300,
                  margin: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label2,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: const Color(0xFF000000),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        value2,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(16.r)),
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
              SizedBox(width: 8.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF000000),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: const Color(0xFF000000),
              height: 1.6.h,
            ),
          ),
        ],
      ),
    );
  }
}
