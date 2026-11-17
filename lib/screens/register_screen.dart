import 'package:flutter/material.dart';

import 'package:brainsnack/screens/login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  Widget build(BuildContext context) {
    return const LoginScreen(initialRegisterMode: true);
  }
}
