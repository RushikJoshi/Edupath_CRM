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
import 'package:gtcrm/core/constants/app_enums.dart';
import 'package:gtcrm/core/widgets/responsive_wrapper.dart';
import 'package:gtcrm/core/utils/role_guard.dart';
import 'package:gtcrm/features/branch/data/models/branch_model.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({super.key});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _selectedRole = 'sales';
  String? _selectedBranchId;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    final currentRole = auth.user?.role ?? '';
    if (RoleGuard.isCompanyAdmin(currentRole)) {
      final branchState = context.read<BranchBloc>().state;
      if (branchState.items.isEmpty &&
          branchState.status != AppStatus.loading) {
        context.read<BranchBloc>().add(BranchFetched());
      }
    }

    // Set default branch
    final branches = _availableBranches(
      auth,
      context.read<BranchBloc>().state,
    );
    if (branches.isNotEmpty) {
      _selectedBranchId = branches.first.id;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
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

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBranchId == null || _selectedBranchId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a branch',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    context.read<UserBloc>().add(
      UserCreated(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        role: _selectedRole,
        branchId: _selectedBranchId!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (prev, curr) =>
          curr.actionStatus != prev.actionStatus &&
          (curr.actionStatus == AppStatus.success ||
              curr.actionStatus == AppStatus.failure),
      listener: (context, state) {
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isCurrentRoute) return;

        if (state.actionStatus == AppStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  'User created successfully!',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF2ECC71),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          Future.delayed(
            const Duration(seconds: 1),
          ).then((_) {
            if (mounted) Navigator.of(context).pop();
          });
        } else if (state.actionStatus == AppStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.actionError ?? 'Failed to create user',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),

        // ── AppBar ───────────────────────────────────────────────────────
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
            'Add User',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),

        // ── Body ─────────────────────────────────────────────────────────
        body: ResponsiveConstraint(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── User Details Section ──────────────────────────────
                  _buildSectionCard(
                    title: 'User Details',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildTextField(
                        controller: _nameCtrl,
                        label: 'Full Name',
                        hint: 'e.g. Rahul Patel',
                        icon: Icons.person_outline_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        hint: 'e.g. rahul@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        controller: _passCtrl,
                        label: 'Password',
                        hint: 'Min 6 characters',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ── Assignment Section ─────────────────────────────────
                  BlocBuilder<BranchBloc, BranchState>(
                    builder: (context, branchState) {
                      final auth = context.read<AuthBloc>().state;
                      final currentRole = auth.user?.role ?? '';
                      final branches = _availableBranches(auth, branchState);
                      final branchesLoading =
                          RoleGuard.isCompanyAdmin(currentRole) &&
                          branchState.status == AppStatus.loading;

                      return _buildSectionCard(
                        title: 'Assignment',
                        icon: Icons.assignment_ind_outlined,
                        children: [
                          _buildBranchDropdown(
                            branches: branches,
                            isLoading: branchesLoading,
                          ),
                          const SizedBox(height: 14),
                          _buildRoleDropdown(),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Bottom Bar ────────────────────────────────────────────────────
        bottomNavigationBar: BlocBuilder<UserBloc, UserState>(
          buildWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
          builder: (context, state) {
            final isLoading = state.actionStatus == AppStatus.loading;
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset(0, -1),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 50),
                          foregroundColor: Colors.black87,
                          side: const BorderSide(
                            color: Color(0xFF2E8EFF),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E8EFF),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50,
                        child: FilledButton(
                          onPressed: isLoading ? null : _onSubmit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8EFF),
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Add User',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Section Card ─────────────────────────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E8EFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF2E8EFF)),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ── Text Field ────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: Colors.black54,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF2E8EFF),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
          ),
          validator: validator ??
              (v) => (v == null || v.isEmpty) ? '$label is required' : null,
        ),
      ],
    );
  }

  // ── Branch Selector (Bottom Sheet) ─────────────────────────────────────────
  Widget _buildBranchDropdown({
    required List<BranchModel> branches,
    bool isLoading = false,
  }) {
    final isSingleOption = branches.length == 1;
    final selectedBranch = branches.where((b) => b.id == _selectedBranchId).firstOrNull ?? (branches.isNotEmpty ? branches.first : null);
    final displayText = selectedBranch != null
        ? (selectedBranch.location.isNotEmpty ? '${selectedBranch.name} · ${selectedBranch.location}' : selectedBranch.name)
        : 'Select a branch';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Branch',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        if (isLoading || branches.isEmpty)
          InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(
                Icons.account_tree_outlined,
                size: 18,
                color: Colors.black54,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
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
                    color: Color(0xFF2E8EFF),
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
          )
        else
          GestureDetector(
            onTap: isSingleOption
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (BuildContext ctx) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Select Branch',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Colors.black54),
                                      onPressed: () => Navigator.pop(ctx),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: branches.length,
                                  itemBuilder: (context, index) {
                                    final b = branches[index];
                                    final isSelected = b.id == _selectedBranchId;
                                    return ListTile(
                                      leading: Icon(
                                        Icons.account_tree_outlined,
                                        color: isSelected ? const Color(0xFF2E8EFF) : Colors.black54,
                                      ),
                                      title: Text(
                                        b.name,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                          color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                                        ),
                                      ),
                                      subtitle: b.location.isNotEmpty
                                          ? Text(
                                              b.location,
                                              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                                            )
                                          : null,
                                      trailing: isSelected
                                          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF))
                                          : null,
                                      onTap: () {
                                        setState(() {
                                          _selectedBranchId = b.id;
                                        });
                                        Navigator.pop(ctx);
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
                  color: Colors.black54,
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
                    : const Icon(Icons.arrow_drop_down, color: Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              child: Text(
                displayText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }

  // ── Role Selector (Bottom Sheet) ───────────────────────────────────────────
  Widget _buildRoleDropdown() {
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

    final effectiveValue =
        roles.contains(_selectedRole) ? _selectedRole : roles.first;
    final displayText = labels[effectiveValue] ?? effectiveValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext ctx) {
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Select Role',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: Colors.black54),
                              onPressed: () => Navigator.pop(ctx),
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
                            final isSelected = r == effectiveValue;
                            return ListTile(
                              leading: Icon(
                                Icons.badge_outlined,
                                color: isSelected ? const Color(0xFF2E8EFF) : Colors.black54,
                              ),
                              title: Text(
                                labels[r] ?? r,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                                ),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF))
                                  : null,
                              onTap: () {
                                setState(() {
                                  _selectedRole = r;
                                });
                                Navigator.pop(ctx);
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
                Icons.badge_outlined,
                size: 18,
                color: Colors.black54,
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            child: Text(
              displayText,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
