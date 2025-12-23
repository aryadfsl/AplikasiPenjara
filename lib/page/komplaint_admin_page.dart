import 'package:flutter/material.dart';
import '../models/complaint.dart';
import '../screens/komplain_admin_screens.dart';

class AdminComplaintManagement extends StatefulWidget {
  const AdminComplaintManagement({super.key});

  @override
  State<AdminComplaintManagement> createState() => _AdminComplaintManagementState();
}

class _AdminComplaintManagementState extends State<AdminComplaintManagement> {
  late AdminComplaintManagementController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AdminComplaintManagementController();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadComplaints(context);
    if (mounted) {
      setState(() {
        _isLoading = _controller.isLoading;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showComplaintDetails(Complaint complaint) {
    _controller.actionTakenController.text = complaint.actionTaken ?? '';
    _controller.resolutionNoteController.text = complaint.resolutionNote ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(complaint.title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailItem('Dari', complaint.userName),
                  _buildDetailItem('Kategori', _getCategoryLabel(complaint.category)),
                  _buildDetailItem('Prioritas', complaint.priority),
                  _buildDetailItem('Status', complaint.status),
                  _buildDetailItem('Tanggal', _controller.formatDate(complaint.date)),
                  const SizedBox(height: 12),
                  const Text(
                    'Deskripsi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(complaint.description),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller.actionTakenController,
                    decoration: const InputDecoration(
                      labelText: 'Tindakan yang diambil',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _controller.resolutionNoteController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan (opsional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              if (complaint.status == 'pending' || complaint.status == 'diproses')
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _controller.updateComplaintStatus(
                        context,
                        complaint.id,
                        'resolved',
                      );
                      setState(() {});
                      Navigator.pop(context);
                      _showSnackBar(context, 'Keluhan berhasil diupdate', Colors.green);
                    } catch (e) {
                      _showSnackBar(context, 'Gagal mengupdate keluhan: $e', Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Selesai'),
                ),
            ],
          );
        },
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'air':
        return 'Air';
      case 'listrik':
        return 'Listrik';
      case 'sanitasi':
        return 'Sanitasi';
      case 'makanan':
        return 'Makanan';
      case 'kamar':
        return 'Kamar';
      default:
        return 'Lainnya';
    }
  }

  Color _getStatusColor(String status) {
    return _controller.getStatusColor(status);
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final statusColor = _getStatusColor(complaint.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.report_problem,
            color: statusColor,
          ),
        ),
        title: Text(complaint.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(complaint.userName),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    complaint.status,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getCategoryLabel(complaint.category),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showComplaintDetails(complaint),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingComplaints = _controller.allComplaints.where((c) => c.status == 'pending').length;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadData();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Colors.blueGrey[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manajemen Keluhan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total: ${_controller.allComplaints.length} keluhan • Pending: $pendingComplaints',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            return TextField(
                              controller: _controller.searchController,
                              decoration: InputDecoration(
                                labelText: 'Cari keluhan...',
                                prefixIcon: const Icon(Icons.search),
                                border: const OutlineInputBorder(),
                                suffixIcon: _controller.searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _controller.searchController.clear();
                                            _controller.filterComplaints();
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _controller.filterComplaints();
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return DropdownButton<String>(
                            value: _controller.selectedStatus,
                            items: const [
                              DropdownMenuItem(value: 'semua', child: Text('Semua')),
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'in_progress', child: Text('Diproses')),
                              DropdownMenuItem(value: 'resolved', child: Text('Selesai')),
                              DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _controller.selectedStatus = value!;
                                _controller.filterComplaints();
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_controller.filteredComplaints.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.report_problem,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak ada keluhan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _controller.searchController.text.isEmpty && _controller.selectedStatus == 'semua'
                                ? 'Belum ada keluhan yang masuk'
                                : 'Tidak ditemukan hasil pencarian',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Column(
                      children: _controller.filteredComplaints.map(_buildComplaintCard).toList(),
                    ),
                ],
              ),
            ),
    );
  }
}