import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/branch/presentation/bloc/branch_bloc.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_event.dart';
import 'package:gtcrm/features/branch/presentation/bloc/branch_state.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_bloc.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_event.dart';
import 'package:gtcrm/features/user/presentation/bloc/user_state.dart';
import 'package:gtcrm/core/constants/app_colors.dart';
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/widgets/shimmer_loading.dart';
import 'package:gtcrm/features/branch/data/models/branch_model.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  final _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    context.read<BranchBloc>().add(BranchFetched());
    context.read<UserBloc>().add(UserFetched());
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
  void _showAddBranchDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final postalCodeCtrl = TextEditingController();
    final customCityCtrl = TextEditingController();

    String branchType = 'sales_branch';
    String citySelection = 'Ahmedabad';
    String managerId = '';
    String status = 'active';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final showCustomCity = citySelection == 'Other';

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E8EFF),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.business_rounded, color: Colors.white, size: 22),
                        SizedBox(width: 10.w),
                        Text(
                          'Add Branch',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Icon(Icons.close_rounded, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDialogField(
                              controller: nameCtrl,
                              label: 'Branch Name *',
                              icon: Icons.business_outlined,
                              validator: (v) => (v == null || v.isEmpty) ? 'Branch name is required' : null,
                            ),
                            SizedBox(height: 14.h),

                            // Branch Type Dropdown
                            Text(
                              'Branch Type *',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            DropdownButtonFormField<String>(
                              value: branchType,
                              decoration: _inputDecorationForDialog(hint: 'Select Type', icon: Icons.badge_outlined),
                              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: 'sales_branch', child: Text('Sales Branch')),
                                DropdownMenuItem(value: 'main_branch', child: Text('Main Branch')),
                                DropdownMenuItem(value: 'admin_branch', child: Text('Admin Branch')),
                                DropdownMenuItem(value: 'support_branch', child: Text('Support Branch')),
                              ],
                              onChanged: (val) {
                                if (val != null) setStateDialog(() => branchType = val);
                              },
                            ),
                            SizedBox(height: 14.h),

                            _buildDialogField(
                              controller: emailCtrl,
                              label: 'Email *',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email is required';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            SizedBox(height: 14.h),

                            _buildDialogField(
                              controller: phoneCtrl,
                              label: 'Phone *',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Phone is required';
                                if (!RegExp(r'^[0-9]{10,12}$').hasMatch(v)) return 'Enter a 10-12 digit phone number';
                                return null;
                              },
                            ),
                            SizedBox(height: 14.h),

                            _buildDialogField(
                              controller: addressCtrl,
                              label: 'Address Line 1 *',
                              icon: Icons.location_on_outlined,
                              validator: (v) => (v == null || v.isEmpty) ? 'Address is required' : null,
                            ),
                            SizedBox(height: 14.h),

                            // City Dropdown
                            Text(
                              'City *',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            DropdownButtonFormField<String>(
                              value: citySelection,
                              decoration: _inputDecorationForDialog(hint: 'Select City', icon: Icons.location_city_outlined),
                              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: 'Ahmedabad', child: Text('Ahmedabad')),
                                DropdownMenuItem(value: 'Surat', child: Text('Surat')),
                                DropdownMenuItem(value: 'Vadodara', child: Text('Vadodara')),
                                DropdownMenuItem(value: 'Rajkot', child: Text('Rajkot')),
                                DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                                DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                                DropdownMenuItem(value: 'Delhi', child: Text('Delhi')),
                                DropdownMenuItem(value: 'Bangalore', child: Text('Bangalore')),
                                DropdownMenuItem(value: 'Other', child: Text('Other (Type custom city)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setStateDialog(() => citySelection = val);
                              },
                            ),
                            if (showCustomCity) ...[
                              SizedBox(height: 14.h),
                              _buildDialogField(
                                controller: customCityCtrl,
                                label: 'Custom City Name *',
                                icon: Icons.location_city_rounded,
                                validator: (v) => (v == null || v.isEmpty) ? 'City name is required' : null,
                              ),
                            ],
                            SizedBox(height: 14.h),

                            _buildDialogField(
                              controller: postalCodeCtrl,
                              label: 'Postal Code *',
                              icon: Icons.local_post_office_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Postal code is required';
                                if (!RegExp(r'^[0-9]{5,6}$').hasMatch(v)) return 'Enter valid postal code';
                                return null;
                              },
                            ),
                            SizedBox(height: 14.h),

                            // Manager selector dropdown
                            Text(
                              'Branch Manager',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            BlocBuilder<UserBloc, UserState>(
                              builder: (context, userState) {
                                final users = userState.items;
                                if (users.isNotEmpty && managerId.isEmpty) {
                                  managerId = users.first.id;
                                }
                                return DropdownButtonFormField<String>(
                                  value: managerId.isEmpty ? null : managerId,
                                  isExpanded: true,
                                  decoration: _inputDecorationForDialog(hint: 'Select Manager', icon: Icons.person_outline_rounded),
                                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                                  items: users.map((u) {
                                    return DropdownMenuItem(
                                      value: u.id,
                                      child: Text(
                                        '${u.name} (${u.role.replaceAll('_', ' ')})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setStateDialog(() => managerId = val);
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 14.h),

                            // Status dropdown
                            Text(
                              'Status *',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            DropdownButtonFormField<String>(
                              value: status,
                              decoration: _inputDecorationForDialog(hint: 'Select Status', icon: Icons.toggle_on_outlined),
                              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('Active')),
                                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                              ],
                              onChanged: (val) {
                                if (val != null) setStateDialog(() => status = val);
                              },
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Actions Footer
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: BlocBuilder<BranchBloc, BranchState>(
                      builder: (context, branchState) {
                        final isLoading = branchState.actionStatus == AppStatus.loading;
                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  foregroundColor: const Color(0xFF2E8EFF),
                                  side: const BorderSide(color: Color(0xFF2E8EFF)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                ),
                                child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E8EFF),
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (formKey.currentState?.validate() ?? false) {
                                          final city = citySelection == 'Other' ? customCityCtrl.text.trim() : citySelection;
                                          final generatedCityId = _getDeterministicCityId(city);

                                          final data = {
                                            'name': nameCtrl.text.trim(),
                                            'branchType': branchType,
                                            'email': emailCtrl.text.trim(),
                                            'phone': phoneCtrl.text.trim(),
                                            'addressLine1': addressCtrl.text.trim(),
                                            'cityId': generatedCityId,
                                            'postalCode': postalCodeCtrl.text.trim(),
                                            'status': status,
                                          };
                                          if (managerId.isNotEmpty) {
                                            data['branchManagerId'] = managerId;
                                          }

                                          context.read<BranchBloc>().add(BranchCreated(data));
                                          Navigator.pop(ctx);
                                        }
                                      },
                                  child: isLoading
                                      ? SizedBox(
                                          width: 18.w,
                                          height: 18.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Add',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

  // ── build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<BranchBloc, BranchState>(
      listenWhen: (prev, curr) => curr.actionStatus != prev.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == AppStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Branch added successfully!',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: AppColors.stageWon,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
        } else if (state.actionStatus == AppStatus.failure &&
            state.actionError != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.actionError!,
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),

        // ── AppBar ──────────────────────────────────────────────────────────
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
            'Branch Management',
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
              onPressed: () => context.read<BranchBloc>().add(BranchFetched()),
            ),
            SizedBox(width: 8.w),
          ],
        ),

        // ── Body ─────────────────────────────────────────────────────────────
        body: ResponsiveConstraint(
          child: Column(
            children: [
              // Search & Branches Count Row
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: BlocBuilder<BranchBloc, BranchState>(
                  builder: (context, state) {
                    final query = _searchController.text.toLowerCase().trim();
                    final filteredBranches = state.items.where((branch) {
                      return query.isEmpty ||
                          branch.name.toLowerCase().contains(query) ||
                          branch.location.toLowerCase().contains(query);
                    }).toList();

                    return Row(
                      children: [
                        // Search Bar
                        Expanded(
                          child: Container(
                            height: 46.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                  offset: Offset.zero,
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 13.sp,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.black,
                                  size: 22,
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                  horizontal: 12.w,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        // Branches Badge
                        Container(
                          height: 46.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F000000),
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
                                Icons.account_tree_rounded,
                                color: Colors.black,
                                size: 20,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '${filteredBranches.length} Branches',
                                style: GoogleFonts.poppins(
                                  fontSize: 13.sp,
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
                child: BlocBuilder<BranchBloc, BranchState>(
                  builder: (context, state) {
                    // Loading
                    if (state.status == AppStatus.loading && state.items.isEmpty) {
                      return ShimmerLoading.listPlaceholder();
                    }

                    // Error
                    if (state.status == AppStatus.failure && state.items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.cloud_off_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              state.errorMessage ?? 'Failed to load branches',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.read<BranchBloc>().add(BranchFetched()),
                              icon: Icon(Icons.refresh_rounded),
                              label: Text(
                                'Retry',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final query = _searchController.text.toLowerCase().trim();
                    final filteredBranches = state.items.where((branch) {
                      return query.isEmpty ||
                          branch.name.toLowerCase().contains(query) ||
                          branch.location.toLowerCase().contains(query);
                    }).toList();

                    // Empty
                    if (filteredBranches.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 80.w,
                              height: 80.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(24.r),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                ),
                              ),
                              child: const Icon(
                                Icons.account_tree_rounded,
                                size: 36,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No branches found',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16.sp,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              query.isNotEmpty
                                  ? 'Try refining your search query'
                                  : 'Tap + to add your first branch',
                              style: GoogleFonts.poppins(
                                fontSize: 13.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // List
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                      itemCount: filteredBranches.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) =>
                          _BranchCard(branch: filteredBranches[i], index: i),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // ── FAB ──────────────────────────────────────────────────────────────
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_branch_fab',
          onPressed: _showAddBranchDialog,
          backgroundColor: const Color(0xFF2E8EFF),
          shape: const CircleBorder(),
          child: Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

// ── Branch card widget ──────────────────────────────────────────────────────

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch, required this.index});

  final BranchModel branch;
  final int index;

  void _showEditDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: branch.name);
    final emailCtrl = TextEditingController(text: branch.email);
    final phoneCtrl = TextEditingController(text: branch.phone);
    final addressCtrl = TextEditingController(
        text: branch.addressLine1.isNotEmpty ? branch.addressLine1 : branch.location);
    final postalCodeCtrl = TextEditingController(text: branch.postalCode);
    final customCityCtrl = TextEditingController();

    String branchType = branch.branchType.isNotEmpty ? branch.branchType : 'sales_branch';

    const popularCities = ['Ahmedabad', 'Surat', 'Vadodara', 'Rajkot', 'Mumbai', 'Pune', 'Delhi', 'Bangalore'];
    String citySelection = 'Ahmedabad';
    if (branch.cityName.isNotEmpty && popularCities.contains(branch.cityName)) {
      citySelection = branch.cityName;
    } else if (branch.location.isNotEmpty) {
      final firstPart = branch.location.split(',').first.trim();
      if (popularCities.contains(firstPart)) {
        citySelection = firstPart;
      } else {
        citySelection = 'Other';
        customCityCtrl.text = firstPart;
      }
    } else {
      citySelection = 'Other';
      customCityCtrl.text = '';
    }

    String managerId = branch.branchManagerId;
    String status = branch.status.isNotEmpty ? branch.status : 'active';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          final showCustomCity = citySelection == 'Other';

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            backgroundColor: Colors.white,
            insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF2E8EFF),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                        SizedBox(width: 10.w),
                        Text(
                          'Edit Branch',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: Icon(Icons.close_rounded, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),

                  // Scrollable Body
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(16.w),
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDialogField(
                              controller: nameCtrl,
                              label: 'Branch Name *',
                              icon: Icons.business_outlined,
                              validator: (v) => (v == null || v.isEmpty) ? 'Branch name is required' : null,
                            ),
                            SizedBox(height: 14.h),

                            // Branch Type Dropdown
                            Text(
                              'Branch Type *',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            DropdownButtonFormField<String>(
                              value: branchType,
                              decoration: _inputDecorationForDialog(hint: 'Select Type', icon: Icons.badge_outlined),
                              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: 'sales_branch', child: Text('Sales Branch')),
                                DropdownMenuItem(value: 'main_branch', child: Text('Main Branch')),
                                DropdownMenuItem(value: 'admin_branch', child: Text('Admin Branch')),
                                DropdownMenuItem(value: 'support_branch', child: Text('Support Branch')),
                              ],
                              onChanged: (val) {
                                if (val != null) setStateDialog(() => branchType = val);
                              },
                            ),
                            SizedBox(height: 14.h),

                            _buildDialogField(
                              controller: emailCtrl,
                              label: 'Email *',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Email is required';
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Enter a valid email';
                                return null;
                              },
                            ),
                            SizedBox(height: 14.h),

                            _buildDialogField(
                              controller: phoneCtrl,
                              label: 'Phone *',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Phone is required';
                                if (!RegExp(r'^[0-9]{10,12}$').hasMatch(v)) return 'Enter a 10-12 digit phone number';
                                return null;
                              },
                            ),
                            SizedBox(height: 14.h),

                            _buildDialogField(
                              controller: addressCtrl,
                              label: 'Address Line 1 *',
                              icon: Icons.location_on_outlined,
                              validator: (v) => (v == null || v.isEmpty) ? 'Address is required' : null,
                            ),
                            SizedBox(height: 14.h),

                            // City Dropdown
                            Text(
                              'City *',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            DropdownButtonFormField<String>(
                              value: citySelection,
                              decoration: _inputDecorationForDialog(hint: 'Select City', icon: Icons.location_city_outlined),
                              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: 'Ahmedabad', child: Text('Ahmedabad')),
                                DropdownMenuItem(value: 'Surat', child: Text('Surat')),
                                DropdownMenuItem(value: 'Vadodara', child: Text('Vadodara')),
                                DropdownMenuItem(value: 'Rajkot', child: Text('Rajkot')),
                                DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                                DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                                DropdownMenuItem(value: 'Delhi', child: Text('Delhi')),
                                DropdownMenuItem(value: 'Bangalore', child: Text('Bangalore')),
                                DropdownMenuItem(value: 'Other', child: Text('Other (Type custom city)')),
                              ],
                              onChanged: (val) {
                                if (val != null) setStateDialog(() => citySelection = val);
                              },
                            ),
                            if (showCustomCity) ...[
                              SizedBox(height: 14.h),
                              _buildDialogField(
                                controller: customCityCtrl,
                                label: 'Custom City Name *',
                                icon: Icons.location_city_rounded,
                                validator: (v) => (v == null || v.isEmpty) ? 'City name is required' : null,
                              ),
                            ],
                            SizedBox(height: 14.h),

                            _buildDialogField(
                              controller: postalCodeCtrl,
                              label: 'Postal Code *',
                              icon: Icons.local_post_office_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Postal code is required';
                                if (!RegExp(r'^[0-9]{5,6}$').hasMatch(v)) return 'Enter valid postal code';
                                return null;
                              },
                            ),
                            SizedBox(height: 14.h),

                            // Manager selector dropdown
                            Text(
                              'Branch Manager',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            BlocBuilder<UserBloc, UserState>(
                              builder: (context, userState) {
                                final users = userState.items;
                                if (users.isNotEmpty && managerId.isEmpty) {
                                  managerId = users.first.id;
                                }
                                return DropdownButtonFormField<String>(
                                  value: managerId.isEmpty ? null : managerId,
                                  isExpanded: true,
                                  decoration: _inputDecorationForDialog(hint: 'Select Manager', icon: Icons.person_outline_rounded),
                                  style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                                  items: users.map((u) {
                                    return DropdownMenuItem(
                                      value: u.id,
                                      child: Text(
                                        '${u.name} (${u.role.replaceAll('_', ' ')})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) setStateDialog(() => managerId = val);
                                  },
                                );
                              },
                            ),
                            SizedBox(height: 14.h),

                            // Status dropdown
                            Text(
                              'Status *',
                              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
                            ),
                            SizedBox(height: 6.h),
                            DropdownButtonFormField<String>(
                              value: status,
                              decoration: _inputDecorationForDialog(hint: 'Select Status', icon: Icons.toggle_on_outlined),
                              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
                              items: const [
                                DropdownMenuItem(value: 'active', child: Text('Active')),
                                DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                              ],
                              onChanged: (val) {
                                if (val != null) setStateDialog(() => status = val);
                              },
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Actions Footer
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: BlocBuilder<BranchBloc, BranchState>(
                      builder: (context, branchState) {
                        final isLoading = branchState.actionStatus == AppStatus.loading;
                        return Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isLoading ? null : () => Navigator.pop(ctx),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 48),
                                  foregroundColor: const Color(0xFF2E8EFF),
                                  side: const BorderSide(color: Color(0xFF2E8EFF)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                ),
                                child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 2,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E8EFF),
                                  minimumSize: const Size(0, 48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (formKey.currentState?.validate() ?? false) {
                                          final city = citySelection == 'Other' ? customCityCtrl.text.trim() : citySelection;
                                          final generatedCityId = _getDeterministicCityId(city);

                                          final data = {
                                            'name': nameCtrl.text.trim(),
                                            'branchType': branchType,
                                            'email': emailCtrl.text.trim(),
                                            'phone': phoneCtrl.text.trim(),
                                            'addressLine1': addressCtrl.text.trim(),
                                            'cityId': generatedCityId,
                                            'postalCode': postalCodeCtrl.text.trim(),
                                            'status': status,
                                          };
                                          if (managerId.isNotEmpty) {
                                            data['branchManagerId'] = managerId;
                                          }

                                          context.read<BranchBloc>().add(BranchUpdated(branch.id, data));
                                          Navigator.pop(ctx);
                                        }
                                      },
                                child: isLoading
                                    ? SizedBox(
                                        width: 18.w,
                                        height: 18.h,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'Save',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
                      border: Border.all(color: Color(0xFFF44336), width: 1.w),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFF44336),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Delete Branch',
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
              Text(
                'Are you sure you want to delete this branch?',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24.h),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEA4335),
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () {
                  context.read<BranchBloc>().add(
                    BranchDeleted(branch.id),
                  );
                  Navigator.pop(ctx);
                },
                child: Text(
                  'Delete',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 15.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isActive = branch.isActive;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 150 + index * 50),
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - v)),
          child: child,
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(14.w),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Building Icon Container
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: Color(0xFF2E8EFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Color(0xFF2E8EFF).withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.business_rounded,
                size: 22,
                color: Color(0xFF2E8EFF),
              ),
            ),
            SizedBox(width: 12.w),

            // Content Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Action Icons
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          branch.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Action Buttons
                      GestureDetector(
                        onTap: () => _showEditDialog(context),
                        child: const Icon(
                          Icons.edit_rounded,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: () => _showDeleteDialog(context),
                        child: const Icon(
                          Icons.delete_rounded,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Location Info
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.black54,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          branch.location.isEmpty ? 'No address' : branch.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Bottom Row: Users count & Status badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Users count
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline_rounded,
                            size: 14,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${branch.userCount} users',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      // Status pill badge with dot
                      GestureDetector(
                        onTap: () {
                          context.read<BranchBloc>().add(
                                BranchStatusToggled(branch.id),
                              );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isActive
                                  ? const Color(0xFFC8E6C9)
                                  : const Color(0xFFFFCDD2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.h,
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                isActive ? 'Active' : 'Inactive',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.green.shade700
                                      : Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}

String _getDeterministicCityId(String cityName) {
  final clean = cityName.toLowerCase().trim();
  if (clean.isEmpty) return '000000000000000000000000';
  final bytes = utf8.encode(clean);
  final digest = md5.convert(bytes);
  return digest.toString().substring(0, 24);
}

Widget _buildDialogField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  String? Function(String?)? validator,
  TextInputType? keyboardType,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
      SizedBox(height: 6.h),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
        decoration: _inputDecorationForDialog(hint: 'Enter $label', icon: icon),
        validator: validator,
      ),
    ],
  );
}

InputDecoration _inputDecorationForDialog({
  required String hint,
  required IconData icon,
}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade400),
      prefixIcon: Icon(icon, size: 20, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 14.w),
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
        borderSide: const BorderSide(color: Color(0xFF2E8EFF)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.red),
      ),
    );