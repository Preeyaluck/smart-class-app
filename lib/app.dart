import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

class SmartClassApp extends StatefulWidget {
  const SmartClassApp({super.key});

  @override
  State<SmartClassApp> createState() => _SmartClassAppState();
}

class _SmartClassAppState extends State<SmartClassApp> {
  bool _isLoggedIn = AuthService.instance.isLoggedIn;

  void _onLoginSuccess() => setState(() => _isLoggedIn = true);
  void _onLogout() => setState(() => _isLoggedIn = false);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Class Check-in',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      home: _isLoggedIn
          ? MainShell(onLogout: _onLogout)
          : LoginScreen(onLoginSuccess: _onLoginSuccess),
    );
  }
}
