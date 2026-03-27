import 'package:flutter/material.dart';
import 'package:homesync/core/constants/theme.dart';
import 'package:homesync/main.dart';
import 'package:homesync/presentation/screens/login/index.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';

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
  int _resendCountdown = 90;
  bool _isVerifying = false;
  bool _isResending = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 90;
    });

    _updateCountdown();
  }

  void _updateCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _updateCountdown();
      } else {
        setState(() {
          _canResend = true;
        });
      }
    });
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

    if (_isVerifying) return;

    setState(() => _isVerifying = true);

    final response = await authService.verifyOtp(
      email: widget.email,
      otp: _otpController.text,
    );

    if (!mounted) return;

    setState(() => _isVerifying = false);

    if (response.success) {
      await storage.saveToken(response.data!['access_token']);

      Fluttertoast.showToast(
        msg: 'Verification successful!',
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      Fluttertoast.showToast(
        msg: response.message,
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );

      _otpController.clear();
    }
  }

  Future<void> _handleResendOtp() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);

    final response = await authService.resendOtp(
      email: widget.email,
    );

    if (!mounted) return;

    setState(() => _isResending = false);

    if (response.success) {
      Fluttertoast.showToast(
        msg: 'OTP sent successfully!',
        backgroundColor: AppColors.success,
        textColor: AppColors.white,
      );

      _startResendCountdown();
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
          onPressed: () => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          ),
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
              // CustomButton(
              //   text: 'Verify',
              //   onPressed: _handleVerifyOtp,
              //   isLoading: _isVerifying,
              // ),
              Column(
                children: [
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
                    ],
                  ),
                  SizedBox(height: 8),
                  CustomButton(
                    text: _canResend
                        ? 'Resend OTP'
                        : 'Resend in ${_resendCountdown}s',
                    onPressed: _handleResendOtp,
                    isLoading: _isResending,
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
