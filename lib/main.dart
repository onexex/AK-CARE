import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'design_system/app_theme.dart';
import 'design_system/app_colors.dart';
import 'core/api.dart';
import 'core/session.dart';
import 'core/theme_controller.dart';
import 'screens/login_screen.dart';
import 'screens/home_dashboard.dart';

/// Lets the app return to sign-in from wherever it is when a token is rejected,
/// without every screen having to know how.
final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Api.onUnauthenticated = () {
    navigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _checkLoginStatus() async {
    try {
      // A stored member with no token is a session from a build that predates
      // authentication. It looks signed in, and every request would 401.
      if (await Session.isSignedIn()) {
        final userData = await Session.user();
        if (userData != null) return HomeDashboard(userData: userData);
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
          navigatorKey: navigatorKey,
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