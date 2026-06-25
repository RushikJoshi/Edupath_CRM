import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gtcrm/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:gtcrm/features/auth/presentation/bloc/auth_state.dart';
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
import 'package:gtcrm/core/utils/role_guard.dart';
import 'package:gtcrm/features/branch/data/models/branch_model.dart';
import 'package:gtcrm/features/user/data/models/user_model.dart';
import 'package:gtcrm/features/user/domain/repositories/user_repository.dart';
import 'package:gtcrm/core/network/dio_client.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(UserFetched());
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final dio = context.read<DioClient>().client;

        final listNoParams = await dio.get('/api/users');
        debugPrint(
          'DIAGNOSTIC 1 (No params) count: ${listNoParams.data is Map ? listNoParams.data["total"] ?? (listNoParams.data["data"] is List ? listNoParams.data["data"].length : null) : "not a map"}',
        );

        final listStatusAll = await dio.get(
          '/api/users',
          queryParameters: {'status': 'all'},
        );
        debugPrint(
          'DIAGNOSTIC 2 (status=all) count: ${listStatusAll.data is Map ? listStatusAll.data["total"] ?? (listStatusAll.data["data"] is List ? listStatusAll.data["data"].length : null) : "not a map"}',
        );

        final listStatusInactive = await dio.get(
          '/api/users',
          queryParameters: {'status': 'inactive'},
        );
        debugPrint(
          'DIAGNOSTIC 3 (status=inactive) count: ${listStatusInactive.data is Map ? listStatusInactive.data["total"] ?? (listStatusInactive.data["data"] is List ? listStatusInactive.data["data"].length : null) : "not a map"}',
        );

        final listIsActiveFalse = await dio.get(
          '/api/users',
          queryParameters: {'isActive': false},
        );
        debugPrint(
          'DIAGNOSTIC 4 (isActive=false) count: ${listIsActiveFalse.data is Map ? listIsActiveFalse.data["total"] ?? (listIsActiveFalse.data["data"] is List ? listIsActiveFalse.data["data"].length : null) : "not a map"}',
        );

        final listStatusEmpty = await dio.get(
          '/api/users',
          queryParameters: {'status': ''},
        );
        debugPrint(
          'DIAGNOSTIC 5 (status="") count: ${listStatusEmpty.data is Map ? listStatusEmpty.data["total"] ?? (listStatusEmpty.data["data"] is List ? listStatusEmpty.data["data"].length : null) : "not a map"}',
        );

        // Let's also check sample user data schema from Diagnostic 1 to see status/isActive properties
        if (listNoParams.data is Map) {
          final usersList =
              listNoParams.data["data"] ?? listNoParams.data["users"];
          if (usersList is List && usersList.isNotEmpty) {
            debugPrint(
              'DIAGNOSTIC SAMPLE USER KEYS: ${usersList.first.keys.toList()}',
            );
            debugPrint(
              'DIAGNOSTIC SAMPLE USER STATUS: ${usersList.first["status"]} | ISACTIVE: ${usersList.first["isActive"]}',
            );
          }
        }
      } catch (e) {
        debugPrint('DIAGNOSTIC ERROR: $e');
      }
    });

    // Only Company Admins need to fetch the full branch list from the API.
    // Branch Managers already have their branchId from the auth session —
    // we construct their branch locally without any API call.
    final auth = context.read<AuthBloc>().state;
    final currentRole = auth.user?.role ?? '';
    if (RoleGuard.isCompanyAdmin(currentRole)) {
      final branchState = context.read<BranchBloc>().state;
      if (branchState.items.isEmpty &&
          branchState.status != AppStatus.loading) {
        context.read<BranchBloc>().add(BranchFetched());
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── role / badge helpers ───────────────────────────────────────────────────

  String _getRoleLabel(String role) {
    if (RoleGuard.isCompanyAdmin(role)) return 'Company Admin';
    if (RoleGuard.isBranchManager(role)) return 'Branch Manager';
    if (RoleGuard.isSales(role)) return 'Sales';
    return role.toUpperCase();
  }

  List<BranchModel> _availableBranches(
    AuthState auth,
    BranchState branchState,
  ) {
    final currentRole = auth.user?.role ?? '';
    final currentBranchId = auth.user?.branchId ?? '';

    if (RoleGuard.isCompanyAdmin(currentRole)) {
      return branchState.items;
    }

    if (currentBranchId.isEmpty) return [];

    final fromList = branchState.items
        .where((b) => b.id == currentBranchId)
        .toList();

    if (fromList.isNotEmpty) return fromList;

    final storedName = auth.user?.branchName ?? '';
    return [
      BranchModel(
        id: currentBranchId,
        name: storedName.isNotEmpty ? storedName : currentBranchId,
      ),
    ];
  }

  // ── Edit User dialog ───────────────────────────────────────────────────────

  void _showEditDialog(UserModel user) {
    final formKey = GlobalKey<FormState>();

    // Parse name fallbacks if firstName/lastName are empty
    final parts = user.name.split(' ');
    final fallbackFirst = parts.isNotEmpty ? parts.first : '';
    final fallbackLast = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final initialFirst = user.firstName.isNotEmpty
        ? user.firstName
        : fallbackFirst;
    final initialLast = user.lastName.isNotEmpty ? user.lastName : fallbackLast;

    final firstNameCtrl = TextEditingController(text: initialFirst);
    final lastNameCtrl = TextEditingController(text: initialLast);
    final phoneCtrl = TextEditingController(text: user.phone);
    final departmentCtrl = TextEditingController(text: user.department);
    final jobTitleCtrl = TextEditingController(text: user.jobTitle);
    final salesTargetCtrl = TextEditingController(
      text: user.salesTarget > 0 ? user.salesTarget.toStringAsFixed(0) : '',
    );
    final commissionPercentageCtrl = TextEditingController(
      text: user.commissionPercentage > 0
          ? user.commissionPercentage.toStringAsFixed(0)
          : '',
    );

    final auth = context.read<AuthBloc>().state;
    final branchState = context.read<BranchBloc>().state;
    final branches = _availableBranches(auth, branchState);

    String? selectedBranchId = branches.any((b) => b.id == user.branchId)
        ? user.branchId
        : (branches.isNotEmpty ? branches.first.id : null);

    String selectedRole = user.role;
    const roles = <String>[
      'super_admin',
      'company_admin',
      'branch_manager',
      'sales',
      'support',
      'marketing',
    ];
    const roleLabels = <String, String>{
      'super_admin': 'Super Admin',
      'company_admin': 'Company Admin',
      'branch_manager': 'Branch Manager',
      'sales': 'Sales',
      'support': 'Support',
      'marketing': 'Marketing',
    };
    if (!roles.contains(selectedRole)) selectedRole = 'sales';

    String selectedStatus = user.status;
    const statuses = <String>[
      'active',
      'inactive',
      'suspended',
      'pending',
      'draft',
    ];
    const statusLabels = <String, String>{
      'active': 'Active',
      'inactive': 'Inactive',
      'suspended': 'Suspended',
      'pending': 'Pending',
      'draft': 'Draft',
    };
    if (!statuses.contains(selectedStatus)) selectedStatus = 'active';

    bool initialized = false;
    bool isLoadingDetail =
        false; // Prefill immediately instead of waiting/blocking on loading screen
    String? detailError;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final isSingleOption = branches.length == 1;

          if (!initialized) {
            initialized = true;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              try {
                final detailedUser = await context
                    .read<UserRepository>()
                    .getUserById(user.id);
                setLocal(() {
                  final dParts = detailedUser.name.split(' ');
                  final dFallbackFirst = dParts.isNotEmpty ? dParts.first : '';
                  final dFallbackLast = dParts.length > 1
                      ? dParts.sublist(1).join(' ')
                      : '';

                  final fetchedFirst = detailedUser.firstName.isNotEmpty
                      ? detailedUser.firstName
                      : dFallbackFirst;
                  final fetchedLast = detailedUser.lastName.isNotEmpty
                      ? detailedUser.lastName
                      : dFallbackLast;

                  if (firstNameCtrl.text == initialFirst) {
                    firstNameCtrl.text = fetchedFirst;
                  }
                  if (lastNameCtrl.text == initialLast) {
                    lastNameCtrl.text = fetchedLast;
                  }
                  if (phoneCtrl.text == user.phone) {
                    phoneCtrl.text = detailedUser.phone;
                  }
                  if (departmentCtrl.text == user.department) {
                    departmentCtrl.text = detailedUser.department;
                  }
                  if (jobTitleCtrl.text == user.jobTitle) {
                    jobTitleCtrl.text = detailedUser.jobTitle;
                  }
                  if (salesTargetCtrl.text ==
                      (user.salesTarget > 0
                          ? user.salesTarget.toStringAsFixed(0)
                          : '')) {
                    salesTargetCtrl.text = detailedUser.salesTarget > 0
                        ? detailedUser.salesTarget.toStringAsFixed(0)
                        : '';
                  }
                  if (commissionPercentageCtrl.text ==
                      (user.commissionPercentage > 0
                          ? user.commissionPercentage.toStringAsFixed(0)
                          : '')) {
                    commissionPercentageCtrl.text =
                        detailedUser.commissionPercentage > 0
                        ? detailedUser.commissionPercentage.toStringAsFixed(0)
                        : '';
                  }

                  selectedRole = detailedUser.role;
                  selectedStatus = detailedUser.status;
                  if (branches.any((b) => b.id == detailedUser.branchId)) {
                    selectedBranchId = detailedUser.branchId;
                  }
                });
              } catch (e) {
                // Fail silently in background as we already have list values pre-filled
              }
            });
          }

          Widget buildField({
            required TextEditingController controller,
            required String hint,
            required IconData icon,
            String? Function(String?)? validator,
            TextInputType keyboardType = TextInputType.text,
          }) {
            return TextFormField(
              controller: controller,
              style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.black),
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.grey.shade500,
                ),
                prefixIcon: Icon(icon, size: 20, color: Colors.grey),
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
                  borderSide: const BorderSide(color: Color(0xFF2E8EFF)),
                ),
              ),
              validator: validator,
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            insetPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 24.h,
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: isLoadingDetail
                  ? SizedBox(
                      height: 220.h,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFF2E8EFF),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Fetching user details...',
                              style: GoogleFonts.poppins(
                                fontSize: 14.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : detailError != null
                  ? SizedBox(
                      height: 220.h,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red,
                                size: 36,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                detailError!,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.red,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              TextButton(
                                onPressed: () {
                                  setLocal(() {
                                    isLoadingDetail = true;
                                    detailError = null;
                                    initialized = false;
                                  });
                                },
                                child: Text(
                                  'Retry',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF2E8EFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 20.h,
                        ),
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
                                      Icons.edit_outlined,
                                      color: Color(0xFF2E8EFF),
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Text(
                                    'Edit User',
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

                              // Fields
                              buildField(
                                controller: firstNameCtrl,
                                hint: 'First Name',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'First name is required'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              buildField(
                                controller: lastNameCtrl,
                                hint: 'Last Name',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Last name is required'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              buildField(
                                controller: phoneCtrl,
                                hint: 'Phone Number',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Phone number is required'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              buildField(
                                controller: jobTitleCtrl,
                                hint: 'Job Title',
                                icon: Icons.work_outline_rounded,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Job title is required'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              buildField(
                                controller: departmentCtrl,
                                hint: 'Department',
                                icon: Icons.business_outlined,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Department is required'
                                    : null,
                              ),
                              SizedBox(height: 12.h),
                              buildField(
                                controller: salesTargetCtrl,
                                hint: 'Sales Target (Optional)',
                                icon: Icons.monetization_on_outlined,
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 12.h),
                              buildField(
                                controller: commissionPercentageCtrl,
                                hint: 'Commission Percentage (Optional)',
                                icon: Icons.percent_rounded,
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 16.h),

                              // Branch Selector
                              Text(
                                'Branch',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              GestureDetector(
                                onTap: isSingleOption
                                    ? null
                                    : () {
                                        showModalBottomSheet<void>(
                                          context: context,
                                          backgroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20.r),
                                            ),
                                          ),
                                          builder: (BuildContext sheetCtx) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical: 20.h,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 20.w,
                                                        ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          'Select Branch',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 16.sp,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                        ),
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons.close_rounded,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                sheetCtx,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Divider(),
                                                  Expanded(
                                                    child: ListView.builder(
                                                      itemCount:
                                                          branches.length,
                                                      itemBuilder: (context, index) {
                                                        final b =
                                                            branches[index];
                                                        final isSelected =
                                                            b.id ==
                                                            selectedBranchId;
                                                        return ListTile(
                                                          leading: Icon(
                                                            Icons
                                                                .account_tree_outlined,
                                                            color: isSelected
                                                                ? const Color(
                                                                    0xFF2E8EFF,
                                                                  )
                                                                : Colors
                                                                      .black54,
                                                          ),
                                                          title: Text(
                                                            b.name,
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  isSelected
                                                                  ? FontWeight
                                                                        .w600
                                                                  : FontWeight
                                                                        .w500,
                                                              color: isSelected
                                                                  ? const Color(
                                                                      0xFF2E8EFF,
                                                                    )
                                                                  : Colors
                                                                        .black87,
                                                            ),
                                                          ),
                                                          trailing: isSelected
                                                              ? const Icon(
                                                                  Icons
                                                                      .check_circle_rounded,
                                                                  color: Color(
                                                                    0xFF2E8EFF,
                                                                  ),
                                                                )
                                                              : null,
                                                          onTap: () {
                                                            setLocal(() {
                                                              selectedBranchId =
                                                                  b.id;
                                                            });
                                                            Navigator.pop(
                                                              sheetCtx,
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.account_tree_outlined,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: isSingleOption
                                        ? Tooltip(
                                            message: 'Your branch',
                                            child: Icon(
                                              Icons.lock_outline_rounded,
                                              size: 16,
                                              color: Colors.grey.shade400,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.arrow_drop_down,
                                            color: Color(0xFF003366),
                                          ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  child: Text(
                                    branches
                                            .where(
                                              (b) => b.id == selectedBranchId,
                                            )
                                            .firstOrNull
                                            ?.name ??
                                        'Select branch',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // Role Selector
                              Text(
                                'Role',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.r),
                                      ),
                                    ),
                                    builder: (BuildContext sheetCtx) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20.h,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.w,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Select Role',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.black54,
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(sheetCtx),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: roles.length,
                                                itemBuilder: (context, index) {
                                                  final r = roles[index];
                                                  final isSelected =
                                                      r == selectedRole;
                                                  return ListTile(
                                                    leading: Icon(
                                                      Icons.badge_outlined,
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFF2E8EFF,
                                                            )
                                                          : Colors.black54,
                                                    ),
                                                    title: Text(
                                                      roleLabels[r] ?? r,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                isSelected
                                                                ? FontWeight
                                                                      .w600
                                                                : FontWeight
                                                                      .w500,
                                                            color: isSelected
                                                                ? const Color(
                                                                    0xFF2E8EFF,
                                                                  )
                                                                : Colors
                                                                      .black87,
                                                          ),
                                                    ),
                                                    trailing: isSelected
                                                        ? const Icon(
                                                            Icons
                                                                .check_circle_rounded,
                                                            color: Color(
                                                              0xFF2E8EFF,
                                                            ),
                                                          )
                                                        : null,
                                                    onTap: () {
                                                      setLocal(() {
                                                        selectedRole = r;
                                                      });
                                                      Navigator.pop(sheetCtx);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.work_outline_rounded,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF003366),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  child: Text(
                                    roleLabels[selectedRole] ?? selectedRole,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: 12.h),

                              // Status Selector
                              Text(
                                'Status',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 6.h),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    context: context,
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20.r),
                                      ),
                                    ),
                                    builder: (BuildContext sheetCtx) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20.h,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.w,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Select Status',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.black54,
                                                    ),
                                                    onPressed: () =>
                                                        Navigator.pop(sheetCtx),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Divider(),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: statuses.length,
                                                itemBuilder: (context, index) {
                                                  final s = statuses[index];
                                                  final isSelected =
                                                      s == selectedStatus;
                                                  return ListTile(
                                                    leading: Icon(
                                                      Icons
                                                          .info_outline_rounded,
                                                      color: isSelected
                                                          ? const Color(
                                                              0xFF2E8EFF,
                                                            )
                                                          : Colors.black54,
                                                    ),
                                                    title: Text(
                                                      statusLabels[s] ?? s,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                isSelected
                                                                ? FontWeight
                                                                      .w600
                                                                : FontWeight
                                                                      .w500,
                                                            color: isSelected
                                                                ? const Color(
                                                                    0xFF2E8EFF,
                                                                  )
                                                                : Colors
                                                                      .black87,
                                                          ),
                                                    ),
                                                    trailing: isSelected
                                                        ? const Icon(
                                                            Icons
                                                                .check_circle_rounded,
                                                            color: Color(
                                                              0xFF2E8EFF,
                                                            ),
                                                          )
                                                        : null,
                                                    onTap: () {
                                                      setLocal(() {
                                                        selectedStatus = s;
                                                      });
                                                      Navigator.pop(sheetCtx);
                                                    },
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    prefixIcon: const Icon(
                                      Icons.info_outline_rounded,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    suffixIcon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF003366),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                  ),
                                  child: Text(
                                    statusLabels[selectedStatus] ??
                                        selectedStatus,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),

                              BlocBuilder<UserBloc, UserState>(
                                builder: (_, state) => FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E8EFF),
                                    minimumSize: const Size(0, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                  ),
                                  onPressed:
                                      state.actionStatus == AppStatus.loading
                                      ? null
                                      : () {
                                          if (formKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            final fName = firstNameCtrl.text
                                                .trim();
                                            final lName = lastNameCtrl.text
                                                .trim();
                                            final name = "$fName $lName";

                                            final updateData =
                                                <String, dynamic>{
                                                  'firstName': fName,
                                                  'lastName': lName,
                                                  'name': name,
                                                  'phone': phoneCtrl.text
                                                      .trim(),
                                                  'department': departmentCtrl
                                                      .text
                                                      .trim(),
                                                  'jobTitle': jobTitleCtrl.text
                                                      .trim(),
                                                  'status': selectedStatus,
                                                  'role': selectedRole,
                                                  'branchId': selectedBranchId,
                                                  'primaryBranchId':
                                                      selectedBranchId,
                                                  'email': user.email,
                                                };

                                            if (salesTargetCtrl
                                                .text
                                                .isNotEmpty) {
                                              updateData['salesTarget'] =
                                                  double.tryParse(
                                                    salesTargetCtrl.text,
                                                  ) ??
                                                  0.0;
                                            }
                                            if (commissionPercentageCtrl
                                                .text
                                                .isNotEmpty) {
                                              updateData['commissionPercentage'] =
                                                  double.tryParse(
                                                    commissionPercentageCtrl
                                                        .text,
                                                  ) ??
                                                  0.0;
                                            }

                                            context.read<UserBloc>().add(
                                              UserUpdated(
                                                userId: user.id,
                                                updateData: updateData,
                                              ),
                                            );
                                            Navigator.pop(ctx);
                                          }
                                        },
                                  child: state.actionStatus == AppStatus.loading
                                      ? SizedBox(
                                          width: 20.w,
                                          height: 20.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'Save',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15.sp,
                                            color: Colors.white,
                                          ),
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
        },
      ),
    );
  }

  // ── Delete confirmation ────────────────────────────────────────────────────

  void _confirmDelete(UserModel user) {
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
                    'Delete User',
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
                'Are you sure you want to delete this user?',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 24.h),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFEA4335), // Google Red
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                onPressed: () {
                  context.read<UserBloc>().add(UserDeleted(user.id));
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

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (prev, curr) => curr.actionStatus != prev.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == AppStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'Done!',
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

        // ── AppBar ───────────────────────────────────────────────────────────
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
          title: Text(
            'User Management',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
              onPressed: () => context.read<UserBloc>().add(UserFetched()),
            ),
          ],
        ),

        // ── Body ─────────────────────────────────────────────────────────────
        body: ResponsiveConstraint(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state.status == AppStatus.loading) {
                return ShimmerLoading.listPlaceholder();
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
                      SizedBox(height: 12.h),
                      Text(
                        state.errorMessage ?? 'Failed to load users',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<UserBloc>().add(UserFetched()),
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

              final totalUsers = state.items.length;
              final activeUsers = state.items.where((u) => u.isActive).length;

              final filteredUsers = state.items.where((user) {
                final name = user.name.toLowerCase();
                final email = user.email.toLowerCase();
                return name.contains(_searchQuery) ||
                    email.contains(_searchQuery);
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search & Count Row
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
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
                                fontSize: 13.sp,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search Users by name, email...',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: Colors.grey.shade500,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.black,
                                  size: 20,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          height: 46.h,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
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
                                size: 18,
                                color: Colors.black54,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                '${filteredUsers.length} Users',
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats Cards Row
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        // Total Users Card
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F6FF),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF2E8EFF),
                                      ),
                                      child: Icon(
                                        Icons.people_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$totalUsers',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Total Users',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2.r),
                                  child: const LinearProgressIndicator(
                                    value: 1.0,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF2E8EFF),
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Active Users Card
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8F5),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF2ECC71),
                                      ),
                                      child: Icon(
                                        Icons.person_outline_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$activeUsers',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Active Users',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2.r),
                                  child: LinearProgressIndicator(
                                    value: totalUsers > 0
                                        ? activeUsers / totalUsers
                                        : 0.0,
                                    backgroundColor: Colors.transparent,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          Color(0xFF2ECC71),
                                        ),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // List view
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? Center(
                            child: Text(
                              'No users found',
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: filteredUsers.length,
                            separatorBuilder: (_, __) => SizedBox(height: 12.h),
                            itemBuilder: (context, i) {
                              final user = filteredUsers[i];
                              final initials = user.name.isNotEmpty
                                  ? user.name
                                        .trim()
                                        .split(' ')
                                        .map((p) => p[0])
                                        .take(2)
                                        .join()
                                        .toUpperCase()
                                  : '?';

                              final branchBloc = context.read<BranchBloc>();
                              final authState = context.read<AuthBloc>().state;
                              final matchedBranch = branchBloc.state.items
                                  .cast<BranchModel?>()
                                  .firstWhere(
                                    (b) => b?.id == user.branchId,
                                    orElse: () => null,
                                  );
                              String branchLabel;
                              if (matchedBranch != null) {
                                branchLabel = matchedBranch.name;
                              } else {
                                final synthesised = _availableBranches(
                                  authState,
                                  branchBloc.state,
                                ).where((b) => b.id == user.branchId).toList();
                                branchLabel = synthesised.isNotEmpty
                                    ? synthesised.first.name
                                    : '-';
                              }

                              return Container(
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          color: Color(0xFF2E8EFF),
                                          width: 4.w,
                                        ),
                                      ),
                                    ),
                                    padding: EdgeInsets.all(12.w),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 56.w,
                                          height: 56.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(
                                              0xFF2E8EFF,
                                            ).withOpacity(0.1),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              28.r,
                                            ),
                                            child: Center(
                                              child: Text(
                                                initials,
                                                style: GoogleFonts.poppins(
                                                  color: const Color(
                                                    0xFF2E8EFF,
                                                  ),
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),

                                        // Info column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4.h),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.mail_outline_rounded,
                                                    size: 14,
                                                    color: Color(0xFF2E8EFF),
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Expanded(
                                                    child: Text(
                                                      user.email,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12.sp,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 8.h),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8.w,
                                                          vertical: 3.h,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Color(
                                                        0xFF2E8EFF,
                                                      ).withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6.r,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      _getRoleLabel(user.role),
                                                      style:
                                                          GoogleFonts.poppins(
                                                            color: const Color(
                                                              0xFF2E8EFF,
                                                            ),
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                          ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  const Icon(
                                                    Icons.location_on_outlined,
                                                    size: 14,
                                                    color: Colors.black,
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  Expanded(
                                                    child: Text(
                                                      branchLabel,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 11.sp,
                                                            color: Colors
                                                                .grey
                                                                .shade600,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.w),

                                        // Actions & status Column
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: const Icon(
                                                    Icons.edit_rounded,
                                                    size: 18,
                                                    color: Colors.black54,
                                                  ),
                                                  onPressed: () =>
                                                      _showEditDialog(user),
                                                ),
                                                SizedBox(width: 2.w),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  icon: const Icon(
                                                    Icons.delete_rounded,
                                                    size: 18,
                                                    color: Colors.black54,
                                                  ),
                                                  onPressed: () =>
                                                      _confirmDelete(user),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 18.h),
                                            InkWell(
                                              onTap: () {
                                                context.read<UserBloc>().add(
                                                  UserUpdated(
                                                    userId: user.id,
                                                    updateData: {
                                                      'firstName':
                                                          user.firstName,
                                                      'lastName': user.lastName,
                                                      'name': user.name,
                                                      'phone': user.phone,
                                                      'department':
                                                          user.department,
                                                      'jobTitle': user.jobTitle,
                                                      'salesTarget':
                                                          user.salesTarget,
                                                      'commissionPercentage': user
                                                          .commissionPercentage,
                                                      'status': user.isActive
                                                          ? 'inactive'
                                                          : 'active',
                                                      'role': user.role,
                                                      'branchId': user.branchId,
                                                      'primaryBranchId':
                                                          user.branchId,
                                                      'email': user.email,
                                                    },
                                                  ),
                                                );
                                              },
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 4.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: user.isActive
                                                      ? const Color(0xFFE8F5E9)
                                                      : const Color(0xFFFFEBEE),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 6.w,
                                                      height: 6.h,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: user.isActive
                                                            ? const Color(
                                                                0xFF2E7D32,
                                                              )
                                                            : const Color(
                                                                0xFFC62828,
                                                              ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    Text(
                                                      user.isActive
                                                          ? 'Active'
                                                          : 'Inactive',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 10.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: user.isActive
                                                                ? const Color(
                                                                    0xFF2E7D32,
                                                                  )
                                                                : const Color(
                                                                    0xFFC62828,
                                                                  ),
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
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),

        // ── FAB ──────────────────────────────────────────────────────────────
        floatingActionButton: FloatingActionButton(
          heroTag: 'add_user_fab',
          onPressed: () => Navigator.of(context).pushNamed('/add-user'),
          backgroundColor: const Color(0xFF2E8EFF),
          elevation: 4,
          shape: const CircleBorder(),
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
