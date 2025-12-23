import 'package:flutter/material.dart';
import '../models/request.dart';
import '../screens/admin_request_screens.dart';

class AdminRequestManagement extends StatefulWidget {
  const AdminRequestManagement({super.key});

  @override
  State<AdminRequestManagement> createState() => _AdminRequestManagementState();
}

class _AdminRequestManagementState extends State<AdminRequestManagement> {
  late AdminRequestManagementController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AdminRequestManagementController();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadRequests(context);
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

  void _showRequestDetails(RequestModel request) {
    _controller.adminNoteController.text = request.adminNote ?? '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(request.title),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailItem('Dari', request.userName),
                  _buildDetailItem('Jenis', _controller.getTypeLabel(request.type)),
                  _buildDetailItem('Status', request.status),
                  _buildDetailItem('Tanggal', _controller.formatDate(request.date)),
                  const SizedBox(height: 12),
                  const Text(
                    'Deskripsi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(request.description),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller.adminNoteController,
                    decoration: const InputDecoration(
                      labelText: 'Catatan untuk narapidana',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              if (request.status == 'pending') ...[
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _controller.updateRequestStatus(
                        context,
                        request.id,
                        'rejected',
                        _controller.adminNoteController.text,
                      );
                      Navigator.pop(context);
                      _showSnackBar(context, 'Pengajuan berhasil ditolak', Colors.green);
                    } catch (e) {
                      _showSnackBar(context, 'Gagal mengupdate pengajuan: $e', Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text('Tolak'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _controller.updateRequestStatus(
                        context,
                        request.id,
                        'approved',
                        _controller.adminNoteController.text,
                      );
                      Navigator.pop(context);
                      _showSnackBar(context, 'Pengajuan berhasil disetujui', Colors.green);
                    } catch (e) {
                      _showSnackBar(context, 'Gagal mengupdate pengajuan: $e', Colors.red);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Setujui'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _getTypeLabel(String type) {
    return _controller.getTypeLabel(type);
  }

  Color _getStatusColor(String status) {
    return _controller.getStatusColor(status);
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'pindah_sel':
        return Icons.home;
      case 'kebutuhan_khusus':
        return Icons.accessible;
      case 'kesehatan':
        return Icons.medical_services;
      case 'keluarga':
        return Icons.family_restroom;
      default:
        return Icons.question_mark;
    }
  }

  Widget _buildRequestCard(RequestModel request) {
    final statusColor = _getStatusColor(request.status);

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
            _getTypeIcon(request.type),
            color: statusColor,
          ),
        ),
        title: Text(request.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.userName),
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
                    request.status,
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
                    _getTypeLabel(request.type),
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
        onTap: () => _showRequestDetails(request),
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
    final pendingRequests = _controller.allRequests.where((r) => r.status == 'pending').length;

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
                            'Manajemen Pengajuan',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Total: ${_controller.allRequests.length} pengajuan • Pending: $pendingRequests',
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
                                labelText: 'Cari pengajuan...',
                                prefixIcon: const Icon(Icons.search),
                                border: const OutlineInputBorder(),
                                suffixIcon: _controller.searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _controller.searchController.clear();
                                            _controller.filterRequests();
                                          });
                                        },
                                      )
                                    : null,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _controller.filterRequests();
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
                              DropdownMenuItem(value: 'pending', child: Text('Pending')),
                              DropdownMenuItem(value: 'semua', child: Text('Semua')),
                              DropdownMenuItem(value: 'approved', child: Text('Disetujui')),
                              DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _controller.selectedStatus = value!;
                                _controller.filterRequests();
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_controller.filteredRequests.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.request_page,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak ada pengajuan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _controller.searchController.text.isEmpty && _controller.selectedStatus == 'pending'
                                ? 'Belum ada pengajuan yang masuk'
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
                      children: _controller.filteredRequests.map(_buildRequestCard).toList(),
                    ),
                ],
              ),
            ),
    );
  }
}