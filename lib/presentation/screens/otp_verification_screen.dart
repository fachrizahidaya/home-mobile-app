import 'package:flutter/material.dart';
import 'package:homesync/core/constants/theme.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'dashboard/member_dashboard_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _canResend = true;
  int _resendCountdown = 60;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    Future.delayed(const Duration(seconds: 1), () {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (_resendCountdown > 0) {
      setState(() => _resendCountdown--);
      Future.delayed(const Duration(seconds: 1), () {
        _updateCountdown();
      });
    } else {
      setState(() => _canResend = true);
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.length != AppConstants.otpLength) {
      Fluttertoast.showToast(
        msg: 'Please enter the complete OTP',
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyOtp(
      email: widget.email,
      otp: _otpController.text,
    );

    if (!mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: 'Verification successful!',
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
      );

      // Navigate to dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const MemberDashboardScreen(),
        ),
        (route) => false,
      );
    } else {
      Fluttertoast.showToast(
        msg: authProvider.errorMessage ?? 'Verification failed',
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
      _otpController.clear();
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.resendOtp(widget.email);

    if (!mounted) return;

    if (success) {
      Fluttertoast.showToast(
        msg: 'OTP sent successfully!',
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
      );
      _startResendCountdown();
    } else {
      Fluttertoast.showToast(
        msg: authProvider.errorMessage ?? 'Failed to resend OTP',
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface,
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.primary, width: 2),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: AppColors.primaryLight.withOpacity(0.1),
        border: Border.all(color: AppColors.primary),
      ),
    );

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: CustomTheme().vGap('2xl'),
            children: [
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.email_outlined,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              // Header
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Column(
                spacing: CustomTheme().vGap('m'),
                children: [
                  Text(
                    'We sent a 6-digit code to',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    widget.email,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              // OTP Input
              Pinput(
                controller: _otpController,
                length: AppConstants.otpLength,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: focusedPinTheme,
                submittedPinTheme: submittedPinTheme,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onCompleted: (pin) => _handleVerifyOtp(),
              ),
              // Verify Button
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    text: 'Verify',
                    onPressed: _handleVerifyOtp,
                    isLoading: authProvider.isLoading,
                  );
                },
              ),
              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: TextStyle(
                      fontSize: CustomTheme().fontSize('l'),
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _canResend ? _handleResendOtp : null,
                    child: Text(
                      _canResend ? 'Resend' : 'Resend in ${_resendCountdown}s',
                      style: TextStyle(
                        fontSize: CustomTheme().fontSize('l'),
                        fontWeight: CustomTheme().fontWeight('semibold'),
                        color:
                            _canResend ? AppColors.primary : AppColors.textHint,
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
  }
}
