import 'package:doro_gear/localization/app_localizations.dart';
import 'package:doro_gear/models/user.dart';
import 'package:flutter/material.dart';

import '../../../constants/app_colors.dart';
import '../../../helpers/enums/user_role.dart';
import '../../../services/user_service.dart';

class AddEditStaffPage extends StatefulWidget {
  final User? staff;
  const AddEditStaffPage({super.key, this.staff});

  @override
  State<AddEditStaffPage> createState() => _AddEditStaffPageState();
}

class _AddEditStaffPageState extends State<AddEditStaffPage> {
  final _formKey = GlobalKey<FormState>();
  late bool _isEditMode;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  UserRole _selectedRole = UserRole.employee;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.staff != null;

    _nameController = TextEditingController(text: _isEditMode ? widget.staff!.name : '');
    _emailController = TextEditingController(text: _isEditMode ? widget.staff!.email : '');
    _phoneController = TextEditingController(text: _isEditMode ? widget.staff!.phoneNumber ?? '' : '');
    _passwordController = TextEditingController();
    _selectedRole = _isEditMode ? widget.staff!.role : UserRole.employee;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveStaff() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (_isEditMode) {
      await UserService.updateUser(
        oldEmail: widget.staff!.email,
        newName: name,
        newPhoneNumber: phone,
        role: _selectedRole,
      );
    } else {
      UserService.registerUser(
        name: name,
        email: email,
        phoneNumber: phone,
        password: password,
        role: _selectedRole,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? t.translate('editStaffTitle') : t.translate('addStaffTitle')),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: t.translate('staffNameLabel'), border: const OutlineInputBorder()),
                validator: (v) => (v?.trim().isEmpty ?? true) ? t.translate('pleaseEnterName') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: t.translate('emailAddress'), border: const OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                readOnly: _isEditMode,
                validator: (v) => (v?.trim().isEmpty ?? true) ? t.translate('pleaseEnterEmail') : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: t.translate('phoneNumber'), border: const OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              if (!_isEditMode)
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: t.translate('password'), border: const OutlineInputBorder()),
                  obscureText: true,
                  validator: (v) => (v?.length ?? 0) < 6 ? t.translate('passwordMinLengthError') : null,
                ),
              if (!_isEditMode) const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: t.translate('roleLabel'), border: const OutlineInputBorder()),
                items: UserRole.values
                    .where((role) => role != UserRole.customer)
                    .map((role) => DropdownMenuItem(value: role, child: Text(role.name.toUpperCase())))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveStaff,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor, foregroundColor: Colors.white),
                  child: Text(t.translate('saveChanges')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}