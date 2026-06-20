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

  // Form Controllers
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _employeeIdCtrl = TextEditingController();
  final _jobTitleCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // State Selections
  String _selectedRole = 'sales';
  String _selectedStatus = 'active';
  String? _selectedBranchId;
  DateTime? _selectedJoiningDate;
  String _selectedEmploymentType = 'full_time';

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    
    // Fetch branches if empty
    final branchState = context.read<BranchBloc>().state;
    if (branchState.items.isEmpty && branchState.status != AppStatus.loading) {
      context.read<BranchBloc>().add(BranchFetched());
    }

    // Set default branch
    final branches = _availableBranches(auth, branchState);
    if (branches.isNotEmpty) {
      _selectedBranchId = branches.first.id;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _departmentCtrl.dispose();
    _employeeIdCtrl.dispose();
    _jobTitleCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  List<BranchModel> _availableBranches(AuthState auth, BranchState branchState) {
    final currentRole = auth.user?.role ?? '';
    final currentBranchId = auth.user?.branchId ?? '';

    if (RoleGuard.isCompanyAdmin(currentRole)) {
      return branchState.items;
    }

    if (currentBranchId.isEmpty) return [];

    final fromList = branchState.items.where((b) => b.id == currentBranchId).toList();
    if (fromList.isNotEmpty) return fromList;

    final storedName = auth.user?.branchName ?? '';
    return [
      BranchModel(
        id: currentBranchId,
        name: storedName.isNotEmpty ? storedName : currentBranchId,
      ),
    ];
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  Future<void> _selectDate(BuildContext context, DateTime? initial, Function(DateTime) onSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2E8EFF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBranchId == null || _selectedBranchId!.isEmpty) {
      _showErrorSnackBar('Please select a branch');
      return;
    }

    if (_selectedJoiningDate == null) {
      _showErrorSnackBar('Please select a joining date');
      return;
    }

    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final name = "$firstName $lastName";

    // Build user payload containing exactly the requested 13 fields (plus auto-generated name)
    final Map<String, dynamic> userData = {
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'email': _emailCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'role': _selectedRole,
      'department': _departmentCtrl.text.trim(),
      'primaryBranchId': _selectedBranchId,
      'branchId': _selectedBranchId, // Keep compatibility with existing repository
      'employeeId': _employeeIdCtrl.text.trim(),
      'jobTitle': _jobTitleCtrl.text.trim(),
      'joiningDate': _formatDate(_selectedJoiningDate!),
      'employmentType': _selectedEmploymentType,
      'password': _passCtrl.text,
      'status': _selectedStatus,
    };

    context.read<UserBloc>().add(UserCreated(userData));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserBloc, UserState>(
      listenWhen: (prev, curr) =>
          curr.actionStatus != prev.actionStatus &&
          (curr.actionStatus == AppStatus.success || curr.actionStatus == AppStatus.failure),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                duration: const Duration(seconds: 2),
              ),
            );
          final nav = Navigator.of(context);
          Future.delayed(const Duration(seconds: 1)).then((_) {
            if (mounted) nav.pop();
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2E8EFF),
          elevation: 0,
          toolbarHeight: 64,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Add User',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20.sp, color: Colors.white),
          ),
        ),
        body: ResponsiveConstraint(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Section 1: Personal & Credentials
                  _buildSectionCard(
                    title: 'Personal & Credentials',
                    icon: Icons.person_outline_rounded,
                    children: [
                      _buildTextField(
                        controller: _firstNameCtrl,
                        label: 'First Name *',
                        hint: 'Rahul',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.isEmpty ? 'First name is required' : null,
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _lastNameCtrl,
                        label: 'Last Name *',
                        hint: 'Patel',
                        icon: Icons.person_outline_rounded,
                        validator: (v) => v == null || v.isEmpty ? 'Last name is required' : null,
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _emailCtrl,
                        label: 'Email *',
                        hint: 'rahul@example.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Email is required';
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _phoneCtrl,
                        label: 'Phone Number *',
                        hint: 'e.g. 9876543210',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty ? 'Phone number is required' : null,
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _passCtrl,
                        label: 'Password *',
                        hint: 'Min 6 characters',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Password is required';
                          if (v.length < 6) return 'Min 6 characters';
                          return null;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Section 2: Employment Details
                  _buildSectionCard(
                    title: 'Employment Details',
                    icon: Icons.badge_outlined,
                    children: [
                      _buildTextField(
                        controller: _employeeIdCtrl,
                        label: 'Employee ID *',
                        hint: 'e.g. EMP001',
                        icon: Icons.badge_outlined,
                        validator: (v) => v == null || v.isEmpty ? 'Employee ID is required' : null,
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _jobTitleCtrl,
                        label: 'Job Title *',
                        hint: 'e.g. Sales Executive',
                        icon: Icons.work_outline_rounded,
                        validator: (v) => v == null || v.isEmpty ? 'Job title is required' : null,
                      ),
                      SizedBox(height: 14.h),
                      _buildTextField(
                        controller: _departmentCtrl,
                        label: 'Department *',
                        hint: 'e.g. Sales',
                        icon: Icons.business_outlined,
                        validator: (v) => v == null || v.isEmpty ? 'Department is required' : null,
                      ),
                      SizedBox(height: 14.h),
                      _buildDatePickerField(
                        label: 'Joining Date *',
                        value: _selectedJoiningDate,
                        onTap: () => _selectDate(context, _selectedJoiningDate, (dt) {
                          setState(() => _selectedJoiningDate = dt);
                        }),
                      ),
                      SizedBox(height: 14.h),
                      _buildEmploymentTypeDropdown(),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Section 3: Branch & Roles
                  _buildSectionCard(
                    title: 'Organization & Status',
                    icon: Icons.corporate_fare_outlined,
                    children: [
                      BlocBuilder<BranchBloc, BranchState>(
                        builder: (context, branchState) {
                          final auth = context.read<AuthBloc>().state;
                          final branches = _availableBranches(auth, branchState);
                          final branchesLoading = RoleGuard.isCompanyAdmin(auth.user?.role ?? '') &&
                              branchState.status == AppStatus.loading;
                          return _buildBranchDropdown(branches: branches, isLoading: branchesLoading);
                        },
                      ),
                      SizedBox(height: 14.h),
                      _buildRoleDropdown(),
                      SizedBox(height: 14.h),
                      _buildStatusDropdown(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BlocBuilder<UserBloc, UserState>(
          buildWhen: (prev, curr) => prev.actionStatus != curr.actionStatus,
          builder: (context, state) {
            final isLoading = state.actionStatus == AppStatus.loading;
            return Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Color(0x10000000), blurRadius: 10, spreadRadius: 0, offset: Offset(0, -4)),
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
                          side: BorderSide(color: Color(0xFF2E8EFF), width: 1.5.w),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Color(0xFF2E8EFF)),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 50.h,
                        child: FilledButton(
                          onPressed: isLoading ? null : _onSubmit,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E8EFF),
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 20.h,
                                  width: 20.w,
                                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                )
                              : Text(
                                  'Add User',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15.sp, color: Colors.white),
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

  // ── Card Container ──
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 4),
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
                decoration: BoxDecoration(
                  color: Color(0xFF2E8EFF).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF2E8EFF)),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  // ── Form Field Builders ──

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
          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade400),
            prefixIcon: Icon(icon, size: 18, color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
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
              borderSide: BorderSide(color: Color(0xFF2E8EFF), width: 1.5.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: Colors.red, width: 1.5.w),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
  }) {
    final text = value != null ? _formatDate(value) : 'Select date';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        SizedBox(height: 6.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: InputDecorator(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.black54),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: value != null ? Colors.black : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBranchDropdown({
    required List<BranchModel> branches,
    bool isLoading = false,
  }) {
    final selectedBranch = branches.where((b) => b.id == _selectedBranchId).firstOrNull ??
        (branches.isNotEmpty ? branches.first : null);
    final displayText = selectedBranch != null ? selectedBranch.name : 'Select branch *';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary Branch *',
          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        SizedBox(height: 6.h),
        if (isLoading)
          _buildLoadingDecorator('Loading branches...')
        else
          _buildDropdownSelector(
            displayText: displayText,
            icon: Icons.account_tree_outlined,
            onTap: () => _showBranchPicker(branches),
          ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    const roles = [
      'super_admin',
      'company_admin',
      'branch_manager',
      'sales',
      'support',
      'marketing',
    ];
    final labels = {
      'super_admin': 'Super Admin',
      'company_admin': 'Company Admin',
      'branch_manager': 'Branch Manager',
      'sales': 'Sales',
      'support': 'Support',
      'marketing': 'Marketing',
    };
    final displayText = labels[_selectedRole] ?? _selectedRole;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role *',
          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        SizedBox(height: 6.h),
        _buildDropdownSelector(
          displayText: displayText,
          icon: Icons.badge_outlined,
          onTap: () => _showSimpleListPicker(
            title: 'Select Role',
            items: roles,
            labels: labels,
            selectedValue: _selectedRole,
            onSelected: (val) => setState(() => _selectedRole = val),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    const statuses = ['active', 'inactive', 'suspended', 'pending', 'draft'];
    final labels = {
      'active': 'Active',
      'inactive': 'Inactive',
      'suspended': 'Suspended',
      'pending': 'Pending',
      'draft': 'Draft',
    };
    final displayText = labels[_selectedStatus] ?? _selectedStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status *',
          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        SizedBox(height: 6.h),
        _buildDropdownSelector(
          displayText: displayText,
          icon: Icons.info_outline_rounded,
          onTap: () => _showSimpleListPicker(
            title: 'Select Status',
            items: statuses,
            labels: labels,
            selectedValue: _selectedStatus,
            onSelected: (val) => setState(() => _selectedStatus = val),
          ),
        ),
      ],
    );
  }

  Widget _buildEmploymentTypeDropdown() {
    const types = ['full_time', 'part_time', 'contract', 'intern'];
    final labels = {
      'full_time': 'Full Time',
      'part_time': 'Part Time',
      'contract': 'Contract',
      'intern': 'Intern',
    };
    final displayText = labels[_selectedEmploymentType] ?? _selectedEmploymentType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Employment Type *',
          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        SizedBox(height: 6.h),
        _buildDropdownSelector(
          displayText: displayText,
          icon: Icons.work_history_outlined,
          onTap: () => _showSimpleListPicker(
            title: 'Select Employment Type',
            items: types,
            labels: labels,
            selectedValue: _selectedEmploymentType,
            onSelected: (val) => setState(() => _selectedEmploymentType = val),
          ),
        ),
      ],
    );
  }

  // ── Dropdown Selectors & Pickers ──

  Widget _buildLoadingDecorator(String text) {
    return InputDecorator(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.refresh_rounded, size: 18, color: Colors.black54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14.w,
            height: 14.h,
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2E8EFF)),
          ),
          SizedBox(width: 10.w),
          Text(text, style: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildDropdownSelector({
    required String displayText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: Colors.black54),
          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.r),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
        child: Text(
          displayText,
          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  void _showSimpleListPicker({
    required String title,
    required List<String> items,
    required Map<String, String> labels,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (BuildContext ctx) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black)),
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
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final val = items[index];
                    final isSelected = val == selectedValue;
                    return ListTile(
                      title: Text(
                        labels[val] ?? val,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF)) : null,
                      onTap: () {
                        onSelected(val);
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
  }

  void _showBranchPicker(List<BranchModel> branches) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (BuildContext ctx) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Select Primary Branch', style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black)),
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
                      leading: Icon(Icons.account_tree_outlined, color: isSelected ? const Color(0xFF2E8EFF) : Colors.black54),
                      title: Text(
                        b.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF2E8EFF) : Colors.black87,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2E8EFF)) : null,
                      onTap: () {
                        setState(() => _selectedBranchId = b.id);
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
  }
}