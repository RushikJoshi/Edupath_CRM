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

  // ── Add User dialog ────────────────────────────────────────────────────────

  void _showAddDialog() {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    String selectedRole = 'sales';

    final auth = context.read<AuthBloc>().state;
    final branchState = context.read<BranchBloc>().state;
    final currentRole = auth.user?.role ?? '';
    final branches = _availableBranches(auth, branchState);
    final branchesLoading =
        RoleGuard.isCompanyAdmin(currentRole) &&
        branchState.status == AppStatus.loading;

    String? selectedBranchId = branches.isNotEmpty ? branches.first.id : null;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_add_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Add User',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      nameCtrl,
                      'Full Name',
                      Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      emailCtrl,
                      'Email',
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      passCtrl,
                      'Password',
                      Icons.lock_outline_rounded,
                      obscure: true,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Password is required';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildBranchDropdown(
                      branches: branches,
                      value: selectedBranchId,
                      onChanged: (v) => setLocal(() => selectedBranchId = v),
                      isLoading: branchesLoading,
                    ),
                    const SizedBox(height: 12),
                    _buildRoleDropdown(
                      value: selectedRole,
                      onChanged: (v) =>
                          setLocal(() => selectedRole = v ?? selectedRole),
                    ),
                  ],
                ),
              ),
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
            BlocBuilder<UserBloc, UserState>(
              builder: (_, state) => FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: state.actionStatus == AppStatus.loading
                    ? null
                    : () {
                        if (formKey.currentState?.validate() ?? false) {
                          if (selectedBranchId == null ||
                              selectedBranchId!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Please select a branch',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          context.read<UserBloc>().add(
                            UserCreated(
                              name: nameCtrl.text.trim(),
                              email: emailCtrl.text.trim(),
                              password: passCtrl.text,
                              role: selectedRole,
                              branchId: selectedBranchId!,
                            ),
                          );
                          Navigator.pop(ctx);
                        }
                      },
                child: state.actionStatus == AppStatus.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Add',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit User dialog ───────────────────────────────────────────────────────

  void _showEditDialog(UserModel user) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: user.name);
    String selectedRole = user.role;

    final auth = context.read<AuthBloc>().state;
    final branchState = context.read<BranchBloc>().state;
    final currentRole = auth.user?.role ?? '';
    final branches = _availableBranches(auth, branchState);
    final branchesLoading =
        RoleGuard.isCompanyAdmin(currentRole) &&
        branchState.status == AppStatus.loading;

    String? selectedBranchId = branches.any((b) => b.id == user.branchId)
        ? user.branchId
        : (branches.isNotEmpty ? branches.first.id : null);

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.stageInterested.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: AppColors.stageInterested,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Edit User',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      nameCtrl,
                      'Full Name',
                      Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildBranchDropdown(
                      branches: branches,
                      value: selectedBranchId,
                      onChanged: (v) => setLocal(() => selectedBranchId = v),
                      isLoading: branchesLoading,
                    ),
                    const SizedBox(height: 12),
                    _buildRoleDropdown(
                      value: selectedRole,
                      onChanged: (v) =>
                          setLocal(() => selectedRole = v ?? selectedRole),
                    ),
                  ],
                ),
              ),
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
            BlocBuilder<UserBloc, UserState>(
              builder: (_, state) => FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: state.actionStatus == AppStatus.loading
                    ? null
                    : () {
                        if (formKey.currentState?.validate() ?? false) {
                          context.read<UserBloc>().add(
                            UserUpdated(
                              userId: user.id,
                              name: nameCtrl.text.trim(),
                              role: selectedRole,
                              branchId: selectedBranchId,
                            ),
                          );
                          Navigator.pop(ctx);
                        }
                      },
                child: state.actionStatus == AppStatus.loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete confirmation ────────────────────────────────────────────────────

  void _confirmDelete(UserModel user) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Delete User',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const TextSpan(text: '? This action cannot be undone.'),
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
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.read<UserBloc>().add(UserDeleted(user.id));
              Navigator.pop(ctx);
            },
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── shared form widgets ────────────────────────────────────────────────────

  Widget _buildTextField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
        prefixIcon: Icon(
          icon,
          size: 18,
          color: AppColors.primary.withOpacity(0.6),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
      validator:
          validator ??
          (v) => (v == null || v.isEmpty) ? '$label is required' : null,
    );
  }

  Widget _buildBranchDropdown({
    required List<BranchModel> branches,
    required String? value,
    required void Function(String?) onChanged,
    bool isLoading = false,
  }) {
    if (isLoading || branches.isEmpty) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Branch',
          labelStyle: GoogleFonts.poppins(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
          prefixIcon: Icon(
            Icons.account_tree_outlined,
            size: 18,
            color: AppColors.primary.withOpacity(0.6),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Loading branches…',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final isSingleOption = branches.length == 1;
    final effectiveValue = branches.any((b) => b.id == value)
        ? value
        : branches.first.id;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      isExpanded: true,
      icon: isSingleOption
          ? Tooltip(
              message: 'Your branch',
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 16,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              ),
            )
          : const Icon(Icons.arrow_drop_down),
      decoration: InputDecoration(
        labelText: 'Branch',
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
        prefixIcon: Icon(
          Icons.account_tree_outlined,
          size: 18,
          color: AppColors.primary.withOpacity(0.6),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      onChanged: isSingleOption ? null : onChanged,
      items: branches
          .map(
            (b) => DropdownMenuItem(
              value: b.id,
              child: Text(
                b.location.isNotEmpty ? '${b.name} · ${b.location}' : b.name,
                style: GoogleFonts.poppins(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      validator: (v) =>
          (v == null || v.isEmpty) ? 'Please select a branch' : null,
    );
  }

  Widget _buildRoleDropdown({
    required String value,
    required void Function(String?) onChanged,
  }) {
    const roles = <String>[
      'company_admin',
      'branch_manager',
      'sales',
      'sales_user',
    ];
    const labels = <String, String>{
      'company_admin': 'Company Admin',
      'branch_manager': 'Branch Manager',
      'sales': 'Sales',
      'sales_user': 'Sales User',
    };

    final effectiveValue = roles.contains(value) ? value : roles.first;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Role',
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey.shade600,
        ),
        prefixIcon: Icon(
          Icons.badge_outlined,
          size: 18,
          color: AppColors.primary.withOpacity(0.6),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
      style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
      items: roles
          .map(
            (r) => DropdownMenuItem(
              value: r,
              child: Text(
                labels[r] ?? r,
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
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
                  borderRadius: BorderRadius.circular(10),
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
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,

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
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 28),
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
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'Failed to load users',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () =>
                            context.read<UserBloc>().add(UserFetched()),
                        icon: const Icon(Icons.refresh_rounded),
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
                return name.contains(_searchQuery) || email.contains(_searchQuery);
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search & Count Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
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
                              style: GoogleFonts.poppins(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Search Users by name, email...',
                                hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey, size: 20),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
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
                              const Icon(Icons.people_alt_outlined, size: 18, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(
                                '${filteredUsers.length} Users',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Total Users Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F6FF),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF2E8EFF),
                                      ),
                                      child: const Icon(Icons.people_rounded, size: 16, color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$totalUsers',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Total Users',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: const LinearProgressIndicator(
                                    value: 1.0,
                                    backgroundColor: Colors.transparent,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E8EFF)),
                                    minHeight: 4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Active Users Card
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F8F5),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF2ECC71),
                                      ),
                                      child: const Icon(Icons.person_outline_rounded, size: 16, color: Colors.white),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$activeUsers',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Active Users',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: totalUsers > 0 ? activeUsers / totalUsers : 0.0,
                                    backgroundColor: Colors.transparent,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
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

                  const SizedBox(height: 16),

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
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 56,
                                          height: 56,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: const Color(0xFF2E8EFF).withOpacity(0.1),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(28),
                                            child: Center(
                                              child: Text(
                                                initials,
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFF2E8EFF),
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Info column
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
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
                                                      user.email,
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
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFF2E8EFF).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      _getRoleLabel(user.role),
                                                      style: GoogleFonts.poppins(
                                                        color: const Color(0xFF2E8EFF),
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                   const SizedBox(width: 8),
                                                   const Icon(Icons.location_on_outlined, size: 14, color: Colors.black),
                                                   const SizedBox(width: 2),
                                                  Expanded(
                                                    child: Text(
                                                      branchLabel,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 11,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Actions & status Column
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.black54),
                                                  onPressed: () => _showEditDialog(user),
                                                ),
                                                const SizedBox(width: 2),
                                                IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.black54),
                                                  onPressed: () => _confirmDelete(user),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 18),
                                            InkWell(
                                              onTap: () {
                                                context.read<UserBloc>().add(
                                                  UserUpdated(
                                                    userId: user.id,
                                                    name: user.name,
                                                    role: user.role,
                                                    branchId: user.branchId,
                                                    status: user.isActive ? 'inactive' : 'active',
                                                  ),
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(12),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: user.isActive ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      width: 6,
                                                      height: 6,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: user.isActive ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      user.isActive ? 'Active' : 'Inactive',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: user.isActive ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
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
          onPressed: _showAddDialog,
          backgroundColor: const Color(0xFF2E8EFF),
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),

      ),
    );
  }
}
