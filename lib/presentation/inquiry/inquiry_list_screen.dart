import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/inquiry/inquiry_bloc.dart';
import '../../bloc/inquiry/inquiry_event.dart';
import '../../bloc/inquiry/inquiry_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../widgets/app_drawer.dart';
import '../../routes/app_routes.dart';

class InquiryListScreen extends StatefulWidget {
  const InquiryListScreen({super.key});

  @override
  State<InquiryListScreen> createState() => _InquiryListScreenState();
}

class _InquiryListScreenState extends State<InquiryListScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedTab = 'All';
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    context.read<InquiryBloc>().add(const InquiryFetched());
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
      case 'fresh':
        return const Color(0xFF4CAF50); // Green
      case 'follow-up':
      case 'contacted':
      case 'interested':
        return const Color(0xFFFF9800); // Orange
      case 'urgent':
      case 'negotiation':
      case 'reviewed':
        return const Color(0xFFE53935); // Red
      case 'converted':
        return const Color(0xFF2E8EFF); // Blue
      default:
        return const Color(0xFFFF9800); // Orange
    }
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _buildTab(String label) {
    final isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        height: 28,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E8EFF).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? const Color(0xFF2E8EFF) : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(activeRoute: AppRoutes.inquiryList),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8EFF),
        elevation: 0,
        toolbarHeight: 64,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Text(
          'Enquiries',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: ResponsiveConstraint(
        child: Column(
          children: <Widget>[
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF000000),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search enquiries...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF000000).withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF2E8EFF),
                      size: 22,
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Tab Switcher
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                  boxShadow: const [
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
                    Expanded(child: _buildTab('All')),
                    Expanded(child: _buildTab('New')),
                    Expanded(child: _buildTab('Closed')),
                  ],
                ),
              ),
            ),

            // ── List ──
            Expanded(
              child: BlocConsumer<InquiryBloc, InquiryState>(
                buildWhen: (p, c) => c.status != p.status || c.items != p.items,
                listenWhen: (p, c) => c.actionStatus != p.actionStatus,
                listener: (context, state) {
                  if (state.actionStatus == AppStatus.success) {
                    context.read<InquiryBloc>().add(const InquiryFetched());
                  }
                },
                builder: (context, state) {
                  if (state.status == AppStatus.loading) {
                    return ShimmerLoading.listPlaceholder();
                  }
                  if (state.status == AppStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage ?? 'Failed to load enquiries',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () => context.read<InquiryBloc>().add(
                              const InquiryFetched(),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(
                              'Retry',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final items = state.items;
                  final query = _searchCtrl.text.toLowerCase().trim();
                  final filtered = items.where((inq) {
                    final matchesSearch = query.isEmpty ||
                        inq.name.toLowerCase().contains(query) ||
                        inq.phone.contains(query) ||
                        inq.email.toLowerCase().contains(query);

                    if (!matchesSearch) return false;
                    if (_selectedTab == 'All') return true;
                    if (_selectedTab == 'New') {
                      return inq.status.toLowerCase() == 'new' ||
                          inq.status.toLowerCase() == 'fresh';
                    }
                    if (_selectedTab == 'Closed') {
                      return inq.status.toLowerCase() == 'closed' ||
                          inq.status.toLowerCase() == 'converted' ||
                          inq.status.toLowerCase() == 'lost' ||
                          inq.status.toLowerCase() == 'ignored';
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) return _empty();

                  return RefreshIndicator(
                    color: const Color(0xFF2E8EFF),
                    onRefresh: () async =>
                        context.read<InquiryBloc>().add(const InquiryFetched()),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final inq = filtered[i];
                        final sc = _statusColor(inq.status);
                        final initials = inq.name.isNotEmpty
                            ? inq.name
                                  .trim()
                                  .split(' ')
                                  .map((p) => p[0])
                                  .take(2)
                                  .join()
                                  .toUpperCase()
                            : '?';
                        final isSelected = _selectedCardId == inq.id || (_selectedCardId == null && i == 0);

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(milliseconds: 150 + i * 40),
                          builder: (_, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 12 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: InkWell(
                            onTap: () async {
                              setState(() {
                                _selectedCardId = inq.id;
                              });
                              await Navigator.pushNamed(
                                context,
                                AppRoutes.inquiryDetail,
                                arguments: inq,
                              );
                              if (context.mounted) {
                                context.read<InquiryBloc>().add(
                                  const InquiryFetched(),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF2E8EFF) : Colors.transparent,
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40000000),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  // Left side info
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                      child: Row(
                                        children: [
                                          // Avatar
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor: const Color(0xFF2E8EFF).withOpacity(0.1),
                                            child: Text(
                                              initials,
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFF2E8EFF),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          // Content
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        inq.name,
                                                        style: GoogleFonts.poppins(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                          color: Colors.black,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    _pill(_cap(inq.status), sc),
                                                  ],
                                                ),
                                                const SizedBox(height: 6),
                                                // Email
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.email_outlined,
                                                      size: 14,
                                                      color: Color(0xFF2E8EFF),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        inq.email.isNotEmpty
                                                            ? inq.email
                                                            : 'No email address',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 12,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                // Phone
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.phone_outlined,
                                                      size: 14,
                                                      color: Color(0xFF2E8EFF),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      inq.phone.isNotEmpty
                                                          ? inq.phone
                                                          : 'No phone number',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Option capsule button (flush on the right, vertically centered)
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _selectedCardId = inq.id;
                                      });
                                      await Navigator.pushNamed(
                                        context,
                                        AppRoutes.inquiryDetail,
                                        arguments: inq,
                                      );
                                      if (context.mounted) {
                                        context.read<InquiryBloc>().add(
                                          const InquiryFetched(),
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 26,
                                      height: 46,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF2E8EFF),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _Dot(),
                                              SizedBox(width: 3),
                                              _Dot(),
                                            ],
                                          ),
                                          SizedBox(height: 3),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _Dot(),
                                              SizedBox(width: 3),
                                              _Dot(),
                                            ],
                                          ),
                                          SizedBox(height: 3),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              _Dot(),
                                              SizedBox(width: 3),
                                              _Dot(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.addInquiry);
          if (context.mounted) {
            context.read<InquiryBloc>().add(const InquiryFetched());
          }
        },
        backgroundColor: const Color(0xFF2E8EFF),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _empty() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFF2E8EFF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2E8EFF).withOpacity(0.2)),
          ),
          child: const Center(
            child: Icon(
              Icons.contact_mail_outlined,
              size: 36,
              color: Color(0xFF2E8EFF),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No enquiries found',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap + to add a new enquiry',
          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
        ),
      ],
    ),
  );
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}
