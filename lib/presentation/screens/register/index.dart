import 'package:flutter/material.dart';
import 'package:homesync/core/constants/theme.dart';
import 'package:homesync/main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../verify/index.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  void _onPasswordChanged() {
    setState(() {}); // trigger UI update
  }

  bool get _isPasswordMismatch {
    return _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text != _confirmPasswordController.text;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final response = await authService.api.post('/auth/register', {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'password_confirmation': _confirmPasswordController.text,
    });

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'Registration successful! Please verify OTP sent to your email.',
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            email: _emailController.text.trim(),
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: response.message,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CustomTheme().padding(''),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: CustomTheme().vGap('2xl'),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: CustomTheme().vGap('m'),
                  children: [
                    Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Sign up to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: CustomTheme().vGap(''),
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      keyboardType: TextInputType.name,
                      validator: Validators.validateName,
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.textSecondary),
                    ),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.textSecondary),
                    ),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      isPassword: true,
                      validator: Validators.validatePassword,
                      prefixIcon: const Icon(Icons.lock_outlined,
                          color: AppColors.textSecondary),
                    ),
                    CustomTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      isPassword: true,
                      validator: _validateConfirmPassword,
                      prefixIcon: const Icon(Icons.lock_outlined,
                          color: AppColors.textSecondary),

                      // 👇 ADD THIS
                      suffixIcon: _confirmPasswordController.text.isEmpty
                          ? null
                          : Icon(
                              _isPasswordMismatch
                                  ? Icons.cancel
                                  : Icons.check_circle,
                              color: _isPasswordMismatch
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                    ),
                    if (_isPasswordMismatch)
                      Padding(
                        padding: CustomTheme().padding('warning-text'),
                        child: Text(
                          'Passwords do not match',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                // Register Button
                CustomButton(
                  text: 'Sign Up',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: CustomTheme().fontSize('l'),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: CustomTheme().fontSize('l'),
                          fontWeight: CustomTheme().fontWeight('semibold'),
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
