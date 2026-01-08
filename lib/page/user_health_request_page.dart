import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../service/auth_service.dart';
import '../service/firebase_service.dart';
import '../models/request.dart';

class UserHealthRequestScreen extends StatefulWidget {
  const UserHealthRequestScreen({super.key});

  @override
  State<UserHealthRequestScreen> createState() =>
      _UserHealthRequestScreenState();
}

class _UserHealthRequestScreenState extends State<UserHealthRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _healthTypes = [
    {'value': 'pemeriksaan_umum', 'label': 'Pemeriksaan Umum'},
    {'value': 'sakit_gigi', 'label': 'Sakit Gigi'},
    {'value': 'sakit_kepala', 'label': 'Sakit Kepala'},
    {'value': 'demam', 'label': 'Demam'},
    {'value': 'luka', 'label': 'Luka/Cedera'},
    {'value': 'obat', 'label': 'Kebutuhan Obat'},
    {'value': 'darurat', 'label': 'Darurat Medis'},
    {'value': 'lainnya', 'label': 'Lainnya'},
  ];

  String _selectedHealthType = 'pemeriksaan_umum';
  bool _isSubmitting = false;
  List<RequestModel> _userHealthRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserHealthRequests();
  }

  Future<void> _loadUserHealthRequests() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final user = authService.currentUser!;

      final allRequests = await firebaseService.getUserRequests(user.id);
      _userHealthRequests = allRequests
          .where((request) => request.type == 'kesehatan')
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading health requests: $e');
    }
  }

  Future<void> _submitHealthRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final user = authService.currentUser!;

      final request = RequestModel(
        id: '',
        userId: user.id,
        userName: user.fullName,
        type: 'kesehatan',
        title: _titleController.text,
        description:
            '${_getHealthTypeLabel(_selectedHealthType)}\n\n${_descriptionController.text}',
        status: 'pending',
        date: DateTime.now(),
      );

      await firebaseService.addRequest(request);

      _titleController.clear();
      _descriptionController.clear();
      _selectedHealthType = 'pemeriksaan_umum';

      await _loadUserHealthRequests();

      setState(() {
        _isSubmitting = false;
      });

      _showSnackBar(
        context,
        'Pengajuan kesehatan berhasil dikirim',
        Colors.green,
      );
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      _showSnackBar(context, 'Gagal mengirim pengajuan', Colors.red);
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'disetujui':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'diproses':
        return Icons.healing;
      case 'disetujui':
        return Icons.check_circle;
      case 'ditolak':
        return Icons.cancel;
      default:
        return Icons.error;
    }
  }

  String _getHealthTypeLabel(String type) {
    final healthType = _healthTypes.firstWhere(
      (t) => t['value'] == type,
      orElse: () => {'value': type, 'label': 'Lainnya'},
    );
    return healthType['label']!;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildHealthRequestCard(RequestModel request) {
    final statusColor = _getStatusColor(request.status);
    final statusIcon = _getStatusIcon(request.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        request.title,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 16, color: statusColor),
                            const SizedBox(width: 8),
                            Text(
                              'Status: ${request.status.toUpperCase()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Detail Keluhan:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(request.description),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text('Tanggal: ${_formatDate(request.date)}'),
                        ],
                      ),
                      if (request.processedDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.event_available,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Diproses: ${_formatDate(request.processedDate!)}',
                            ),
                          ],
                        ),
                      ],
                      if (request.processedBy != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text('Oleh: ${request.processedBy}'),
                          ],
                        ),
                      ],
                      if (request.adminNote != null &&
                          request.adminNote!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.note,
                                    size: 16,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Catatan Tenaga Kesehatan:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(request.adminNote!),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.medical_services,
                            color: Colors.red[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              request.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[900],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            request.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  request.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(request.date),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    if (request.processedBy != null) ...[
                      Icon(Icons.person, size: 14, color: Colors.blue[700]),
                      const SizedBox(width: 6),
                      Text(
                        request.processedBy!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthRequestForm() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_services, color: Colors.red[400], size: 24),
                const SizedBox(width: 12),
                Text(
                  'Pengajuan Kesehatan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedHealthType,
              decoration: InputDecoration(
                labelText: 'Jenis Keluhan Kesehatan',
                prefixIcon: const Icon(Icons.healing),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: _healthTypes.map((type) {
                return DropdownMenuItem(
                  value: type['value'],
                  child: Text(type['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHealthType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Judul Keluhan',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Judul harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Detail Keluhan Kesehatan',
                prefixIcon: const Icon(Icons.description),
                hintText:
                    'Jelaskan gejala, keluhan, atau kebutuhan kesehatan Anda secara detail',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Detail keluhan harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[600]!, Colors.red[400]!],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: _isSubmitting ? null : _submitHealthRequest,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSubmitting)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.send_rounded, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _isSubmitting ? 'Mengirim...' : 'Kirim Pengajuan',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserHealthRequests,
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
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red[400]!,
                                      Colors.red[300]!,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.local_hospital,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Layanan Kesehatan',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueGrey[900],
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Ajukan kebutuhan kesehatan Anda',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Total Pengajuan',
                                  value: '${_userHealthRequests.length}',
                                  color: Colors.blue,
                                  icon: Icons.description,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Pending',
                                  value:
                                      '${_userHealthRequests.where((r) => r.status == 'pending').length}',
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
                  _buildHealthRequestForm(),
                  const SizedBox(height: 24),
                  Text(
                    'Riwayat Pengajuan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_userHealthRequests.isEmpty)
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
                            'Belum ada pengajuan kesehatan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kirim pengajuan kesehatan Anda dengan menggunakan formulir di atas',
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
                      children: _userHealthRequests
                          .map(_buildHealthRequestCard)
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
