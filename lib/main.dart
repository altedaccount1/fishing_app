// main.dart
import 'package:flutter/material.dart';

import 'services/data_service.dart';
import 'services/auth_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_page.dart';
import 'utils/theme.dart';

void main() {
  // Initialize services
  DataService.initialize();
  AuthService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ASAC Fishing',
      theme: AppTheme.lightTheme,
      home: AuthService.isSignedIn ? const MainPage() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
