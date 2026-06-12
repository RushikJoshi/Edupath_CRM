import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/branch/branch_bloc.dart';
import '../../bloc/branch/branch_event.dart';
import '../../bloc/branch/branch_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/widgets/responsive_wrapper.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/utils/role_guard.dart';
import '../../data/models/branch_model.dart';
import '../../data/models/user_model.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(UserFetched());

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

  // ── role / badge helpers ───────────────────────────────────────────────────

  Color _getBadgeColor(String role) {
    if (RoleGuard.isCompanyAdmin(role)) return AppColors.error;
    if (RoleGuard.isBranchManager(role)) return AppColors.stageInterested;
    return AppColors.primary;
  }

  String _getRoleLabel(String role) {
    if (RoleGuard.isCompanyAdmin(role)) return 'Company Admin';
    if (RoleGuard.isBranchManager(role)) return 'Branch Manager';
    if (RoleGuard.isSales(role)) return 'Sales';
    return role.toUpperCase();
  }

  // ── build the branch list available to the logged-in user ─────────────────
  //
  // Company Admin  → all branches from BranchBloc
  // Branch Manager → only the branch whose id matches their own branchId

  List<BranchModel> _availableBranches(
    AuthState auth,
    BranchState branchState,
  ) {
    final currentRole = auth.user?.role ?? '';
    final currentBranchId = auth.user?.branchId ?? '';

    if (RoleGuard.isCompanyAdmin(currentRole)) {
      return branchState.items;
    }

    // Branch Manager: no API call is made for branches.
    // First try to find their branch in the already-loaded list (if any).
    // If not found, synthesise a stub from their own branchId so the
    // dropdown always shows exactly one, locked option.
    if (currentBranchId.isEmpty) return [];

    final fromList = branchState.items
        .where((b) => b.id == currentBranchId)
        .toList();

    if (fromList.isNotEmpty) return fromList;

    // Fallback: synthesise from the stored branchName (set at login).
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

    // Pre-select: first available branch
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

                    // ── Branch dropdown ──────────────────────────────────────
                    _buildBranchDropdown(
                      branches: branches,
                      value: selectedBranchId,
                      onChanged: (v) => setLocal(() => selectedBranchId = v),
                      isLoading: branchesLoading,
                    ),
                    const SizedBox(height: 12),

                    // ── Role dropdown ────────────────────────────────────────
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

    // Pre-select the user's current branch if it is in the available list,
    // else fall back to the first available branch.
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

                    // ── Branch dropdown ──────────────────────────────────────
                    _buildBranchDropdown(
                      branches: branches,
                      value: selectedBranchId,
                      onChanged: (v) => setLocal(() => selectedBranchId = v),
                      isLoading: branchesLoading,
                    ),
                    const SizedBox(height: 12),

                    // ── Role dropdown ────────────────────────────────────────
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

  /// Branch dropdown.
  /// - Company Admin : all branches are selectable.
  /// - Branch Manager: only their one branch is shown (effectively locked).
  Widget _buildBranchDropdown({
    required List<BranchModel> branches,
    required String? value,
    required void Function(String?) onChanged,
    bool isLoading = false,
  }) {
    // Show spinner only when explicitly loading (Company Admin waiting for API).
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
      // Branch managers have only one item — disable interaction
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
        backgroundColor: AppColors.background,

        // ── AppBar ───────────────────────────────────────────────────────────
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
                'User Management',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text(
                'Manage team access',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              onPressed: () => context.read<UserBloc>().add(UserFetched()),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.people_rounded,
                    color: Colors.white,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  BlocBuilder<UserBloc, UserState>(
                    builder: (_, state) => Text(
                      '${state.items.length} Users',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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

              if (state.items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.people_rounded,
                          size: 36,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users found',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap + to add your first user',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: responsiveListPadding(context),
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final user = state.items[i];
                  final rc = _getBadgeColor(user.role);
                  final initials = user.name.isNotEmpty
                      ? user.name
                            .trim()
                            .split(' ')
                            .map((p) => p[0])
                            .take(2)
                            .join()
                            .toUpperCase()
                      : '?';

                  // Resolve branch name for display.
                  // For Branch Managers, BranchBloc may have no items loaded —
                  // fall back to _availableBranches which synthesises a stub.
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
                    // Try synthesised list (covers Branch Manager's own branch)
                    final synthesised = _availableBranches(
                      authState,
                      branchBloc.state,
                    ).where((b) => b.id == user.branchId).toList();
                    branchLabel = synthesised.isNotEmpty
                        ? synthesised.first.name
                        : '-';
                  }

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
                    child: InnerShadow(
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
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            // Avatar
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: user.isActive
                                    ? AppColors.primary.withOpacity(0.08)
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: user.isActive
                                      ? AppColors.primary.withOpacity(0.25)
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: GoogleFonts.poppins(
                                    color: user.isActive
                                        ? AppColors.primary
                                        : Colors.grey.shade400,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    user.name,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: rc.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          border: Border.all(
                                            color: rc.withOpacity(0.25),
                                          ),
                                        ),
                                        child: Text(
                                          _getRoleLabel(user.role),
                                          style: GoogleFonts.poppins(
                                            color: rc,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.account_tree_outlined,
                                        size: 11,
                                        color: AppColors.primary.withOpacity(
                                          0.4,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          // Show branch name if resolved,
                                          // fall back to raw id
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
                                  const SizedBox(height: 2),
                                  Text(
                                    user.email,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),

                            // Active toggle + actions
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Switch(
                                  value: user.isActive,
                                  onChanged: (val) {
                                    context.read<UserBloc>().add(
                                      UserUpdated(
                                        userId: user.id,
                                        name: user.name,
                                        role: user.role,
                                        branchId: user.branchId,
                                        status: val ? 'active' : 'inactive',
                                      ),
                                    );
                                  },
                                  activeColor: AppColors.stageWon,
                                  activeTrackColor: AppColors.stageWon
                                      .withOpacity(0.3),
                                  inactiveThumbColor: Colors.grey.shade400,
                                  inactiveTrackColor: Colors.grey.shade200,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                Text(
                                  user.isActive ? 'Active' : 'Inactive',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: user.isActive
                                        ? AppColors.stageWon
                                        : Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _iconAction(
                                      icon: Icons.edit_rounded,
                                      color: AppColors.stageInterested,
                                      tooltip: 'Edit',
                                      onTap: () => _showEditDialog(user),
                                    ),
                                    const SizedBox(width: 4),
                                    _iconAction(
                                      icon: Icons.delete_rounded,
                                      color: AppColors.error,
                                      tooltip: 'Delete',
                                      onTap: () => _confirmDelete(user),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // ── FAB ──────────────────────────────────────────────────────────────
        floatingActionButton: InnerShadow(
          shadows: [
            BoxShadow(
              color: Colors.transparent,
              blurRadius: 10,
              offset: const Offset(3, 3),
            ),
          ],
          child: FloatingActionButton.extended(
            heroTag: 'add_user_fab',
            onPressed: _showAddDialog,
            icon: const Icon(Icons.person_add_rounded, color: Colors.white),
            label: Text(
              'Add User',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.primary,
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _iconAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
      ),
    );
  }
}
