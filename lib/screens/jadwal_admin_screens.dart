import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/schedule.dart';
import '../models/user.dart';
import '../service/firebase_service.dart';

class AdminScheduleManagementController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final instructorController = TextEditingController();
  final startTimeController = TextEditingController();
  final endTimeController = TextEditingController();
  
  DateTime? selectedDate;
  String selectedType = 'kerja';
  bool isMandatory = true;
  final List<String> selectedParticipants = [];
  final List<String> types = ['kerja', 'olahraga', 'pendidikan', 'ibadah', 'makan', 'istirahat'];
  
  List<Schedule> schedules = [];
  List<UserModel> inmates = [];
  bool isLoading = true;

  Future<void> loadData(BuildContext context) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      schedules = await firebaseService.getSchedules();
      inmates = await firebaseService.getUsers();
      isLoading = false;
    } catch (e) {
      isLoading = false;
      print('Error loading data: $e');
    }
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    instructorController.clear();
    startTimeController.clear();
    endTimeController.clear();
    selectedDate = DateTime.now();
    selectedType = 'kerja';
    isMandatory = true;
    selectedParticipants.clear();
  }

  Future<void> addSchedule(BuildContext context) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      
      final newSchedule = Schedule(
        id: '',
        title: titleController.text,
        description: descriptionController.text,
        date: selectedDate!,
        startTime: startTimeController.text,
        endTime: endTimeController.text,
        location: locationController.text,
        type: selectedType,
        instructor: instructorController.text,
        participants: selectedParticipants,
        isMandatory: isMandatory,
      );

      await firebaseService.addSchedule(newSchedule);
      await loadData(context);
    } catch (e) {
      print('Error adding schedule: $e');
      rethrow;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String getTypeIcon(String type) {
    switch (type) {
      case 'kerja':
        return '🏭';
      case 'olahraga':
        return '⚽';
      case 'pendidikan':
        return '📚';
      case 'ibadah':
        return '🙏';
      case 'makan':
        return '🍽️';
      case 'istirahat':
        return '😴';
      default:
        return '📌';
    }
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    instructorController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
  }
}
