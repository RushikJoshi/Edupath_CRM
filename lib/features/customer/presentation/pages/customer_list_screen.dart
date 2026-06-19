import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:gtcrm/features/customer/presentation/bloc/customer_event.dart';
import 'package:gtcrm/features/customer/presentation/bloc/customer_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/customer/data/models/customer_model.dart';
import 'package:gtcrm/routes/app_routes.dart';
import 'customer_detail_screen.dart';
import 'package:gtcrm/core/widgets/app_drawer.dart';

class AccountListScreen extends StatefulWidget {
  const AccountListScreen({super.key});

  @override
  State<AccountListScreen> createState() => _AccountListScreenState();
}

class _AccountListScreenState extends State<AccountListScreen> {
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  String _searchQuery = '';
  int _currentPage = 1;
  static const int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(
      CustomerFetched(
        page: _currentPage,
        limit: _pageSize,
        search: _searchQuery,
      ),
    );
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = _searchCtrl.text.trim();
        _currentPage = 1;
      });
      context.read<CustomerBloc>().add(
        CustomerFetched(
          page: 1,
          limit: _pageSize,
          search: _searchQuery.isEmpty ? null : _searchQuery,
        ),
      );
    });
  }

  Future<void> _refreshCustomers() async {
    context.read<CustomerBloc>().add(
      CustomerFetched(
        page: _currentPage,
        limit: _pageSize,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      ),
    );
    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      drawer: const AppDrawer(activeRoute: AppRoutes.accounts),

      // ── AppBar ───────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E8EFF),
        elevation: 0,
        toolbarHeight: 64,
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Accounts',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
            onPressed: _refreshCustomers,
          ),
        ],
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      body: ResponsiveConstraint(
        child: Column(
          children: [
            // Search & Count Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  final filtered = state.items
                      .where(
                        (c) =>
                            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            c.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            c.phone.contains(_searchQuery),
                      )
                      .toList();

                  return Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: Container(
                          height: 46,
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
                            controller: _searchCtrl,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              hintStyle: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: Colors.black,
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
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Accounts Badge
                      Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.people_alt_outlined,
                              color: Colors.black,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${filtered.length} Accounts',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // List/Empty/Error state
            Expanded(
              child: BlocBuilder<CustomerBloc, CustomerState>(
                builder: (context, state) {
                  if (state.status == AppStatus.loading) {
                    return ShimmerLoading.listPlaceholder(itemCount: 8);
                  }
                  if (state.status == AppStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            state.errorMessage ?? 'Failed to load accounts',
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _refreshCustomers,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text(
                              'Retry',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF2E8EFF),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final filtered = state.items
                      .where(
                        (c) =>
                            c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            c.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            c.phone.contains(_searchQuery),
                      )
                      .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E8EFF).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: const Icon(
                              Icons.people_alt_rounded,
                              size: 36,
                              color: Color(0xFF2E8EFF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Accounts Found',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Pull down to refresh'
                                : 'Try another search term',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refreshCustomers,
                    color: const Color(0xFF2E8EFF),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final customer = filtered[i];
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
                          child: _AccountCard(customer: customer),
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

      // ── FAB ──────────────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_account_fab',
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.addAccount),
        backgroundColor: const Color(0xFF2E8EFF),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.customer});

  final CustomerModel customer;

  @override
  Widget build(BuildContext context) {
    final initials = customer.name.isNotEmpty
        ? customer.name
              .trim()
              .split(' ')
              .map((p) => p[0])
              .take(2)
              .join()
              .toUpperCase()
        : 'CS';

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Color(0xFF2E8EFF), width: 4),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(
                context,
              ).pushNamed(AppRoutes.accountDetail, arguments: customer),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E8EFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Info Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.mail_outline_rounded,
                                size: 14,
                                color: Color(0xFF2E8EFF),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  customer.email,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${customer.city}, ${customer.state}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
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
                    const SizedBox(width: 8),

                    // Action Column
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AccountDetailScreen(
                                customer: customer,
                                initialEditMode: true,
                              ),
                            ),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            size: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ],
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
}
