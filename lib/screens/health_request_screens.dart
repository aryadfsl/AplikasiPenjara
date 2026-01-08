import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/request.dart';
import '../service/firebase_service.dart';
import '../service/auth_service.dart';

class HealthRequestManagementController {
  final searchController = TextEditingController();
  final adminNoteController = TextEditingController();

  String selectedStatus = 'pending';
  List<RequestModel> filteredRequests = [];
  List<RequestModel> allRequests = [];
  bool isLoading = true;

  Future<void> loadRequests(BuildContext context) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final allRequestsFromDb = await firebaseService.getRequests();

      // Filter hanya pengajuan kesehatan
      allRequests = allRequestsFromDb
          .where((r) => r.type == 'kesehatan')
          .toList();
      filteredRequests = allRequests
          .where((r) => r.status == 'pending')
          .toList();
      isLoading = false;
    } catch (e) {
      isLoading = false;
      print('Error loading health requests: $e');
    }
  }

  void filterRequests() {
    List<RequestModel> filtered = allRequests;

    if (selectedStatus != 'semua') {
      filtered = filtered.where((r) => r.status == selectedStatus).toList();
    }

    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      filtered = filtered
          .where(
            (r) =>
                r.title.toLowerCase().contains(query) ||
                r.description.toLowerCase().contains(query) ||
                r.userName.toLowerCase().contains(query),
          )
          .toList();
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
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final authService = Provider.of<AuthService>(context, listen: false);
      final healthStaffName =
          authService.currentUser?.fullName ?? 'Petugas Kesehatan';

      await firebaseService.updateRequestStatus(
        requestId,
        newStatus,
        healthStaffName,
        adminNote: adminNote,
      );
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
      case 'kesehatan':
        return 'Kesehatan';
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
