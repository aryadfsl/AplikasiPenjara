import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/complaint.dart';
import '../service/auth_service.dart';
import '../service/firebase_service.dart';

class UserComplaintScreenController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  
  final List<String> categories = ['air', 'listrik', 'sanitasi', 'makanan', 'kamar', 'lainnya'];
  final List<Map<String, String>> priorities = [
    {'value': 'rendah', 'label': 'Rendah'},
    {'value': 'sedang', 'label': 'Sedang'},
    {'value': 'tinggi', 'label': 'Tinggi'},
    {'value': 'darurat', 'label': 'Darurat'},
  ];
  
  String selectedCategory = 'air';
  String selectedPriority = 'sedang';
  bool isSubmitting = false;
  List<Complaint> userComplaints = [];
  bool isLoading = true;

  Future<void> loadUserComplaints(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final user = authService.currentUser!;

      userComplaints = await firebaseService.getUserComplaints(user.id);
      isLoading = false;
    } catch (e) {
      isLoading = false;
      print('Error loading complaints: $e');
    }
  }

  Future<void> submitComplaint(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    try {
      isSubmitting = true;
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final user = authService.currentUser!;

      final newComplaint = Complaint(
        id: '',
        title: titleController.text,
        description: descriptionController.text,
        category: selectedCategory,
        priority: selectedPriority,
        status: 'pending',
        userId: user.id,
        userName: user.fullName,
        date: DateTime.now(),
      );

      await firebaseService.addComplaint(newComplaint);
      await loadUserComplaints(context);
      
      resetForm();
      isSubmitting = false;
    } catch (e) {
      isSubmitting = false;
      print('Error submitting complaint: $e');
      rethrow;
    }
  }

  void resetForm() {
    titleController.clear();
    descriptionController.clear();
    selectedCategory = 'air';
    selectedPriority = 'sedang';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Diproses';
      case 'resolved':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'rendah':
        return Colors.green;
      case 'sedang':
        return Colors.orange;
      case 'tinggi':
        return Colors.red;
      case 'darurat':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String getCategoryEmoji(String category) {
    switch (category) {
      case 'air':
        return '💧';
      case 'listrik':
        return '⚡';
      case 'sanitasi':
        return '🧹';
      case 'makanan':
        return '🍽️';
      case 'kamar':
        return '🚪';
      case 'lainnya':
        return '❓';
      default:
        return '📌';
    }
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}
