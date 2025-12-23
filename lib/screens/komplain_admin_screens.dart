import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/complaint.dart';
import '../service/auth_service.dart';
import '../service/firebase_service.dart';

class AdminComplaintManagementController {
  final searchController = TextEditingController();
  final actionTakenController = TextEditingController();
  final resolutionNoteController = TextEditingController();
  
  String selectedStatus = 'semua';
  List<Complaint> filteredComplaints = [];
  List<Complaint> allComplaints = [];
  bool isLoading = true;

  Future<void> loadComplaints(BuildContext context) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      allComplaints = await firebaseService.getComplaints();
      filteredComplaints = allComplaints;
      isLoading = false;
    } catch (e) {
      isLoading = false;
      print('Error loading complaints: $e');
    }
  }

  void filterComplaints() {
    List<Complaint> filtered = allComplaints;

    if (selectedStatus != 'semua') {
      filtered = filtered.where((c) => c.status == selectedStatus).toList();
    }

    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      filtered = filtered.where((c) =>
          c.title.toLowerCase().contains(query) ||
          c.description.toLowerCase().contains(query) ||
          c.userName.toLowerCase().contains(query) ||
          c.category.toLowerCase().contains(query)
      ).toList();
    }

    filteredComplaints = filtered;
  }

  Future<void> updateComplaintStatus(
    BuildContext context,
    String complaintId,
    String newStatus,
  ) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final adminName = authService.currentUser?.fullName ?? 'Admin';
      
      await firebaseService.updateComplaintStatus(complaintId, newStatus, adminName);
      await loadComplaints(context);
    } catch (e) {
      print('Error updating complaint: $e');
      rethrow;
    }
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

  void dispose() {
    searchController.dispose();
    actionTakenController.dispose();
    resolutionNoteController.dispose();
  }
}
