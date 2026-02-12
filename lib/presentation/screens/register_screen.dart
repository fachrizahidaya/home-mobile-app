import 'package:flutter/material.dart';
import 'package:homesync/core/constants/theme.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import 'otp_verification_screen.dart';

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
  final _usernameController = TextEditingController();
  bool _isCheckingUsername = false;
  bool _usernameAvailable = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkUsername(String username) async {
    if (username.length >= 3) {
      setState(() => _isCheckingUsername = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final available = await authProvider.checkUsernameAvailability(username);

      setState(() {
        _usernameAvailable = available;
        _isCheckingUsername = false;
      });
    }
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
    if (_formKey.currentState!.validate()) {
      if (!_usernameAvailable) {
        Fluttertoast.showToast(
          msg: 'Username already exists. Please choose another.',
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        );
        return;
      }

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        username: _usernameController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        Fluttertoast.showToast(
          msg: 'Registration successful! Please verify OTP sent to your email.',
          backgroundColor: AppColors.success,
          textColor: AppColors.white,
        );

        // Navigate to OTP verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(
          msg: authProvider.errorMessage ?? 'Registration failed',
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
        );
      }
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
                      controller: _usernameController,
                      label: 'Username',
                      hint: 'Choose a username',
                      validator: Validators.validateUsername,
                      onChanged: (value) => _checkUsername(value),
                      prefixIcon: const Icon(Icons.account_circle_outlined,
                          color: AppColors.textSecondary),
                      suffixIcon: _isCheckingUsername
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _usernameController.text.length >= 3
                              ? Icon(
                                  _usernameAvailable
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _usernameAvailable
                                      ? AppColors.success
                                      : AppColors.error,
                                )
                              : null,
                    ),
                    if (!_usernameAvailable &&
                        _usernameController.text.length >= 3)
                      Padding(
                        padding: CustomTheme().padding('warning-text'),
                        child: Text(
                          'Username already exists',
                          style: TextStyle(
                            color: AppColors.error,
                          ),
                        ),
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
                    ),
                  ],
                ),

                // Register Button
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomButton(
                      text: 'Sign Up',
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                    );
                  },
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
