import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';  
import 'dart:convert'; 
import '../core/config.dart';
import 'dart:developer' as dev;  
import 'home_dashboard.dart';  

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;

  // Branding Colors
  final Color primaryGreen = const Color(0xFF12A006); 
  final Color deepTeal = const Color(0xFF004D40);
  final Color bgLight = const Color(0xFFF0F7F0);

  // --- STEP 1: Request OTP ---
  Future<void> _requestOtp() async {
    if (_phoneController.text.isEmpty) {
      _showError("Please enter your phone number");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.checkUserUrl),
        body: {'phone_number': _phoneController.text},
      ).timeout(const Duration(seconds: 4));

      if (!mounted) return;

      final data = json.decode(response.body);
      dev.log("Server Response: $data", name: "AUTH");

      if (data['status'] == 'success') {
        setState(() => _isOtpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP Sent: ${data['otp']}"), 
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      if (!mounted) return;
      
      _showError("Connection failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- STEP 2: Verify OTP & Save Session ---
  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) {
      _showError("Please enter the 6-digit code");
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse(AppConfig.verifyOtpUrl),
        body: {
          'phone_number': _phoneController.text,
          'otp_code': _otpController.text,
        },
      );

      if (!mounted) return;

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // I-save ang user object para sa auto-login
        if (data['user'] != null) {
          await prefs.setString('user_session', json.encode(data['user']));
        }

        if (!mounted) return;

        // Lipat sa Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeDashboard(userData: data['user']),
          ),
        );
      } else {
        _showError(data['message']);
      }
    } catch (e) {
      if (!mounted) return;
      _showError("Verification failed.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg), 
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Layer
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgLight, Colors.white],
              ),
            ),
          ),

          // 2. Floating Health Background Icons
          _buildFloatingIcon(Icons.medical_information_outlined, top: 80, left: -20, size: 100),
          _buildFloatingIcon(Icons.history_edu_rounded, top: 220, right: -30, size: 120),
          _buildFloatingIcon(Icons.health_and_safety_outlined, bottom: 150, left: -30, size: 140),
          _buildFloatingIcon(Icons.medication_rounded, bottom: 50, right: 20, size: 80),
          _buildFloatingIcon(Icons.volunteer_activism_rounded, top: 400, left: 30, size: 70),

          // 3. Main UI Layer
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // --- LOGO SECTION ---
                    _buildLogoHeader(),
                    
                    const SizedBox(height: 40),

                    // --- LOGIN CARD ---
                    _buildLoginCard(),

                    const SizedBox(height: 30),

                    // --- FOOTER ---
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildFloatingIcon(IconData icon, {double? top, double? bottom, double? left, double? right, double size = 100}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Opacity(
        opacity: 0.05,
        child: Icon(icon, size: size, color: primaryGreen),
      ),
    );
  }

  Widget _buildLogoHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            // Tinanggal na natin ang boxShadow dito
          ),
          child: Image.asset('assets/loginlogo.png', height: 100),
        ),
        const SizedBox(height: 20),
        Text(
          "AK CARE",
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: deepTeal,
            letterSpacing: 2,
          ),
        ),
        Text(
          "HEALTHCARE & PERKS",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            _isOtpSent ? "Verify OTP" : "Welcome Back",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _isOtpSent 
              ? "We've sent a code to your phone" 
              : "Sign in to manage your health benefits",
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 35),

          if (!_isOtpSent)
            _buildTextField(
              controller: _phoneController,
              label: "Phone Number",
              hint: "09XXXXXXXXX",
              icon: Icons.phone_android_rounded,
              type: TextInputType.phone,
            )
          else
            _buildTextField(
              controller: _otpController,
              label: "Enter 6-digit Code",
              hint: "0 0 0 0 0 0",
              icon: Icons.shield_moon_outlined,
              type: TextInputType.number,
              isOtp: true,
            ),

          const SizedBox(height: 30),

          // ACTION BUTTON
          Container(
            width: double.infinity,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [primaryGreen, const Color(0xFF0D7A04)],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _requestOtp),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _isOtpSent ? "CONFIRM & LOGIN" : "GET OTP CODE",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required TextInputType type,
    bool isOtp = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLength: isOtp ? 6 : null,
          textAlign: isOtp ? TextAlign.center : TextAlign.start,
          style: TextStyle(
            fontSize: isOtp ? 26 : 16,
            letterSpacing: isOtp ? 12 : 0,
            fontWeight: isOtp ? FontWeight.w900 : FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(letterSpacing: 0, color: Colors.grey[300], fontSize: 14),
            prefixIcon: Icon(icon, color: primaryGreen),
            filled: true,
            fillColor: bgLight.withOpacity(0.3),
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: primaryGreen, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    if (_isOtpSent) {
      return TextButton.icon(
        onPressed: () => setState(() => _isOtpSent = false),
        icon: const Icon(Icons.arrow_back),
        label: const Text("Edit Phone Number"),
        style: TextButton.styleFrom(foregroundColor: primaryGreen),
      );
    }
    return Column(
      children: [
        // const Text("Don't have an account?", style: TextStyle(color: Colors.grey, fontSize: 13)),
        // TextButton(
        //   onPressed: () {},
        //   child: Text("Contact Administrator", style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold)),
        // ),
      ],
    );
  }
}