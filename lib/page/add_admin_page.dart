import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/add_narapidana_screens.dart';
import '../models/user.dart';
import 'detail_page.dart';

class AdminInmateManagement extends StatefulWidget {
  const AdminInmateManagement({super.key});

  @override
  State<AdminInmateManagement> createState() => _AdminInmateManagementState();
}

class _AdminInmateManagementState extends State<AdminInmateManagement> {
  late AdminInmateManagementController _controller;
  bool _isLoading = true;
  XFile? _photoFile;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = AdminInmateManagementController();
    _loadData();
  }

  Future<void> _loadData() async {
    await _controller.loadUsers(context);
    if (mounted) {
      setState(() {
        _isLoading = _controller.isLoading;
      });
    }
  }

  void _showAddInmateDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Narapidana Baru'),
            content: SingleChildScrollView(
              child: Form(
                key: _controller.formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _photoFile = image;
                          });
                        }
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blueGrey),
                        ),
                        child: _photoFile != null
                            ? FutureBuilder<Uint8List>(
                                future: _photoFile!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                                    );
                                  } else {
                                    return const Center(child: CircularProgressIndicator());
                                  }
                                },
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 40, color: Colors.blueGrey),
                                  const SizedBox(height: 8),
                                  const Text('Pilih Foto', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _controller.fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controller.inmateIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID Narapidana',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controller.blockController,
                      decoration: const InputDecoration(
                        labelText: 'Blok',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controller.cellController,
                      decoration: const InputDecoration(
                        labelText: 'Sel',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controller.crimeController,
                      decoration: const InputDecoration(
                        labelText: 'Kasus/Kejahatan',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controller.sentenceStartDateController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Mulai Hukuman',
                        hintText: 'dd/MM/yyyy',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _controller.sentenceStartDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _controller.sentenceStartDate = date;
                                _controller.sentenceStartDateController.text = _controller.formatDate(date);
                              });
                            }
                          },
                        ),
                      ),
                      readOnly: true,
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _controller.sentenceEndDateController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Akhir Hukuman',
                        hintText: 'dd/MM/yyyy',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            if (_controller.sentenceStartDate == null) {
                              _showSnackBar(context, 'Pilih tanggal mulai hukuman terlebih dahulu', Colors.red);
                              return;
                            }
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _controller.sentenceEndDate ?? _controller.sentenceStartDate ?? DateTime.now(),
                              firstDate: _controller.sentenceStartDate ?? DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (date != null) {
                              setState(() {
                                _controller.sentenceEndDate = date;
                                _controller.sentenceEndDateController.text = _controller.formatDate(date);
                              });
                            }
                          },
                        ),
                      ),
                      readOnly: true,
                      validator: (value) => value!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField(
                      initialValue: _controller.selectedStatus,
                      items: ['aktif', 'transfer', 'bebas'].map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _controller.selectedStatus = value ?? 'aktif';
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_controller.formKey.currentState!.validate() &&
                      _controller.sentenceStartDate != null &&
                      _controller.sentenceEndDate != null) {
                    try {
                      await _controller.addInmate(context);
                      Navigator.pop(context);
                      _showSnackBar(context, 'Narapidana berhasil ditambahkan', Colors.green);
                      setState(() {});
                    } catch (e) {
                      _showSnackBar(context, 'Gagal menambahkan narapidana: $e', Colors.red);
                    }
                  }
                },
                child: const Text('Tambah'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInmateDetails(UserModel inmate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminInmateDetailPage(inmate: inmate),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddInmateDialog,
        backgroundColor: Colors.blueGrey[800],
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Narapidana Baru', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
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
                            'Manajemen Narapidana',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey[900],
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kelola data dan informasi narapidana',
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
                                  value: '${_controller.allUsers.length}',
                                  color: Colors.blue,
                                  icon: Icons.people,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  title: 'Aktif',
                                  value: '${_controller.allUsers.where((u) => u.status == 'aktif').length}',
                                  color: Colors.green,
                                  icon: Icons.check_circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  StatefulBuilder(
                    builder: (context, setState) {
                      return TextField(
                        controller: _controller.searchController,
                        decoration: InputDecoration(
                          labelText: 'Cari narapidana...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: _controller.searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    setState(() {
                                      _controller.searchController.clear();
                                      _controller.searchUsers('');
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (query) {
                          setState(() {
                            _controller.searchUsers(query);
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  if (_controller.filteredUsers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada narapidana',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _controller.searchController.text.isEmpty
                                ? 'Tambahkan narapidana baru dengan tombol di bawah'
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
                      children: _controller.filteredUsers.map((inmate) {
                        final statusColor = _controller.getStatusColor(inmate.status);
                        return _buildInmateCard(inmate, statusColor);
                      }).toList(),
                    ),
                  const SizedBox(height: 100),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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

  Widget _buildInmateCard(UserModel inmate, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () => _showInmateDetails(inmate),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blueGrey[100],
                  radius: 28,
                  child: Text(
                    inmate.fullName.isEmpty ? '?' : inmate.fullName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[900],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inmate.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.badge_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            inmate.inmateId,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.home_outlined, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 6),
                          Text(
                            '${inmate.block}-${inmate.cell}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    inmate.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
