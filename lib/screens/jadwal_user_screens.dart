import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../service/auth_service.dart';
import '../service/firebase_service.dart';

class UserScheduleScreenController {
  List<Schedule> userSchedules = [];
  bool isLoading = true;

  Future<void> loadUserSchedules(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final user = authService.currentUser!;

      userSchedules = await firebaseService.getUserSchedules(user.id);
      isLoading = false;
    } catch (e) {
      isLoading = false;
      print('Error loading schedules: $e');
    }
  }

  Color getScheduleColor(String type) {
    switch (type) {
      case 'kerja':
        return Colors.blue;
      case 'olahraga':
        return Colors.green;
      case 'pendidikan':
        return Colors.purple;
      case 'ibadah':
        return Colors.orange;
      case 'makan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData getScheduleIcon(String type) {
    switch (type) {
      case 'kerja':
        return Icons.work;
      case 'olahraga':
        return Icons.sports;
      case 'pendidikan':
        return Icons.school;
      case 'ibadah':
        return Icons.person_pin;
      case 'makan':
        return Icons.restaurant;
      case 'istirahat':
        return Icons.bedtime;
      default:
        return Icons.event;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
