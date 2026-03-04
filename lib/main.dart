import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // I-import mo yung file dito

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AK CARE',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Eto ang magsasabi na Login Screen ang unang bubukas
      home: const LoginScreen(), 
    );
  }
}