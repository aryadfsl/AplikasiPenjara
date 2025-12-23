import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import '../page/dashboard_admin_page.dart';
import '../page/dahsboard_user_page.dart';

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

  Future<void> loginAndNavigate(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.login(
      emailController.text,
      passwordController.text,
      context,
    );

    if (!success) return;
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.blueGrey[800],
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Login berhasil'),
            ],
          ),
        ),
      );

    await Future.delayed(const Duration(seconds: 2));
    if (!context.mounted) return;

    if (authService.currentUser?.role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserDashboard()),
      );
    }
  }

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
