import 'package:flutter/material.dart';
import '../models/request.dart';
import '../screens/health_request_screens.dart';

class HealthRequestManagement extends StatefulWidget {
  const HealthRequestManagement({super.key});

  @override
  State<HealthRequestManagement> createState() =>
      _HealthRequestManagementState();
}

class _HealthRequestManagementState extends State<HealthRequestManagement> {
  late HealthRequestManagementController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = HealthRequestManagementController();
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
                  _buildDetailItem(
                    'Jenis',
                    _controller.getTypeLabel(request.type),
                  ),
                  _buildDetailItem('Status', request.status),
                  _buildDetailItem(
                    'Tanggal',
                    _controller.formatDate(request.date),
                  ),
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
                      _showSnackBar(
                        context,
                        'Pengajuan berhasil ditolak',
                        Colors.green,
                      );
                    } catch (e) {
                      _showSnackBar(
                        context,
                        'Gagal mengupdate pengajuan: $e',
                        Colors.red,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                      _showSnackBar(
                        context,
                        'Pengajuan berhasil disetujui',
                        Colors.green,
                      );
                    } catch (e) {
                      _showSnackBar(
                        context,
                        'Gagal mengupdate pengajuan: $e',
                        Colors.red,
                      );
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
      case 'kesehatan':
        return Icons.medical_services;
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
          child: Icon(_getTypeIcon(request.type), color: statusColor),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
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
          Text(value, style: const TextStyle(fontSize: 14)),
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
    final pendingRequests = _controller.allRequests
        .where((r) => r.status == 'pending')
        .length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await _loadData();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengajuan Kesehatan',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Proses pengajuan kesehatan narapidana',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Total',
                                  value: '${_controller.allRequests.length}',
                                  color: Colors.green,
                                  icon: Icons.request_page,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Pending',
                                  value: '$pendingRequests',
                                  color: Colors.orange,
                                  icon: Icons.pending,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                suffixIcon:
                                    _controller.searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          setState(() {
                                            _controller.searchController
                                                .clear();
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
                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            child: DropdownButton<String>(
                              value: _controller.selectedStatus,
                              underline: const SizedBox(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'pending',
                                  child: Text('Pending'),
                                ),
                                DropdownMenuItem(
                                  value: 'semua',
                                  child: Text('Semua'),
                                ),
                                DropdownMenuItem(
                                  value: 'approved',
                                  child: Text('Disetujui'),
                                ),
                                DropdownMenuItem(
                                  value: 'rejected',
                                  child: Text('Ditolak'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _controller.selectedStatus = value!;
                                  _controller.filterRequests();
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_controller.filteredRequests.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada pengajuan kesehatan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _controller.searchController.text.isEmpty &&
                                    _controller.selectedStatus == 'pending'
                                ? 'Belum ada pengajuan kesehatan yang masuk'
                                : 'Tidak ditemukan hasil pencarian',
                            textAlign: TextAlign.center,
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
                      children: _controller.filteredRequests
                          .map(_buildRequestCard)
                          .toList(),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
