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
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  String? get currentUserName {
    return null; // Will be provided from context
  }
}
