import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';

class LoginController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  bool obscurePassword = true;
  final formKey = GlobalKey<FormState>();

  Future<bool> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return false;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      emailController.text,
      passwordController.text,
      context,
    );

    return success;
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
