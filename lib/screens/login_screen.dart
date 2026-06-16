import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../core/config.dart';
import '../design_system/theme_colors.dart';
import '../design_system/app_radius.dart';
import '../design_system/app_spacing.dart';
import '../design_system/app_typography.dart';
import '../design_system/app_elevation.dart';
import '../design_system/app_theme.dart';
import '../widgets/app_button.dart';
import 'home_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(4, (_) => FocusNode());
  bool _isOtpSent = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _combinedOtp => _otpControllers.map((c) => c.text).join();

  void _showError(String msg) {
    if (!mounted) return;
    final tc = ThemeColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: tc.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    final tc = ThemeColors.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: tc.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _requestOtp() async {
    setState(() => _error = null);
    if (_phoneController.text.trim().isEmpty) {
      setState(() => _error = 'Please enter your phone number');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(AppConfig.checkUserUrl),
        body: {'phone_number': _phoneController.text.trim()},
      ).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        setState(() => _isOtpSent = true);
        _otpFocusNodes[0].requestFocus();
        _showSuccess('Verification code sent to your device');
      } else {
        setState(() => _error = data['message'] ?? 'Phone number not found');
      }
    } catch (_) {
      if (!mounted) return;
      setState(
          () => _error = 'Unable to connect. Check your internet and try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    setState(() => _error = null);
    if (_combinedOtp.length < 4) {
      setState(() => _error = 'Please enter the complete 4-digit code');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(AppConfig.verifyOtpUrl),
        body: {
          'phone_number': _phoneController.text.trim(),
          'otp_code': _combinedOtp,
        },
      );
      if (!mounted) return;
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        final prefs = await SharedPreferences.getInstance();
        if (data['user'] != null) {
          await prefs.setString('user_session', json.encode(data['user']));
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => HomeDashboard(userData: data['user'])),
        );
      } else {
        setState(() => _error = data['message'] ?? 'Invalid verification code');
        for (final c in _otpControllers) {
          c.clear();
        }
        _otpFocusNodes[0].requestFocus();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tc = ThemeColors.of(context);
    return Scaffold(
      backgroundColor: tc.scaffoldBg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    const SizedBox(height: AppSpacing.huge),
                    _buildLogo(tc),
                    const SizedBox(height: AppSpacing.huge),
                    _isOtpSent ? _buildOtpCard(tc) : _buildPhoneCard(tc),
                    const SizedBox(height: AppSpacing.xxl),
                    if (_isOtpSent) _buildEditPhoneLink(tc),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ThemeColors tc) {
    return Column(
      children: [
        Image.asset('assets/loginlogo.png', height: 90),
        const SizedBox(height: AppSpacing.xxl),
        Text('AK MIYEMBRO',
            style: AppTypography.displayLarge.copyWith(color: tc.deepTeal)),
        const SizedBox(height: AppSpacing.xs),
        Text('HEALTHCARE & PERKS',
            style: AppTypography.labelMedium.copyWith(
                color: tc.neutral60, letterSpacing: 4)),
      ],
    );
  }

  Widget _buildPhoneCard(ThemeColors tc) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppElevation.medium,
      ),
      child: Column(
        children: [
          Text('Welcome Back',
              style: AppTypography.headlineMedium.copyWith(color: tc.neutral100)),
          const SizedBox(height: AppSpacing.sm),
          Text('Sign in to manage your health benefits',
              style: AppTypography.bodyMedium.copyWith(color: tc.neutral60),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xxxl),
          _buildPhoneField(tc),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.error_outline, size: 16, color: tc.error),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(_error!,
                        style: AppTypography.caption.copyWith(color: tc.error))),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: 'GET VERIFICATION CODE',
            onPressed: _isLoading ? null : _requestOtp,
            icon: Icons.arrow_forward_rounded,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField(ThemeColors tc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Phone Number',
            style: AppTypography.labelMedium.copyWith(color: tc.neutral80)),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() => _error = null),
          style: AppTypography.bodyLarge.copyWith(color: tc.neutral100),
          decoration: InputDecoration(
            hintText: '09XXXXXXXXX',
            prefixIcon: const Icon(Icons.phone_android_rounded, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpCard(ThemeColors tc) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: tc.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        boxShadow: AppElevation.medium,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: tc.primarySurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(Icons.shield_moon_outlined, color: tc.primary, size: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Verify Your Identity',
              style: AppTypography.headlineMedium.copyWith(color: tc.neutral100)),
          const SizedBox(height: AppSpacing.sm),
          Text('We sent a 4-digit code to your device',
              style: AppTypography.bodyMedium.copyWith(color: tc.neutral60),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xxxl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (i) {
              return Container(
                width: 60,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _otpControllers[i],
                  focusNode: _otpFocusNodes[i],
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineMedium.copyWith(
                      color: tc.neutral100, letterSpacing: 0),
                  decoration: InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        borderSide: BorderSide(color: tc.primary, width: 2)),
                  ),
                  onChanged: (v) {
                    if (v.isNotEmpty && i < 3) {
                      _otpFocusNodes[i + 1].requestFocus();
                    }
                    if (v.isEmpty && i > 0) {
                      _otpFocusNodes[i - 1].requestFocus();
                    }
                    if (_combinedOtp.length == 4) {
                      FocusScope.of(context).unfocus();
                    }
                    setState(() => _error = null);
                  },
                ),
              );
            }),
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 16, color: tc.error),
                const SizedBox(width: 6),
                Text(_error!, style: AppTypography.caption.copyWith(color: tc.error)),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xxxl),
          AppButton(
            label: 'CONFIRM & LOGIN',
            onPressed: _isLoading ? null : _verifyOtp,
            icon: Icons.lock_open_rounded,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildEditPhoneLink(ThemeColors tc) {
    return TextButton.icon(
      onPressed: () => setState(() {
        _isOtpSent = false;
        for (final c in _otpControllers) c.clear();
        _error = null;
      }),
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: const Text('Edit Phone Number'),
      style: TextButton.styleFrom(foregroundColor: tc.neutral70),
    );
  }
}