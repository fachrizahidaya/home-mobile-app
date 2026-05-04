import 'package:flutter/material.dart';
import 'package:homesync/providers/auth_provider.dart';
import 'package:homesync/ui/core/constants/theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../../ui/core/constants/app_colors.dart';
import '../../../utils/utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../register/index.dart';
import '../verify/index.dart';
import '../dashboard/index.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!_formKey.currentState!.validate()) return;

    final result = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result.success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MemberDashboardScreen(),
        ),
      );
    } else if (result.needsVerification == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            email: result.email ?? _emailController.text.trim(),
          ),
        ),
      );
    } else {
      Fluttertoast.showToast(
        msg: result.message ?? authProvider.errorMessage ?? 'Login failed',
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CustomTheme().padding(''),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Column(
                    spacing: CustomTheme().vGap('3xl'),
                    children: [
                      Column(
                        spacing: CustomTheme().vGap('2xl'),
                        children: [
                          Column(
                            spacing: CustomTheme().vGap('m'),
                            children: [
                              Text(
                                'HomeSync',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Manage your home efficiently',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: CustomTheme().vGap('2xl'),
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: CustomTheme().vGap('m'),
                            children: [
                              const Text(
                                'Welcome Back',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Sign in to continue',
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
                                validator: (value) =>
                                    Validators.validateRequired(
                                        value, 'Password'),
                                prefixIcon: const Icon(Icons.lock_outlined,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          CustomButton(
                            text: 'Sign In',
                            onPressed: _handleLogin,
                            isLoading: isLoading,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: TextStyle(
                                  fontSize: CustomTheme().fontSize('l'),
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: CustomTheme().fontSize('l'),
                                    fontWeight:
                                        CustomTheme().fontWeight('semibold'),
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
