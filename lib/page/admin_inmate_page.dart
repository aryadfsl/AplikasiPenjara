import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../screens/add_narapidana_screens.dart';
import '../models/user.dart';

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
                      value: _controller.selectedStatus,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(inmate.fullName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Email', inmate.email),
              _buildDetailItem('ID Narapidana', inmate.inmateId),
              _buildDetailItem('Blok', inmate.block),
              _buildDetailItem('Sel', inmate.cell),
              _buildDetailItem('Kasus', inmate.crime),
              _buildDetailItem('Hukuman Mulai', _controller.formatDate(inmate.sentenceStart)),
              _buildDetailItem('Hukuman Akhir', _controller.formatDate(inmate.sentenceEnd)),
              _buildDetailItem('Sisa Waktu', _controller.calculateRemainingTime(inmate.sentenceEnd)),
              _buildDetailItem('Status', inmate.status.toUpperCase()),
              _buildDetailItem('Tanggal Daftar', _controller.formatDate(inmate.registrationDate)),
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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddInmateDialog,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
                          'Manajemen Narapidana',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total: ${_controller.allUsers.length} narapidana',
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
                StatefulBuilder(
                  builder: (context, setState) {
                    return TextField(
                      controller: _controller.searchController,
                      decoration: InputDecoration(
                        labelText: 'Cari narapidana...',
                        prefixIcon: const Icon(Icons.search),
                        border: const OutlineInputBorder(),
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
                const SizedBox(height: 16),
                if (_controller.filteredUsers.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.people,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada narapidana',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _controller.searchController.text.isEmpty
                              ? 'Tambahkan narapidana baru'
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
                    children: _controller.filteredUsers.map((inmate) {
                      final statusColor = _controller.getStatusColor(inmate.status);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          child: Text(
                            inmate.fullName.isEmpty ? '?' : inmate.fullName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          inmate.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(inmate.inmateId),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            inmate.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                        onTap: () => _showInmateDetails(inmate),
                      );
                    }).toList(),
                  ),
              ],
            ),
    );
  }
}
