import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  // STEP 1: Request OTP from PHP
  Future<void> _requestOtp() async {
  if (_phoneController.text.isEmpty) {
    _showError("Please enter your phone number");
    return;
  }

  setState(() => _isLoading = true);
  
  try {
    // dev.log("Sending request to: ${AppConfig.checkUserUrl}", name: "NETWORK");
    // dev.log("Payload: {'phone_number': ${_phoneController.text}}", name: "NETWORK");

    final response = await http.post(
      Uri.parse(AppConfig.checkUserUrl),
      body: {'phone_number': _phoneController.text},
    ).timeout(const Duration(seconds: 4)); // Nag-add tayo ng timeout



    if (!mounted) return;

    final data = json.decode(response.body);
    dev.log("Decoded Response: $data", name: "SERVER_RESPONSE");

    if (data['status'] == 'success') {
      setState(() => _isOtpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP Sent: ${data['otp']}"), backgroundColor: Colors.green),
      );
    } else {
      _showError(data['message']);
    }
  } catch (e, stacktrace) {
    dev.log("Connection Error!", name: "ERROR", error: e, stackTrace: stacktrace);
    
    if (!mounted) return;
    _showError("Connection failed. Check your Debug Console for logs.");
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  // STEP 2: Verify OTP via PHP
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

      // Proteksyon laban sa async gaps
      if (!mounted) return;

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        // SUCCESS: Lilipat na sa Home Dashboard bitbit ang user data
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
      _showError("Verification failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( 
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- LOGO SECTION ---
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.account_circle, size: 120, color: Colors.blueGrey);
                  },
                ),
                
                const SizedBox(height: 20),
               const Text(
                  "AK CARE",
                  style: TextStyle(
                    fontSize: 32, 
                    fontWeight: FontWeight.bold, 
                    color: Color.fromARGB(255, 18, 160, 6),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isOtpSent ? "Verification" : "Welcome Back",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 40),

                // --- INPUT FIELDS ---
                if (!_isOtpSent)
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      hintText: "09XXXXXXXXX",
                      prefixIcon: const Icon(Icons.phone_android),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  )
                else
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, letterSpacing: 10, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: "OTP Code",
                      counterText: "",
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),

                const SizedBox(height: 25),

                // --- ACTION BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _requestOtp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                    child: _isLoading 
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isOtpSent ? "VERIFY & LOGIN" : "SEND OTP", 
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                  ),
                ),
                
                const SizedBox(height: 15),

                // --- FOOTER BUTTONS ---
                if (_isOtpSent)
                  TextButton(
                    onPressed: () => setState(() => _isOtpSent = false),
                    child: const Text("Edit Phone Number", style: TextStyle(color: Colors.blue)),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text("Don't have an account? Contact Admin", style: TextStyle(color: Colors.grey)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}