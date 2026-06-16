import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'dart:convert';
import 'design_system/app_theme.dart';
import 'design_system/app_colors.dart';
import 'design_system/app_typography.dart';
import 'core/theme_controller.dart';
import 'screens/login_screen.dart';
import 'screens/home_dashboard.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('user_session');
      if (userJson != null) {
        final Map<String, dynamic> userData = json.decode(userJson);
        return HomeDashboard(userData: userData);
      }
    } catch (e) {
      debugPrint('Error reading session: $e');
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AK CARE',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          home: FutureBuilder<Widget>(
            future: _checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                FlutterNativeSplash.remove();
                if (snapshot.hasData) return snapshot.data!;
                return const LoginScreen();
              }
              return const _AppLoadingScreen();
            },
          ),
        );
      },
    );
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(image: AssetImage('assets/logo.png'), height: 80),
            SizedBox(height: 24),
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}