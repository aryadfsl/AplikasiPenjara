import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/request.dart';
import '../service/firebase_service.dart';
import '../service/auth_service.dart';

class AdminRequestManagementController {
  final searchController = TextEditingController();
  final adminNoteController = TextEditingController();
  
  String selectedStatus = 'pending';
  List<RequestModel> filteredRequests = [];
  List<RequestModel> allRequests = [];
  bool isLoading = true;

  Future<void> loadRequests(BuildContext context) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      allRequests = await firebaseService.getRequests();
      filteredRequests = allRequests.where((r) => r.status == 'pending').toList();
      isLoading = false;
    } catch (e) {
      isLoading = false;
      print('Error loading requests: $e');
    }
  }

  void filterRequests() {
    List<RequestModel> filtered = allRequests;

    if (selectedStatus != 'semua') {
      filtered = filtered.where((r) => r.status == selectedStatus).toList();
    }

    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      filtered = filtered.where((r) =>
          r.title.toLowerCase().contains(query) ||
          r.description.toLowerCase().contains(query) ||
          r.userName.toLowerCase().contains(query) ||
          r.type.toLowerCase().contains(query)).toList();
    }

    filteredRequests = filtered;
  }

  Future<void> updateRequestStatus(
    BuildContext context,
    String requestId,
    String newStatus,
    String adminNote,
  ) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final adminName = authService.currentUser?.fullName ?? 'Admin';
      
      await firebaseService.updateRequestStatus(requestId, newStatus, adminName);
      await loadRequests(context);
    } catch (e) {
      print('Error updating request: $e');
      rethrow;
    }
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String getTypeLabel(String type) {
    switch (type) {
      case 'cuti':
        return 'Cuti';
      case 'kesehatan':
        return 'Kesehatan';
      case 'keluarga':
        return 'Kunjungan Keluarga';
      case 'lainnya':
        return 'Lainnya';
      default:
        return type;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
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
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  void dispose() {
    searchController.dispose();
    adminNoteController.dispose();
  }
}
