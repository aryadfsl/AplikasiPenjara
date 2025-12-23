import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../service/firebase_service.dart';

class AdminInmateManagementController {
  final formKey = GlobalKey<FormState>();
  final searchController = TextEditingController();
  final fullNameController = TextEditingController();
  final inmateIdController = TextEditingController();
  final blockController = TextEditingController();
  final cellController = TextEditingController();
  final crimeController = TextEditingController();
  final sentenceStartDateController = TextEditingController();
  final sentenceEndDateController = TextEditingController();
  
  DateTime? sentenceStartDate;
  DateTime? sentenceEndDate;
  String selectedStatus = 'aktif';
  
  List<UserModel> filteredUsers = [];
  List<UserModel> allUsers = [];
  bool isLoading = true;

  Future<void> loadUsers(BuildContext context) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      allUsers = await firebaseService.getUsers();
      filteredUsers = allUsers;
      isLoading = false;
    } catch (e) {
      isLoading = false;
      print('Error loading users: $e');
    }
  }

  void searchUsers(String query) {
    if (query.isEmpty) {
      filteredUsers = allUsers;
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    filteredUsers = allUsers.where((user) =>
        user.fullName.toLowerCase().contains(lowercaseQuery) ||
        user.inmateId.toLowerCase().contains(lowercaseQuery) ||
        user.block.toLowerCase().contains(lowercaseQuery) ||
        user.cell.toLowerCase().contains(lowercaseQuery) ||
        user.crime.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  void resetForm() {
    fullNameController.clear();
    inmateIdController.clear();
    blockController.clear();
    cellController.clear();
    crimeController.clear();
    sentenceStartDateController.clear();
    sentenceEndDateController.clear();
    sentenceStartDate = null;
    sentenceEndDate = null;
    selectedStatus = 'aktif';
  }

  Future<void> addInmate(BuildContext context) async {
    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);

      // Generate inmate ID based on block and cell
      final generatedInmateId = await _generateInmateId(firebaseService, blockController.text, cellController.text);

      final newInmate = UserModel(
        id: '',
        email: 'inmate_${DateTime.now().millisecondsSinceEpoch}@penjara.local',
        fullName: fullNameController.text,
        role: 'user',
        block: blockController.text,
        cell: cellController.text,
        inmateId: generatedInmateId,
        crime: crimeController.text,
        sentenceStart: sentenceStartDate!,
        sentenceEnd: sentenceEndDate!,
        status: selectedStatus,
        registrationDate: DateTime.now(),
      );

      await firebaseService.addUser(newInmate);
      await loadUsers(context);
    } catch (e) {
      print('Error adding inmate: $e');
      rethrow;
    }
  }

  Future<String> _generateInmateId(FirebaseService firebaseService, String block, String cell) async {
    final users = await firebaseService.getUsers();

    // Filter users with the same block and cell
    final sameBlockCellUsers = users.where((user) =>
        user.block.toUpperCase() == block.toUpperCase() &&
        user.cell == cell
    ).toList();

    // Find the highest number for this block-cell combination
    int maxNumber = 0;
    for (final user in sameBlockCellUsers) {
      // Extract number from inmateId like "A12-001" -> 1
      final parts = user.inmateId.split('-');
      if (parts.length == 2) {
        final numberPart = parts[1];
        final number = int.tryParse(numberPart);
        if (number != null && number > maxNumber) {
          maxNumber = number;
        }
      }
    }

    // Generate new ID: Block + Cell + "-" + (maxNumber + 1)
    final nextNumber = (maxNumber + 1).toString().padLeft(3, '0');
    return '${block.toUpperCase()}$cell-$nextNumber';
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String calculateRemainingTime(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.inDays < 0) {
      return 'Sudah selesai';
    }
    
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    final days = (difference.inDays % 365) % 30;
    
    List<String> parts = [];
    if (years > 0) parts.add('$years tahun');
    if (months > 0) parts.add('$months bulan');
    if (days > 0) parts.add('$days hari');
    
    return parts.isEmpty ? 'Kurang dari 1 hari' : parts.join(' ');
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'aktif':
        return Colors.orange;
      case 'transfer':
        return Colors.blue;
      case 'bebas':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void dispose() {
    searchController.dispose();
    fullNameController.dispose();
    inmateIdController.dispose();
    blockController.dispose();
    cellController.dispose();
    crimeController.dispose();
    sentenceStartDateController.dispose();
    sentenceEndDateController.dispose();
  }
}
