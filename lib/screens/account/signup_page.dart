import 'package:doro_gear/localization/app_localizations.dart';
import 'package:doro_gear/screens/account/signin_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants/app_colors.dart';
import '../../services/user_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    UserService.initialize();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final t = AppLocalizations.of(context)!;
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('agreeToTermsPrompt')), backgroundColor: Colors.red),
      );
      return;
    }

    final name = _nameController.text.trim();
    final success = UserService.registerUser(
      name: name,
      email: _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.translate('accountCreatedSuccess').replaceAll('{name}', name)),
          backgroundColor: AppColors.primaryColor,
        ),
      );
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.translate('registrationFailed')), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          _buildGradientBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(t),
                  _buildSignUpForm(t),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.translate('signUp'),
              style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            Container(width: 170, height: 3, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpForm(AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10))
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.translate('createAccount'), style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
            const SizedBox(height: 8),
            Text(t.translate('fillInfoToSignUp'), style: TextStyle(
                fontSize: 14, color: Colors.grey[600], height: 1.5)),
            const SizedBox(height: 32),
            _buildTextField(t, controller: _nameController,
                label: t.translate('fullName'),
                hint: t.translate('enterYourFullName'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return t.translate('pleaseEnterName');
                  }
                  if (v.trim().length < 2) {
                    return t.translate('nameMinLength');
                  }
                  return null;
                }),
            const SizedBox(height: 20),
            _buildTextField(t, controller: _emailController,
                label: t.translate('emailAddress'),
                hint: t.translate('enterYourEmail'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return t.translate('pleaseEnterEmail');
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                    return t.translate('emailInvalid');
                  }
                  return null;
                }),
            const SizedBox(height: 20),
            _buildTextField(t, controller: _phoneController,
                label: t.translate('phoneNumber'),
                hint: t.translate('enterYourPhoneNumber'),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11)
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return t.translate('pleaseEnterPhone');
                  }
                  if (v.length < 10) return t.translate('phoneMinLength');
                  return null;
                }),
            const SizedBox(height: 20),
            _buildPasswordField(t),
            const SizedBox(height: 20),
            _buildConfirmPasswordField(t),
            const SizedBox(height: 16),
            _buildTermsAndConditions(t),
            const SizedBox(height: 32),
            _buildSignUpButton(t),
            const SizedBox(height: 24),
            _buildSocialSignUpButtons(t),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(AppLocalizations t, {required TextEditingController controller, required String label, required String hint, String? Function(String?)? validator, TextInputType? keyboardType, List<TextInputFormatter>? inputFormatters}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            filled: true,
            fillColor: Colors.grey[100],
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryColor)),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildPasswordField(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.translate('password'), style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          validator: (v) {
            if (v == null || v.isEmpty) return t.translate('pleaseEnterPassword');
            if (v.length < 6) return t.translate('passwordMinLength');
            return null;
          },
          decoration: InputDecoration(
            hintText: t.translate('enterYourPassword'),
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            filled: true,
            fillColor: Colors.grey[100],
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryColor)),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[600]),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.translate('confirmPassword'), style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          validator: (v) {
            if (v == null || v.isEmpty) return t.translate('pleaseConfirmPassword');
            if (v != _passwordController.text) return t.translate('passwordsDoNotMatch');
            return null;
          },
          decoration: InputDecoration(
            hintText: t.translate('confirmYourPassword'),
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            filled: true,
            fillColor: Colors.grey[100],
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryColor)),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey[600]),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildTermsAndConditions(AppLocalizations t) {
    return Row(
      children: [
        SizedBox(
          width: 20, height: 20,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
            activeColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('${t.translate('agreeToTerms')} ', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              GestureDetector(
                onTap: () { /* Navigate to terms page */ },
                child: Text(
                  t.translate('termsAndConditions'),
                  style: const TextStyle(fontSize: 13, color: AppColors.primaryColor, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(AppLocalizations t) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _handleSignUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(t.translate('signUp'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ),
    );
  }

  Widget _buildSocialSignUpButtons(AppLocalizations t) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${t.translate('alreadyHaveAccount')} ", style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(t.translate('signIn'), style: const TextStyle(fontSize: 13, color: AppColors.primaryColor, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }
}