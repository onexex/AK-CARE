import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // 1. Import ito
import 'dart:convert';
import 'screens/login_screen.dart';
import 'screens/home_dashboard.dart';

void main() async {
  // 2. Napaka-importante nito para sa Native Splash
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // 3. Panatilihin ang Native Splash (para hindi agad mawala ang logo)
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _checkLoginStatus() async {
    // Hindi na natin kailangan ang 3 seconds delay dahil Native Splash na ang gamit
    // Mas mabilis ma-load, mas masaya ang user.
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userJson = prefs.getString('user_session');

      if (userJson != null) {
        Map<String, dynamic> userData = json.decode(userJson);
        return HomeDashboard(userData: userData);
      }
    } catch (e) {
      debugPrint("Error reading session: $e");
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AK CARE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 36, 154, 25)),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          // Kapag may data na (ito yung moment na tapos na ang check)
          if (snapshot.connectionState == ConnectionState.done) {
            // 4. ALISIN NA ANG NATIVE SPLASH
            FlutterNativeSplash.remove();
            
            if (snapshot.hasData) {
              return snapshot.data!;
            }
            return const LoginScreen();
          }

          // Habang 'waiting', empty screen lang. 
          // Hindi ito makikita ng user dahil nakapatong pa ang Native Splash Logo.
          return const Scaffold(backgroundColor: Colors.white);
        },
      ),
    );
  }
}