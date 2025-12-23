import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';

class UserDashboardController {
  int selectedIndex = 0;
  late List<Widget> screens;

  UserDashboardController(List<Widget> screenWidgets) {
    screens = screenWidgets;
  }

  void onItemTapped(int index) {
    selectedIndex = index;
  }

  Future<void> logout(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.logout();
    if (context.mounted) {
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
                Text('Logout berhasil'),
              ],
            ),
          ),
        );

      await Future.delayed(const Duration(seconds: 2));
      if (!context.mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  String? get currentUserName {
    return null; // Will be provided from context
  }
}
